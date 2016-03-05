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
import CocoaLumberjack

// TODO: my - Need to set up a periodic task to perodically drain the Realm db and upload those events to service, this should be able to be done as background task even when app is not active, and periodically when active

class HealthKitDataSync {
    // MARK: Access, authorization
    
    static let sharedInstance = HealthKitDataSync()
    private init() {
        var config = Realm.Configuration(
            schemaVersion: 1,

            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically

                    DDLogInfo("Migrating Realm from 0 to 1")
                }
            }
        )
        
        // Append nosync to avoid iCloud backup of realm db
        config.path = NSURL.fileURLWithPath(config.path!)
            .URLByAppendingPathExtension("nosync")
            .path
        
        DDLogInfo("Realm path: \(config.path)")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config

        var syncTime = NSUserDefaults.standardUserDefaults().objectForKey("lastSyncTimeBloodGlucoseSamples")
        if (syncTime != nil) {
            lastSyncTimeBloodGlucoseSamples = syncTime as! NSDate
            lastSyncCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("lastSyncCountBloodGlucoseSamples")
            totalSyncCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalSyncCountBloodGlucoseSamples")
        }
        
        syncTime = NSUserDefaults.standardUserDefaults().objectForKey("lastSyncTimeWorkoutSamples")
        if (syncTime != nil) {
            lastSyncTimeWorkoutSamples = syncTime as! NSDate
            lastSyncCountWorkoutSamples = NSUserDefaults.standardUserDefaults().integerForKey("lastSyncCountWorkoutSamples")
            totalSyncCountWorkoutSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalSyncCountWorkoutSamples")
        }
    }
    
    private(set) var totalSyncCountBloodGlucoseSamples = -1
    private(set) var lastSyncCountBloodGlucoseSamples = -1
    private(set) var lastSyncTimeBloodGlucoseSamples = NSDate.distantPast()

    private(set) var totalSyncCountWorkoutSamples = -1
    private(set) var lastSyncCountWorkoutSamples = -1
    private(set) var lastSyncTimeWorkoutSamples = NSDate.distantPast()
    
    var totalSyncCount: Int {
        get {
            var count = 0
            if (lastSyncCountBloodGlucoseSamples > 0) {
                count += lastSyncCountBloodGlucoseSamples
            }
            if (lastSyncCountWorkoutSamples > 0) {
                count += lastSyncCountWorkoutSamples
            }
            return count
        }
    }
    
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
    
    enum Notifications {
        static let ObservedBloodGlucoseSamples = "HealthKitDataSync-observed-\(HKWorkoutTypeIdentifier)"
        static let ObservedWorkoutSamples = "HealthKitDataSync-observed-\(HKWorkoutTypeIdentifier)"
    }

    func authorizeAndStartSyncing(
            shouldSyncBloodGlucoseSamples shouldSyncBloodGlucoseSamples: Bool,
            shouldSyncWorkoutSamples: Bool)
    {
        HealthKitManager.sharedInstance.authorize(
            shouldAuthorizeBloodGlucoseSamples: shouldSyncBloodGlucoseSamples,
            shouldAuthorizeWorkoutSamples: shouldSyncWorkoutSamples) {
            success, error -> Void in
            if (error == nil) {
                self.startSyncing(
                    shouldSyncBloodGlucoseSamples: shouldSyncBloodGlucoseSamples,
                    shouldSyncWorkoutSamples: shouldSyncWorkoutSamples)
            } else {
                DDLogError("Error authorizing health data \(error), \(error!.userInfo)")
            }
        }
    }
    
    // MARK: Sync control
    
    func startSyncing(shouldSyncBloodGlucoseSamples shouldSyncBloodGlucoseSamples: Bool, shouldSyncWorkoutSamples: Bool)
    {
        if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
            if (shouldSyncBloodGlucoseSamples) {
                HealthKitManager.sharedInstance.startObservingBloodGlucoseSamples() {
                    (newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?, error: NSError?) in
                    
                    if (newSamples != nil) {
                        DDLogInfo("********* PROCESSING \(newSamples!.count) new blood glucose samples ********* ")
                    }
                    
                    if (deletedSamples != nil) {
                        DDLogInfo("********* PROCESSING \(deletedSamples!.count) deleted blood glucose samples ********* ")
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
                        DDLogInfo("********* PROCESSING \(newSamples!.count) new workout samples ********* ")
                    }
                    
                    if (deletedSamples != nil) {
                        DDLogInfo("********* PROCESSING \(deletedSamples!.count) deleted workout samples ********* ")
                    }

                    self.writeSamples(newSamples: newSamples, deletedSamples: deletedSamples, error: error)
                    
                    self.updateLastSyncWorkoutSamples(newSamples: newSamples, deletedSamples: deletedSamples)
                }
                HealthKitManager.sharedInstance.enableBackgroundDeliveryWorkoutSamples()
            }
        }
    }
    
    func stopSyncing(shouldStopSyncingBloodGlucoseSamples shouldStopSyncingBloodGlucoseSamples: Bool, shouldStopSyncingWorkoutSamples: Bool) {
        if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
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
    
    // MARK: Private
    
    private func writeSamples(newSamples newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?, error: NSError?) {
        guard error == nil else {
            DDLogError("Error processing samples \(error), \(error!.userInfo)")
            return
        }
        
        if (newSamples != nil) {
            writeNewSamples(newSamples!)
        }
        
        if (deletedSamples != nil) {
            writeDeletedSamples(deletedSamples!)
        }
    }
    
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
                
                DDLogInfo("Granola sample: \(healthKitData.granolaJson)");

                // TODO: my - Confirm that composite key of id + action does not exist before attempting to add to avoid dups?
                realm.add(healthKitData)
            }
            
            try realm.commitWrite()
        } catch let error as NSError! {
            DDLogError("Error writing new samples \(error), \(error!.userInfo)")
        }
    }
    
    private func writeDeletedSamples(deletedSamples: [HKDeletedObject]) {
        do {
            let realm = try Realm()
            
            try realm.write() {
                for sample in deletedSamples {
                    let healthKitData = HealthKitData()
                    healthKitData.id = sample.UUID.UUIDString
                    healthKitData.action = HealthKitData.Action.Deleted.rawValue
                    healthKitData.granolaJson = ""

                    DDLogInfo("Deleted sample: \(healthKitData.id)");

                    // TODO: my - Confirm that composite key of id + action does not exist before attempting to add to avoid dups?
                    realm.add(healthKitData)
                }
            }
        } catch let error as NSError! {
            DDLogError("Error writing deleted samples \(error), \(error.userInfo)")
        }
    }
    
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
            NSUserDefaults.standardUserDefaults().setObject(lastSyncTimeBloodGlucoseSamples, forKey: "lastSyncTimeBloodGlucoseSamples")
            let totalSyncCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalSyncCountBloodGlucoseSamples") + lastSyncCountBloodGlucoseSamples
            NSUserDefaults.standardUserDefaults().setObject(totalSyncCountBloodGlucoseSamples, forKey: "totalSyncCountBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.ObservedBloodGlucoseSamples, object: nil))
            }
        }
    }
    
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
            let totalSyncCountWorkoutSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalSyncCountWorkoutSamples") + lastSyncCountBloodGlucoseSamples
            NSUserDefaults.standardUserDefaults().setObject(totalSyncCountWorkoutSamples, forKey: "totalSyncCountWorkoutSamples")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.ObservedWorkoutSamples, object: nil))
            }
        }
    }
}
