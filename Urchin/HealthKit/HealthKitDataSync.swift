/*
* Copyright (c) 2015, Tidepool Project
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
import RealmSwift

// TODO: my - Need to set up a periodic task to perodically drain the Realm db and upload those events to service, this should be able to be done as background task even when app is not active, and periodically when active

class HealthKitDataSync {
    // MARK: Access, authorization
    
    static let sharedInstance = HealthKitDataSync()
    private init() {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.path = NSURL.fileURLWithPath(config.path!)
            .URLByAppendingPathExtension("nosync")
            .path
        
        NSLog("\(__FUNCTION__): Realm path: \(config.path)")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config

        var syncTime = NSUserDefaults.standardUserDefaults().objectForKey("lastSyncTimeBloodGlucoseSamples")
        if (syncTime != nil) {
            lastSyncTimeBloodGlucoseSamples = syncTime as! NSDate
            lastSyncCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("lastSyncCountBloodGlucoseSamples")
        }
        
        syncTime = NSUserDefaults.standardUserDefaults().objectForKey("lastSyncTimeWorkoutSamples")
        if (syncTime != nil) {
            lastSyncTimeWorkoutSamples = syncTime as! NSDate
            lastSyncCountWorkoutSamples = NSUserDefaults.standardUserDefaults().integerForKey("lastSyncCountWorkoutSamples")
        }
    }
    
    private(set) var lastSyncCountBloodGlucoseSamples = -1
    private(set) var lastSyncTimeBloodGlucoseSamples = NSDate.distantPast()

    private(set) var lastSyncCountWorkoutSamples = -1
    private(set) var lastSyncTimeWorkoutSamples = NSDate.distantPast()
    
    var lastSyncCount: Int {
        get {
            let time = lastSyncTime
            var count = 0
            if (lastSyncCountBloodGlucoseSamples > 0 && fabs(lastSyncTimeBloodGlucoseSamples.timeIntervalSinceDate(time)) < 60) {
                count += lastSyncCountBloodGlucoseSamples
            }
            if (lastSyncCountWorkoutSamples > 0 && fabs(lastSyncTimeWorkoutSamples.timeIntervalSinceDate(time)) < 60) {
                count += lastSyncCountWorkoutSamples
            }
            return count
        }
    }
    
    var lastSyncTime: NSDate {
        get {
            var time = NSDate.distantPast()
            if (lastSyncCountBloodGlucoseSamples > 0 && time.compare(lastSyncTimeBloodGlucoseSamples) == .OrderedAscending) {
                time = lastSyncTimeBloodGlucoseSamples
            }
            if (lastSyncCountWorkoutSamples > 0 && time.compare(lastSyncTimeWorkoutSamples) == .OrderedAscending) {
                time = lastSyncTimeWorkoutSamples
            }
            return time
        }
    }

    let observedBloodGlucoseSamplesNotification = "HealthKitDataSync-observed-\(HKWorkoutTypeIdentifier)"
    let observedWorkoutSamplesNotification = "HealthKitDataSync-observed-\(HKWorkoutTypeIdentifier)"

    func authorizeAndStartSyncing(
            shouldSyncBloodGlucoseSamples shouldSyncBloodGlucoseSamples: Bool,
            shouldSyncWorkoutSamples: Bool)
    {
        if #available(iOS 9.0, *) {
            HealthKitManager.sharedInstance.authorize(
                shouldAuthorizeBloodGlucoseSamples: shouldSyncBloodGlucoseSamples,
                shouldAuthorizeWorkoutSamples: shouldSyncWorkoutSamples) {
                success, error -> Void in
                if (error == nil) {
                    self.startSyncing(
                        shouldSyncBloodGlucoseSamples: shouldSyncBloodGlucoseSamples,
                        shouldSyncWorkoutSamples: shouldSyncWorkoutSamples)
                } else {
                    NSLog("\(__FUNCTION__): Error authorizing health data \(error), \(error!.userInfo)")
                }
            }
        }
    }
    
    // MARK: Sync control
    
    func startSyncing(shouldSyncBloodGlucoseSamples shouldSyncBloodGlucoseSamples: Bool, shouldSyncWorkoutSamples: Bool)
    {
        if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
            if #available(iOS 9.0, *) {
                if (shouldSyncBloodGlucoseSamples) {
                    HealthKitManager.sharedInstance.startObservingBloodGlucoseSamples() {
                        (newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?, error: NSError?) in
                        
                        if (newSamples != nil) {
                            NSLog("********* PROCESSING \(newSamples!.count) new blood glucose samples ********* ")
                        }
                        
                        if (deletedSamples != nil) {
                            NSLog("********* PROCESSING \(deletedSamples!.count) deleted blood glucose samples ********* ")
                        }
                        
                        self.writeSamples(newSamples: newSamples, deletedSamples: deletedSamples, error: error)
                        
                        self.updateLastSyncBloodGlucoseSamples(newSamples: newSamples, deletedSamples: deletedSamples)
                    }
                    HealthKitManager.sharedInstance.enableBackgroundDeliveryBloodGlucoseSamples()
                }
                if (shouldSyncWorkoutSamples) {
                    HealthKitManager.sharedInstance.startObservingWorkoutSamples() {
                        (newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?, error: NSError?) in

                        if (newSamples != nil) {
                            NSLog("********* PROCESSING \(newSamples!.count) new workout samples ********* ")
                        }
                        
                        if (deletedSamples != nil) {
                            NSLog("********* PROCESSING \(deletedSamples!.count) deleted workout samples ********* ")
                        }

                        self.writeSamples(newSamples: newSamples, deletedSamples: deletedSamples, error: error)
                        
                        self.updateLastSyncWorkoutSamples(newSamples: newSamples, deletedSamples: deletedSamples)
                    }
                    HealthKitManager.sharedInstance.enableBackgroundDeliveryWorkoutSamples()
                }
            }
        }
    }
    
    func stopSyncing(shouldStopSyncingBloodGlucoseSamples shouldStopSyncingBloodGlucoseSamples: Bool, shouldStopSyncingWorkoutSamples: Bool) {
        if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
            if #available(iOS 9.0, *) {
                if (shouldStopSyncingBloodGlucoseSamples) {
                    HealthKitManager.sharedInstance.stopObservingBloodGlucoseSamples()
                    HealthKitManager.sharedInstance.disableBackgroundDeliveryBloodGlucoseSamples()
                }
                if (shouldStopSyncingWorkoutSamples) {
                    HealthKitManager.sharedInstance.stopObservingWorkoutSamples()
                    HealthKitManager.sharedInstance.disableBackgroundDeliveryWorkoutSamples()
                }
            }
        }
    }
    
    // MARK: Private
    
    @available(iOS 9, *)
    private func writeSamples(newSamples newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?, error: NSError?) {
        guard error == nil else {
            NSLog("\(__FUNCTION__): Error processing samples \(error), \(error!.userInfo)")
            return
        }
        
        if (newSamples != nil) {
            writeNewSamples(newSamples!)
        }
        
        if (deletedSamples != nil) {
            writeDeletedSamples(deletedSamples!)
        }
    }
    
    @available(iOS 9, *)
    private func writeNewSamples(samples: [HKSample]) {
        do {
            let realm = try Realm()

            realm.beginWrite()
            
            for sample in samples {
                let healthKitData = HealthKitData()
                healthKitData.id = sample.UUID.UUIDString
                healthKitData.action = HealthKitData.Action.Added.rawValue
                
                let serializer = OMHSerializer()
                healthKitData.granolaJson = try serializer.jsonForSample(sample)
                
                NSLog("Granola sample: \(healthKitData.granolaJson)");

                // TODO: my - Confirm that composite key of id + action does not exist before attempting to add to avoid dups?
                realm.add(healthKitData)
            }
            
            try realm.commitWrite()
        } catch let error as NSError! {
            NSLog("\(__FUNCTION__): Error writing new samples \(error), \(error!.userInfo)")
        }
    }
    
    @available(iOS 9, *)
    private func writeDeletedSamples(deletedSamples: [HKDeletedObject]) {
        do {
            let realm = try Realm()
            
            try realm.write() {
                for sample in deletedSamples {
                    let healthKitData = HealthKitData()
                    healthKitData.id = sample.UUID.UUIDString
                    healthKitData.action = HealthKitData.Action.Deleted.rawValue
                    healthKitData.granolaJson = ""

                    NSLog("Deleted sample: \(healthKitData.id)");

                    // TODO: my - Confirm that composite key of id + action does not exist before attempting to add to avoid dups?
                    realm.add(healthKitData)
                }
            }
        } catch let error as NSError! {
            NSLog("\(__FUNCTION__): Error writing deleted samples \(error), \(error.userInfo)")
        }
    }
    
    @available(iOS 9, *)
    private func updateLastSyncBloodGlucoseSamples(newSamples newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?) {
        var totalCount = 0
        if (newSamples != nil) {
            totalCount += newSamples!.count
        }
        if (deletedSamples != nil) {
            totalCount += deletedSamples!.count
        }
        if (totalCount > 0) {
            lastSyncCountBloodGlucoseSamples = totalCount
            lastSyncTimeBloodGlucoseSamples = NSDate()
            NSUserDefaults.standardUserDefaults().setObject(lastSyncTimeBloodGlucoseSamples, forKey: "lastSyncTimeBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().setInteger(lastSyncCountBloodGlucoseSamples, forKey: "lastSyncCountBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: self.observedBloodGlucoseSamplesNotification, object: nil))
            }
        }
    }
    
    @available(iOS 9, *)
    private func updateLastSyncWorkoutSamples(newSamples newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?) {
        var totalCount = 0
        if (newSamples != nil) {
            totalCount += newSamples!.count
        }
        if (deletedSamples != nil) {
            totalCount += deletedSamples!.count
        }
        if (totalCount > 0) {
            lastSyncCountWorkoutSamples = totalCount
            lastSyncTimeWorkoutSamples = NSDate()
            NSUserDefaults.standardUserDefaults().setObject(lastSyncTimeWorkoutSamples, forKey: "lastSyncTimeWorkoutSamples")
            NSUserDefaults.standardUserDefaults().setInteger(lastSyncCountWorkoutSamples, forKey: "lastSyncCountWorkoutSamples")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: self.observedWorkoutSamplesNotification, object: nil))
            }
        }
    }
}
