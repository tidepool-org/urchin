/*
* Copyright (c) 2016, Tidepool Project
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the associated License, which is identical to the BSD 2-Clause
* License as published by the Open Source Initiative at opensource.org.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the License for more details.
*
* You should have received a copy of the License along with this program; if
* not, you can obtain one from Tidepool Project at tidepool.org.
*/

import HealthKit
import CocoaLumberjack
import CryptoSwift

class HealthKitDataUploader {
    // MARK: Access, authorization
    
    static let sharedInstance = HealthKitDataUploader()
    private init() {
        DDLogVerbose("trace")
        
        let latestUploaderVersion = 2
        
        let lastExecutedUploaderVersion = NSUserDefaults.standardUserDefaults().integerForKey("lastExecutedUploaderVersion")
        var resetPersistentData = false
        if latestUploaderVersion != lastExecutedUploaderVersion {
            DDLogInfo("Migrating uploader to \(latestUploaderVersion)")
            NSUserDefaults.standardUserDefaults().setInteger(latestUploaderVersion, forKey: "lastExecutedUploaderVersion")
            resetPersistentData = true
        }
        
        initState(resetPersistentData)
     }
    
    private func initState(resetUser: Bool = false) {
        if resetUser {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("bloodGlucoseQueryAnchor")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("bloodGlucoseUploadRecentEndDate")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("bloodGlucoseUploadRecentStartDate")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("bloodGlucoseUploadRecentStartDateFinal")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("lastUploadSampleTimeBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("totalUploadCountBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("totalUploadCountBloodGlucoseSamplesWithoutDuplicates")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("workoutQueryAnchor")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            DDLogInfo("Reset upload stats and HealthKit query anchor during migration")
        }
        
        let lastUploadSampleTime = NSUserDefaults.standardUserDefaults().objectForKey("lastUploadSampleTimeBloodGlucoseSamples")
        if lastUploadSampleTime != nil {
            self.lastUploadSampleTimeBloodGlucoseSamples = lastUploadSampleTime as! NSDate
            self.totalUploadCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalUploadCountBloodGlucoseSamples")
            self.totalUploadCountBloodGlucoseSamplesWithoutDuplicates = NSUserDefaults.standardUserDefaults().integerForKey("totalUploadCountBloodGlucoseSamplesWithoutDuplicates")
        } else {
            self.lastUploadSampleTimeBloodGlucoseSamples = NSDate.distantPast()
            self.totalUploadCountBloodGlucoseSamples = 0
            self.totalUploadCountBloodGlucoseSamplesWithoutDuplicates = 0
        }
        
        if resetUser {
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.UploadedBloodGlucoseSamples, object: nil))
            }
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseQueryAnchor") == nil {
            DDLogInfo("Anchor does not exist, we'll upload most recent samples first")
            self.shouldUploadMostRecentFirst = true
        } else {
            DDLogInfo("Anchor exists, we'll upload samples from anchor query")
        }
    }

    enum Notifications {
        static let StartedUploading = "HealthKitDataUpload-started"
        static let StoppedUploading = "HealthKitDataUpload-stopped"
        static let UploadedBloodGlucoseSamples = "HealthKitDataUpload-uploaded-\(HKQuantityTypeIdentifierBloodGlucose)"
    }
    
    private(set) var isUploading = false
    private(set) var isReadingMostRecentSamples = false
    private(set) var isReadingSamplesFromAnchor = false
    private(set) var shouldUploadMostRecentFirst = false
    
    private(set) var lastUploadSampleTimeBloodGlucoseSamples = NSDate.distantPast()
    private(set) var totalUploadCountBloodGlucoseSamples = 0
    private(set) var totalUploadCountBloodGlucoseSamplesWithoutDuplicates = 0
    
    var uploadHandler: ((postBody: NSData, completion: (error: NSError?, duplicateItemCount: Int) -> (Void)) -> (Void)) = {(postBody, completion) in }

    func authorizeAndStartUploading(currentUserId currentUserId: String)
    {
        DDLogVerbose("trace")
        
        HealthKitManager.sharedInstance.authorize(
            shouldAuthorizeBloodGlucoseSampleReads: true, shouldAuthorizeBloodGlucoseSampleWrites: false,
            shouldAuthorizeWorkoutSamples: false) {
                success, error -> Void in
                
                if error == nil {
                    DDLogInfo("Authorization did not have an error (though we don't know whether permission was given), start uploading if possible")
                    self.startUploading(currentUserId: currentUserId)
                } else {
                    DDLogError("Error authorizing health data, success: \(success), \(error))")
                }
        }
    }
    
    func startUploading(currentUserId currentUserId: String?) {
        DDLogVerbose("trace")
        
        guard currentUserId != nil else {
            DDLogInfo("No logged in user, unable to upload")
            return
        }
        
        guard HealthKitManager.sharedInstance.isHealthDataAvailable else {
            DDLogError("Health data not available, ignoring request to upload")
            return
        }
        
        isUploading = true

        // Remember the user id for the uploads
        self.currentUserId = currentUserId
        
        // Start observing samples. We don't really start uploading until we've successsfully started observing
        HealthKitManager.sharedInstance.startObservingBloodGlucoseSamples(self.bloodGlucoseObservationHandler)

        DDLogInfo("start reading samples - start uploading")
        self.startReadingSamples()

        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.StartedUploading, object: nil))
    }
    
    func stopUploading() {
        DDLogVerbose("trace")
        
        guard isUploading else {
            DDLogInfo("Not currently uploading, ignoring request to stop uploading")
            return
        }
        
        self.isUploading = false
        self.currentUserId = nil
        HealthKitManager.sharedInstance.disableBackgroundDeliveryWorkoutSamples()
        HealthKitManager.sharedInstance.stopObservingBloodGlucoseSamples()

        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.StoppedUploading, object: nil))
    }

    // TODO: review; should only be called when a non-current HK user is logged in!
    func resetHealthKitUploaderForNewUser() {
        DDLogVerbose("Switching healthkit user, need to reset anchors!")
        initState(true)
    }
    

    // MARK: Private - observation and results handlers

    private func bloodGlucoseObservationHandler(error: NSError?) {
        DDLogVerbose("trace")

        if error == nil {
            dispatch_async(dispatch_get_main_queue(), {
                HealthKitManager.sharedInstance.enableBackgroundDeliveryBloodGlucoseSamples()

                DDLogInfo("start reading samples - started observing blood glucose samples")
                self.startReadingSamples()
            })
        }
    }
    
    private func bloodGlucoseResultHandler(error: NSError?, newSamples: [HKSample]?, completion: (NSError?) -> (Void)) {
        DDLogVerbose("trace")
        
        var samplesAvailableToUpload = false
        
        defer {
            if !samplesAvailableToUpload {
                self.handleNoResultsToUpload(error: error, completion: completion)
            }
        }
        
        guard error == nil else {
            return
        }
        
        guard let samples = newSamples where samples.count > 0 else {
            return
        }
        
        self.filterSortAndGroupSamplesForUpload(samples)
        let groupCount = currentSamplesToUploadBySource.count
        if let (_, samples) = self.currentSamplesToUploadBySource.popFirst() {
            samplesAvailableToUpload = true
            
            // Start first batch upload for available groups
            DDLogInfo("Start batch upload for \(groupCount) remaining distinct-source-app-groups of samples")
            startBatchUpload(samples: samples, completion: completion)
        }
    }
 
    // MARK: Private - upload

    private func startBatchUpload(samples samples: [HKSample], completion: (NSError?) -> (Void)) {
        DDLogVerbose("trace")
        
        let firstSample = samples[0]
        let sourceRevision = firstSample.sourceRevision
        let source = sourceRevision.source
        let sourceBundleIdentifier = source.bundleIdentifier
        let deviceModel = deviceModelForSourceBundleIdentifier(sourceBundleIdentifier)
        let deviceId = "\(deviceModel)_\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        let timeZoneOffset = NSCalendar.currentCalendar().timeZone.secondsFromGMT / 60
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let appBuild = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        let appBundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        let version = "\(appBundleIdentifier):\(appVersion):\(appBuild)"
        let time = dateFormatter.isoStringFromDate(now)
        let guid = NSUUID().UUIDString
        let uploadIdSuffix = "\(deviceId)_\(time)_\(guid)"
        let uploadIdSuffixMd5Hash = uploadIdSuffix.md5()
        let uploadId = "upid_\(uploadIdSuffixMd5Hash)"
        
        self.currentBatchUploadDict = [String: AnyObject]()
        self.currentBatchUploadDict["type"] = "upload"
        self.currentBatchUploadDict["uploadId"] = uploadId
        self.currentBatchUploadDict["computerTime"] = dateFormatter.isoStringFromDate(now, zone: NSTimeZone(forSecondsFromGMT: 0), dateFormat: iso8601dateNoTimeZone)
        self.currentBatchUploadDict["time"] = time
        self.currentBatchUploadDict["timezoneOffset"] = timeZoneOffset
        self.currentBatchUploadDict["timezone"] = NSTimeZone.localTimeZone().name
        self.currentBatchUploadDict["timeProcessing"] = "none"
        self.currentBatchUploadDict["version"] = version
        self.currentBatchUploadDict["guid"] = guid
        self.currentBatchUploadDict["byUser"] = currentUserId
        self.currentBatchUploadDict["deviceTags"] = ["cgm"]
        self.currentBatchUploadDict["deviceManufacturers"] = ["Dexcom"]
        self.currentBatchUploadDict["deviceSerialNumber"] = ""
        self.currentBatchUploadDict["deviceModel"] = deviceModel
        self.currentBatchUploadDict["deviceId"] = deviceId

        do {
            let postBody = try NSJSONSerialization.dataWithJSONObject(self.currentBatchUploadDict, options: NSJSONWritingOptions.PrettyPrinted)
            if defaultDebugLevel != DDLogLevel.Off {
                let postBodyString = NSString(data: postBody, encoding: NSUTF8StringEncoding)! as String
                DDLogVerbose("Start batch upload JSON: \(postBodyString)")
            }
            
            self.uploadHandler(postBody: postBody) {
                (error: NSError?, duplicateItemCount: Int) in
                if error == nil {
                    self.uploadSamplesForBatch(samples: samples, completion: completion)
                } else {
                    DDLogError("stop reading samples - error starting batch upload of samples: \(error)")
                    self.stopReadingSamples(completion: completion, error: error)
                }
            }
        } catch let error as NSError! {
            DDLogError("stop reading samples - error creating post body for start of batch upload: \(error)")
            self.stopReadingSamples(completion: completion, error: error)
        }
    }
    
    private func uploadSamplesForBatch(samples samples: [HKSample], completion: (NSError?) -> (Void)) {
        DDLogVerbose("trace")

        // Prepare upload post body
        let dateFormatter = NSDateFormatter()
        var samplesToUploadDictArray = [[String: AnyObject]]()
        for sample in samples {
            var sampleToUploadDict = [String: AnyObject]()
            
            sampleToUploadDict["uploadId"] = self.currentBatchUploadDict["uploadId"]
            sampleToUploadDict["type"] = "cbg"
            sampleToUploadDict["deviceId"] = self.currentBatchUploadDict["deviceId"]
            sampleToUploadDict["guid"] = sample.UUID.UUIDString
            sampleToUploadDict["time"] = dateFormatter.isoStringFromDate(sample.startDate, zone: NSTimeZone(forSecondsFromGMT: 0), dateFormat: iso8601dateZuluTime)
            
            if let quantitySample = sample as? HKQuantitySample {
                let units = "mg/dL"
                sampleToUploadDict["units"] = units
                let unit = HKUnit(fromString: units)
                let value = quantitySample.quantity.doubleValueForUnit(unit)
                sampleToUploadDict["value"] = value
                
                // Add out-of-range annotation if needed
                var annotationCode: String?
                var annotationValue: String?
                var annotationThreshold = 0
                if (value < 40) {
                    annotationCode = "bg/out-of-range"
                    annotationValue = "low"
                    annotationThreshold = 40
                } else if (value > 400) {
                    annotationCode = "bg/out-of-range"
                    annotationValue = "high"
                    annotationThreshold = 400
                }
                if let annotationCode = annotationCode,
                       annotationValue = annotationValue {
                    let annotations = [
                        [
                            "code": annotationCode,
                            "value": annotationValue,
                            "threshold": annotationThreshold
                        ]
                    ]
                    sampleToUploadDict["annotations"] = annotations
                }
            }
            
            // Add sample metadata payload props
            if var metadata = sample.metadata {
                for (key, value) in metadata {
                    if let dateValue = value as? NSDate {
                        if key == "Receiver Display Time" {
                            metadata[key] = dateFormatter.isoStringFromDate(dateValue, zone: NSTimeZone(forSecondsFromGMT: 0), dateFormat: iso8601dateNoTimeZone)
                            
                        } else {
                            metadata[key] = dateFormatter.isoStringFromDate(dateValue, zone: NSTimeZone(forSecondsFromGMT: 0), dateFormat: iso8601dateZuluTime)
                        }
                    }
                }
                
                // If "Receiver Display Time" exists, use that as deviceTime and remove from metadata payload
                if let receiverDisplayTime = metadata["Receiver Display Time"] {
                    sampleToUploadDict["deviceTime"] = receiverDisplayTime
                    metadata.removeValueForKey("Receiver Display Time")
                }
                sampleToUploadDict["payload"] = metadata
            }
            
            // Add sample
            samplesToUploadDictArray.append(sampleToUploadDict)
        }

        do {
            let postBody = try NSJSONSerialization.dataWithJSONObject(samplesToUploadDictArray, options: NSJSONWritingOptions.PrettyPrinted)
            if defaultDebugLevel != DDLogLevel.Off {
                let postBodyString = NSString(data: postBody, encoding: NSUTF8StringEncoding)! as String
                DDLogVerbose("Samples to upload: \(postBodyString)")
            }
            
            self.uploadHandler(postBody: postBody) {
                (error: NSError?, duplicateItemCount: Int) in
                if error == nil {
                    self.updateStats(samples: samples, duplicateItemCount: duplicateItemCount)
                    
                    let groupCount = self.currentSamplesToUploadBySource.count
                    if let (_, samples) = self.currentSamplesToUploadBySource.popFirst() {
                        // Start next batch upload for groups
                        DDLogInfo("Start next upload for \(groupCount) remaining distinct-source-app-groups of samples")
                        self.startBatchUpload(samples: samples, completion: completion)
                    } else {
                        DDLogInfo("stop reading samples - finished uploading groups from last read")
                        self.readMore(completion: completion)
                    }
                } else {
                    DDLogError("stop reading samples - error uploading samples: \(error)")
                    self.stopReadingSamples(completion: completion, error: error)
                }
            }
        } catch let error as NSError! {
            DDLogError("stop reading samples - error creating post body for start of batch upload: \(error)")
            self.stopReadingSamples(completion: completion, error: error)
        }
    }
    
    private func deviceModelForSourceBundleIdentifier(sourceBundleIdentifier: String) -> String {
        var deviceModel = ""
        
        if sourceBundleIdentifier.lowercaseString.rangeOfString("com.dexcom.cgm") != nil {
            deviceModel = "DexG5"
        } else if sourceBundleIdentifier.lowercaseString.rangeOfString("com.dexcom.share2") != nil {
            deviceModel = "DexG4"
        } else {
            DDLogError("Unknown Dexcom sourceBundleIdentifier: \(sourceBundleIdentifier)")
            deviceModel = "DexUnknown"
        }
        
        return "HealthKit_\(deviceModel)"
    }
    
    private func filterSortAndGroupSamplesForUpload(samples: [HKSample]) {
        DDLogVerbose("trace")

        var samplesBySource = [String: [HKSample]]()
        var samplesLatestSampleTimeBySource = [String: NSDate]()
        
        let sortedSamples = samples.sort({x, y in
            return x.startDate.compare(y.startDate) == .OrderedAscending
        })
        
        // Group by source
        for sample in sortedSamples {
            let sourceRevision = sample.sourceRevision
            let source = sourceRevision.source
            let sourceBundleIdentifier = source.bundleIdentifier

            if source.name.lowercaseString.rangeOfString("dexcom") == nil {
                DDLogInfo("Ignoring non-Dexcom glucose data")
                continue
            }

            if samplesBySource[sourceBundleIdentifier] == nil {
                samplesBySource[sourceBundleIdentifier] = [HKSample]()
                samplesLatestSampleTimeBySource[sourceBundleIdentifier] = NSDate.distantPast()
            }
            samplesBySource[sourceBundleIdentifier]?.append(sample)
            if sample.startDate.compare(samplesLatestSampleTimeBySource[sourceBundleIdentifier]!) == .OrderedDescending {
                samplesLatestSampleTimeBySource[sourceBundleIdentifier] = sample.startDate
            }
        }
    
        self.currentSamplesToUploadBySource = samplesBySource
        self.currentSamplesToUploadLatestSampleTimeBySource = samplesLatestSampleTimeBySource
    }
    
    // MARK: Private - upload phases (more recent, or anchor)
    
    private func startReadingSamples() {
        DDLogVerbose("trace")
        
        dispatch_async(dispatch_get_main_queue(), {
            if self.shouldUploadMostRecentFirst {
                self.startReadingMostRecentSamples()
            } else {
                self.startReadingSamplesFromAnchor()
            }
        })
    }
    
    private func stopReadingSamples(completion completion: (NSError?) -> (Void), error: NSError?) {
        DDLogVerbose("trace")

        dispatch_async(dispatch_get_main_queue(), {
            if self.isReadingMostRecentSamples {
                self.stopReadingMostRecentSamples(completion: completion, error: error)
            } else if self.isReadingSamplesFromAnchor {
                self.stopReadingSamplesFromAnchor(completion: completion, error: error)
            }
        })
    }
    
    private func handleNoResultsToUpload(error error: NSError?, completion: (NSError?) -> (Void)) {
        DDLogVerbose("trace")

        dispatch_async(dispatch_get_main_queue(), {
            if self.isReadingMostRecentSamples {
                if error == nil {
                    self.readMore(completion: completion)
                } else {
                    DDLogInfo("stop reading most recent samples due to error: \(error)")
                    self.stopReadingMostRecentSamples(completion: completion, error: error)
                }
            } else if self.isReadingSamplesFromAnchor {
                if error == nil {
                    DDLogInfo("stop reading samples from anchor - no new samples available to upload")
                    self.stopReadingSamplesFromAnchor(completion: completion, error: nil)
                } else {
                    DDLogInfo("stop reading samples from anchor due to error: \(error)")
                    self.stopReadingSamplesFromAnchor(completion: completion, error: nil)
                }
            }
        })
    }
    
    private func readMore(completion completion: (NSError?) -> (Void)) {
        DDLogVerbose("trace")
        
        dispatch_async(dispatch_get_main_queue(), {
            if self.isReadingMostRecentSamples {
                self.stopReadingMostRecentSamples(completion: completion, error: nil)

                let bloodGlucoseUploadRecentEndDate = NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseUploadRecentStartDate") as! NSDate
                let bloodGlucoseUploadRecentStartDate = bloodGlucoseUploadRecentEndDate.dateByAddingTimeInterval(-60 * 60 * 8)
                let bloodGlucoseUploadRecentStartDateFinal = NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseUploadRecentStartDateFinal") as! NSDate
                if bloodGlucoseUploadRecentEndDate.compare(bloodGlucoseUploadRecentStartDateFinal) == .OrderedAscending {
                    DDLogInfo("finished reading most recent samples - transitioning to reading samples from anchor")
                    self.shouldUploadMostRecentFirst = false
                }
                else {
                    NSUserDefaults.standardUserDefaults().setObject(bloodGlucoseUploadRecentStartDate, forKey: "bloodGlucoseUploadRecentStartDate")
                    NSUserDefaults.standardUserDefaults().setObject(bloodGlucoseUploadRecentEndDate, forKey: "bloodGlucoseUploadRecentEndDate")
                }
            } else if self.isReadingSamplesFromAnchor {
                self.stopReadingSamplesFromAnchor(completion: completion, error: nil)
            }
            self.startReadingSamples()
        })
    }
    
    // MARK: Private - anchor phase

    private func startReadingSamplesFromAnchor() {
        DDLogVerbose("trace")
        
        if !self.isReadingSamplesFromAnchor {
            self.isReadingSamplesFromAnchor = true
            HealthKitManager.sharedInstance.readBloodGlucoseSamplesFromAnchor(self.bloodGlucoseResultHandler)
        } else {
            DDLogVerbose("Already reading blood glucose samples from anchor, ignoring subsequent request to read")
        }
    }
    
    private func stopReadingSamplesFromAnchor(completion completion: (NSError?) -> (Void), error: NSError?) {
        DDLogVerbose("trace")

        if self.isReadingSamplesFromAnchor {
            completion(error)
            self.isReadingSamplesFromAnchor = false
        } else {
            DDLogVerbose("Unexpected call to stopReadingSamplesFromAnchor when not reading samples")
        }
    }
    
    // MARK: Private - most recent samples phase
    
    private func startReadingMostRecentSamples() {
        DDLogVerbose("trace")
        
        if !self.isReadingMostRecentSamples {
            self.isReadingMostRecentSamples = true
            
            let now = NSDate()
            let eightHoursAgo = now.dateByAddingTimeInterval(-60 * 60 * 8)
            let twoWeeksAgo = now.dateByAddingTimeInterval(-60 * 60 * 24 * 14)
            var bloodGlucoseUploadRecentEndDate = now
            var bloodGlucoseUploadRecentStartDate = eightHoursAgo
            var bloodGlucoseUploadRecentStartDateFinal = twoWeeksAgo
            
            let bloodGlucoseUploadRecentStartDateFinalSetting = NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseUploadRecentStartDateFinal")
            if bloodGlucoseUploadRecentStartDateFinalSetting == nil {
                NSUserDefaults.standardUserDefaults().setObject(bloodGlucoseUploadRecentEndDate, forKey: "bloodGlucoseUploadRecentEndDate")
                NSUserDefaults.standardUserDefaults().setObject(bloodGlucoseUploadRecentStartDate, forKey: "bloodGlucoseUploadRecentStartDate")
                NSUserDefaults.standardUserDefaults().setObject(bloodGlucoseUploadRecentStartDateFinal, forKey: "bloodGlucoseUploadRecentStartDateFinal")
                DDLogInfo("final date for most upload of most recent samples: \(bloodGlucoseUploadRecentStartDateFinal)")
            } else {
                bloodGlucoseUploadRecentEndDate = NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseUploadRecentEndDate") as! NSDate
                bloodGlucoseUploadRecentStartDate = NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseUploadRecentStartDate") as! NSDate
                bloodGlucoseUploadRecentStartDateFinal = bloodGlucoseUploadRecentStartDateFinalSetting as! NSDate
            }

            HealthKitManager.sharedInstance.readBloodGlucoseSamples(startDate: bloodGlucoseUploadRecentStartDate, endDate: bloodGlucoseUploadRecentEndDate, limit: 288, resultsHandler: self.bloodGlucoseResultHandler)
        } else {
            DDLogVerbose("Already reading most recent blood glucose samples, ignoring subsequent request to read")
        }
    }
    
    private func stopReadingMostRecentSamples(completion completion: (NSError?) -> (Void), error: NSError?) {
        DDLogVerbose("trace")
        
        if self.isReadingMostRecentSamples {
            completion(error)
            self.isReadingMostRecentSamples = false
        } else {
            DDLogVerbose("Unexpected call to stopReadingMostRecentSamples when not reading samples")
        }
    }
    
    // MARK: Private - stats
    
    private func updateStats(samples samples: [HKSample], duplicateItemCount: Int) {
        DDLogVerbose("trace")
        
        // Only update stats we've moved to the anchor query phase. We don't want to double count the most 
        // recent samples, since we'll end up re-uploading those once we exhaust all the samples from the 
        // anchor query and have caught up to what was already uploaded with the most recent sample upload 
        // optimization
        if !isReadingMostRecentSamples {
            if duplicateItemCount > 0 {
                DDLogInfo("Successfully uploaded \(samples.count) samples, of which \(duplicateItemCount) were duplicates. totalUploadCountBloodGlucoseSamples: \(self.totalUploadCountBloodGlucoseSamples), totalUploadCountBloodGlucoseSamplesWithoutDuplicates: \(self.totalUploadCountBloodGlucoseSamplesWithoutDuplicates)")
            } else {
                DDLogInfo("Successfully uploaded \(samples.count) samples. totalUploadCountBloodGlucoseSamples: \(self.totalUploadCountBloodGlucoseSamples), totalUploadCountBloodGlucoseSamplesWithoutDuplicates: \(self.totalUploadCountBloodGlucoseSamplesWithoutDuplicates)")
            }
            
            self.lastUploadSampleTimeBloodGlucoseSamples = currentSamplesToUploadLatestSampleTimeBySource.popFirst()!.1
            self.totalUploadCountBloodGlucoseSamples += samples.count
            self.totalUploadCountBloodGlucoseSamplesWithoutDuplicates += (samples.count - duplicateItemCount)
            
            NSUserDefaults.standardUserDefaults().setObject(lastUploadSampleTimeBloodGlucoseSamples, forKey: "lastUploadSampleTimeBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().setInteger(totalUploadCountBloodGlucoseSamples, forKey: "totalUploadCountBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().setInteger(totalUploadCountBloodGlucoseSamplesWithoutDuplicates, forKey: "totalUploadCountBloodGlucoseSamplesWithoutDuplicates")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.UploadedBloodGlucoseSamples, object: nil))
            }
        }
    }
    
    private var currentUserId: String?
    private var currentSamplesToUploadBySource = [String: [HKSample]]()
    private var currentSamplesToUploadLatestSampleTimeBySource = [String: NSDate]()
    private var currentBatchUploadDict = [String: AnyObject]()
}
