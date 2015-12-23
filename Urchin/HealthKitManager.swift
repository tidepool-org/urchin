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

class HealthKitManager {
    static let sharedInstance = HealthKitManager()
    private init() {}
    
    let healthStore: HKHealthStore? = {
        return HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    }()
    
    let isHealthDataAvailable: Bool = {
        // NOTE: For now we are relying on iOS 9 HealthKit support for better anchor query support, etc, but, Blip Notes
        // still supports pre-9.0, hence this check. At the time of this writing iOS 9 adoption is 80%, iOS 8 is 15%, and
        // pre-iOS 8 is 5%: https://mixpanel.com/trends/#report/ios_9
        if #available(iOS 9.0, *) {
            return HKHealthStore.isHealthDataAvailable()
        } else {
            return false;
        }
    }()
    
    func authorize(shouldAuthorizeBloodGlucoseSamples shouldAuthorizeBloodGlucoseSamples: Bool, shouldAuthorizeWorkoutSamples: Bool, completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        guard #available(iOS 9, *) else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call for pre-iOS 9")
            return
        }
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }
        
        var readTypes = Set<HKSampleType>()
        if (shouldAuthorizeBloodGlucoseSamples) {
            readTypes.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!)
        }
        if (shouldAuthorizeWorkoutSamples) {
            readTypes.insert(HKObjectType.workoutType())
        }
        guard readTypes.count > 0 else {
            NSLog("\(__FUNCTION__): No health data authorization requested, ignoring")
            return
        }
        
        if (isHealthDataAvailable) {
            healthStore!.requestAuthorizationToShareTypes(nil, readTypes: readTypes) { (success, error) -> Void in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "requestedHealthKitAuthorization");
                NSUserDefaults.standardUserDefaults().synchronize()
                if (completion != nil) {
                    completion(success:success, error:error)
                }
            }
        } else {
            let error = NSError(
                            domain: "HealthKitManager",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available on this device"])
            if (completion != nil) {
                completion(success:false, error:error)
            }
        }
    }
    
    func observeBloodGlucoseSamples(completion: ((success:Bool, error:NSError!) -> Void)!) {
        guard #available(iOS 9, *) else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call for pre-iOS 9")
            return
        }
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }

        if (!bloodGlucoseObservationSuccessful) {
            if (bloodGlucoseObservationQuery != nil) {
                healthStore?.stopQuery(bloodGlucoseObservationQuery!)
            }
            
            let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!
            bloodGlucoseObservationQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) {
                [unowned self](query, observerQueryCompletion, error) in
                if error == nil {
                    self.bloodGlucoseObservationSuccessful = true
                    self.readBloodGlucoseSamples()
                } else {
                    NSLog("\(__FUNCTION__): HealthKit observation error \(error), \(error!.userInfo)")
                }

                if (completion != nil) {
                    completion(success:error == nil, error:error)
                }

                observerQueryCompletion()
            }
            healthStore?.executeQuery(bloodGlucoseObservationQuery!)
        } else {
            if (completion != nil) {
                completion(success:true, error:nil)
            }
        }
    }
    
    func enableBackgroundDeliveryBloodGlucoseSamples(completion: ((success:Bool, error:NSError!) -> Void)!) {
        guard #available(iOS 9, *) else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call for pre-iOS 9")
            return
        }
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }

        if (!bloodGlucoseBackgroundDeliveryEnabled) {
            bloodGlucoseBackgroundDeliveryEnabled = true
            
            healthStore?.enableBackgroundDeliveryForType(
                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!,
                frequency: HKUpdateFrequency.Immediate) {
                    success, error -> Void in
                    if (error == nil) {
                        NSLog("\(__FUNCTION__): Enabled background delivery of health data")
                    } else {
                        NSLog("\(__FUNCTION__): Error enabling background delivery of health data \(error), \(error!.userInfo)")
                    }
                    
                    if (completion != nil) {
                        completion(success:success, error:error)
                    }
                }
        } else {
            if (completion != nil) {
                completion(success:true, error:nil)
            }
        }
    }
    
    func observeWorkoutSamples(completion: ((success:Bool, error:NSError!) -> Void)!) {
        guard #available(iOS 9, *) else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call for pre-iOS 9")
            return
        }
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }
        
        if (!workoutsObservationSuccessful) {
            if (workoutsObservationQuery != nil) {
                healthStore?.stopQuery(workoutsObservationQuery!)
            }
            
            let sampleType = HKObjectType.workoutType()
            workoutsObservationQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) {
                [unowned self](query, observerQueryCompletion, error) in
                if error == nil {
                    self.workoutsObservationSuccessful = true
                    self.readWorkoutSamples()
                } else {
                    NSLog("\(__FUNCTION__): HealthKit observation error \(error), \(error!.userInfo)")
                }
                
                if (completion != nil) {
                    completion(success:error == nil, error:error)
                }
                
                observerQueryCompletion()
            }
            healthStore?.executeQuery(workoutsObservationQuery!)
        } else {
            if (completion != nil) {
                completion(success:true, error:nil)
            }
        }
    }
    
    func enableBackgroundDeliveryWorkoutSamples(completion: ((success:Bool, error:NSError!) -> Void)!) {
        guard #available(iOS 9, *) else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call for pre-iOS 9")
            return
        }
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }
        
        if (!workoutsBackgroundDeliveryEnabled) {
            workoutsBackgroundDeliveryEnabled = true
            
            healthStore?.enableBackgroundDeliveryForType(
                HKObjectType.workoutType(),
                frequency: HKUpdateFrequency.Immediate) {
                    success, error -> Void in
                    if (error == nil) {
                        NSLog("\(__FUNCTION__): Enabled background delivery of health data")
                    } else {
                        NSLog("\(__FUNCTION__): Error enabling background delivery of health data \(error), \(error!.userInfo)")
                    }
                    
                    if (completion != nil) {
                        completion(success:success, error:error)
                    }
            }
        } else {
            if (completion != nil) {
                completion(success:true, error:nil)
            }
        }
    }
    
    @available(iOS 9, *)
    private func readBloodGlucoseSamples()
    {
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }
        
        var queryAnchor: HKQueryAnchor?
        let queryAnchorData = NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseQueryAnchor")
        if (queryAnchorData != nil) {
            queryAnchor = NSKeyedUnarchiver.unarchiveObjectWithData(queryAnchorData as! NSData) as? HKQueryAnchor
        }
        
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!
        let sampleQuery = HKAnchoredObjectQuery(type: sampleType,
            predicate: nil,
            anchor: queryAnchor,
            limit: Int(HKObjectQueryNoLimit)) {
                [unowned self](query, newSamples, deletedSamples, newAnchor, error) -> Void in
                
                if (newAnchor != nil) {
                    let queryAnchorData = NSKeyedArchiver.archivedDataWithRootObject(newAnchor!)
                    NSUserDefaults.standardUserDefaults().setObject(queryAnchorData, forKey: "bloodGlucoseQueryAnchor")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }

                self.processNewBloodGlucoseSamples(newSamples)
                self.processDeletedBloodGlucoseSamples(deletedSamples)
            }
        healthStore?.executeQuery(sampleQuery)
    }
    
    @available(iOS 9, *)
    private func readWorkoutSamples()
    {
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }
        
        var queryAnchor: HKQueryAnchor?
        let queryAnchorData = NSUserDefaults.standardUserDefaults().objectForKey("workoutQueryAnchor")
        if (queryAnchorData != nil) {
            queryAnchor = NSKeyedUnarchiver.unarchiveObjectWithData(queryAnchorData as! NSData) as? HKQueryAnchor
        }
        
        let sampleType = HKObjectType.workoutType()
        let sampleQuery = HKAnchoredObjectQuery(type: sampleType,
            predicate: nil,
            anchor: queryAnchor,
            limit: Int(HKObjectQueryNoLimit)) {
                [unowned self](query, newSamples, deletedSamples, newAnchor, error) -> Void in
                
                if (newAnchor != nil) {
                    let queryAnchorData = NSKeyedArchiver.archivedDataWithRootObject(newAnchor!)
                    NSUserDefaults.standardUserDefaults().setObject(queryAnchorData, forKey: "workoutQueryAnchor")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                self.processNewWorkoutSamples(newSamples)
                self.processDeletedWorkoutSamples(deletedSamples)
        }
        healthStore?.executeQuery(sampleQuery)
    }
    
    @available(iOS 9, *)
    private func processNewBloodGlucoseSamples(samples: [HKSample]?) {
        guard samples != nil else {
            return
        }
        
        let samples = samples!
        NSLog("********* PROCESSING \(samples.count) new glucose samples ********* ")
        let serializer = OMHSerializer()
        for sample in samples {
            let jsonString = try! serializer.jsonForSample(sample)
            NSLog("Granola serialized glucose sample: \(jsonString)");
        }
    }
    
    @available(iOS 9, *)
    private func processDeletedBloodGlucoseSamples(samples: [HKDeletedObject]?) {
        guard samples != nil else {
            return
        }
        
        let samples = samples!
        NSLog("********* PROCESSING \(samples.count) deleted glucose samples ********* ")
        for sample in samples {
            NSLog("Processed deleted glucose sample with UUID: \(sample.UUID)");
        }
    }
    
    @available(iOS 9, *)
    private func processNewWorkoutSamples(samples: [HKSample]?) {
        guard samples != nil else {
            return
        }
        
        let samples = samples!
        NSLog("********* PROCESSING \(samples.count) new workout samples ********* ")
        let serializer = OMHSerializer()
        for sample in samples {
            let jsonString = try! serializer.jsonForSample(sample)
            NSLog("Granola serialized workout sample: \(jsonString)");
        }
    }
    
    @available(iOS 9, *)
    private func processDeletedWorkoutSamples(samples: [HKDeletedObject]?) {
        guard samples != nil else {
            return
        }
        
        let samples = samples!
        NSLog("********* PROCESSING \(samples.count) deleted workout samples ********* ")
        for sample in samples {
            NSLog("Processed deleted workout sample with UUID: \(sample.UUID)");
        }
    }
    
    private var bloodGlucoseObservationSuccessful = false
    private var bloodGlucoseObservationQuery: HKObserverQuery?
    private var bloodGlucoseBackgroundDeliveryEnabled = false
    private var bloodGlucoseQueryAnchor = Int(HKAnchoredObjectQueryNoAnchor)

    private var workoutsObservationSuccessful = false
    private var workoutsObservationQuery: HKObserverQuery?
    private var workoutsBackgroundDeliveryEnabled = false
    private var workoutsQueryAnchor = Int(HKAnchoredObjectQueryNoAnchor)
}
