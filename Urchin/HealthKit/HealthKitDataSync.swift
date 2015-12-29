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
    }
 
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
                if (shouldStopSyncingBloodGlucoseSamples) {
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
                let granolaData = GranolaData()
                granolaData.id = sample.UUID.UUIDString
                granolaData.action = GranolaData.Action.Added.rawValue
                granolaData.createdAt = NSDate()
                
                let serializer = OMHSerializer()
                granolaData.granolaJson = try serializer.jsonForSample(sample)
                
                NSLog("Granola sample: \(granolaData.granolaJson)");

                // TODO: my - Confirm that composite key of id + action does not exist before attempting to add to avoid dups?
                realm.add(granolaData)
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
                    let granolaData = GranolaData()
                    granolaData.id = sample.UUID.UUIDString
                    granolaData.action = GranolaData.Action.Deleted.rawValue
                    granolaData.createdAt = NSDate()
                    granolaData.granolaJson = ""

                    NSLog("Deleted sample: \(granolaData.id)");

                    // TODO: my - Confirm that composite key of id + action does not exist before attempting to add to avoid dups?
                    realm.add(granolaData)
                }
            }
        } catch let error as NSError! {
            NSLog("\(__FUNCTION__): Error writing deleted samples \(error), \(error.userInfo)")
        }
    }
}
