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
import Granola

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

        var syncTime = NSUserDefaults.standardUserDefaults().objectForKey("lastDbSyncTimeBloodGlucoseSamples")
        if (syncTime != nil) {
            lastDbSyncTimeBloodGlucoseSamples = syncTime as! NSDate
            lastDbSyncCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("lastDbSyncCountBloodGlucoseSamples")
            totalDbSyncCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalDbSyncCountBloodGlucoseSamples")
        }
        
        syncTime = NSUserDefaults.standardUserDefaults().objectForKey("lastDbSyncTimeWorkoutSamples")
        if (syncTime != nil) {
            lastDbSyncTimeWorkoutSamples = syncTime as! NSDate
            lastDbSyncCountWorkoutSamples = NSUserDefaults.standardUserDefaults().integerForKey("lastDbSyncCountWorkoutSamples")
            totalDbSyncCountWorkoutSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalDbSyncCountWorkoutSamples")
        }
    }
    
    private(set) var totalDbSyncCountBloodGlucoseSamples = -1
    private(set) var lastDbSyncCountBloodGlucoseSamples = -1
    private(set) var lastDbSyncTimeBloodGlucoseSamples = NSDate.distantPast()

    private(set) var totalDbSyncCountWorkoutSamples = -1
    private(set) var lastDbSyncCountWorkoutSamples = -1
    private(set) var lastDbSyncTimeWorkoutSamples = NSDate.distantPast()
    
    var totalDbSyncCount: Int {
        get {
            var count = 0
            if (lastDbSyncCountBloodGlucoseSamples > 0) {
                count += lastDbSyncCountBloodGlucoseSamples
            }
            if (lastDbSyncCountWorkoutSamples > 0) {
                count += lastDbSyncCountWorkoutSamples
            }
            return count
        }
    }
    
    var lastDbSyncCount: Int {
        get {
            let time = lastDbSyncTime
            var count = 0
            if (lastDbSyncCountBloodGlucoseSamples > 0 && fabs(lastDbSyncTimeBloodGlucoseSamples.timeIntervalSinceDate(time)) < 60) {
                count += lastDbSyncCountBloodGlucoseSamples
            }
            if (lastDbSyncCountWorkoutSamples > 0 && fabs(lastDbSyncTimeWorkoutSamples.timeIntervalSinceDate(time)) < 60) {
                count += lastDbSyncCountWorkoutSamples
            }
            return count
        }
    }
    
    var lastDbSyncTime: NSDate {
        get {
            var time = NSDate.distantPast()
            if (lastDbSyncCountBloodGlucoseSamples > 0 && time.compare(lastDbSyncTimeBloodGlucoseSamples) == .OrderedAscending) {
                time = lastDbSyncTimeBloodGlucoseSamples
            }
            if (lastDbSyncCountWorkoutSamples > 0 && time.compare(lastDbSyncTimeWorkoutSamples) == .OrderedAscending) {
                time = lastDbSyncTimeWorkoutSamples
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
                    
                    self.writeSamplesToDb(newSamples: newSamples, deletedSamples: deletedSamples, error: error)
                    
                    self.updateLastDbSyncBloodGlucoseSamples(newSamples: newSamples, deletedSamples: deletedSamples)
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

                    self.writeSamplesToDb(newSamples: newSamples, deletedSamples: deletedSamples, error: error)
                    
                    self.updateLastDbSyncWorkoutSamples(newSamples: newSamples, deletedSamples: deletedSamples)
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
    
    private func writeSamplesToDb(newSamples newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?, error: NSError?) {
        guard error == nil else {
            DDLogError("Error processing samples \(error), \(error!.userInfo)")
            return
        }
        
        if (newSamples != nil) {
            writeNewSamplesToDb(newSamples!)
        }
        
        if (deletedSamples != nil) {
            writeDeletedSamplesToDb(deletedSamples!)
        }
    }
    
    private func writeNewSamplesToDb(samples: [HKSample]) {
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
    
    private func writeDeletedSamplesToDb(deletedSamples: [HKDeletedObject]) {
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
    
    private func updateLastDbSyncBloodGlucoseSamples(newSamples newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?) {
        var totalCount = 0
        if (newSamples != nil) {
            totalCount += newSamples!.count
        }
        if (deletedSamples != nil) {
            totalCount += deletedSamples!.count
        }
        if (totalCount > 0) {
            lastDbSyncCountBloodGlucoseSamples = totalCount
            lastDbSyncTimeBloodGlucoseSamples = NSDate()
            NSUserDefaults.standardUserDefaults().setObject(lastDbSyncTimeBloodGlucoseSamples, forKey: "lastDbSyncTimeBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().setInteger(lastDbSyncCountBloodGlucoseSamples, forKey: "lastDbSyncCountBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().setObject(lastDbSyncTimeBloodGlucoseSamples, forKey: "lastDbSyncTimeBloodGlucoseSamples")
            let totalDbSyncCountBloodGlucoseSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalDbSyncCountBloodGlucoseSamples") + lastDbSyncCountBloodGlucoseSamples
            NSUserDefaults.standardUserDefaults().setObject(totalDbSyncCountBloodGlucoseSamples, forKey: "totalDbSyncCountBloodGlucoseSamples")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.ObservedBloodGlucoseSamples, object: nil))
            }
        }
    }
    
    private func updateLastDbSyncWorkoutSamples(newSamples newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?) {
        var totalCount = 0
        if (newSamples != nil) {
            totalCount += newSamples!.count
        }
        if (deletedSamples != nil) {
            totalCount += deletedSamples!.count
        }
        if (totalCount > 0) {
            lastDbSyncCountWorkoutSamples = totalCount
            lastDbSyncTimeWorkoutSamples = NSDate()
            NSUserDefaults.standardUserDefaults().setObject(lastDbSyncTimeWorkoutSamples, forKey: "lastDbSyncTimeWorkoutSamples")
            NSUserDefaults.standardUserDefaults().setInteger(lastDbSyncCountWorkoutSamples, forKey: "lastDbSyncCountWorkoutSamples")
            let totalDbSyncCountWorkoutSamples = NSUserDefaults.standardUserDefaults().integerForKey("totalDbSyncCountWorkoutSamples") + lastDbSyncCountBloodGlucoseSamples
            NSUserDefaults.standardUserDefaults().setObject(totalDbSyncCountWorkoutSamples, forKey: "totalDbSyncCountWorkoutSamples")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Notifications.ObservedWorkoutSamples, object: nil))
            }
        }
    }
}
