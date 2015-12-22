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
    
    func authorize(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        guard #available(iOS 9, *) else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call for pre-iOS 9")
            return
        }
        guard isHealthDataAvailable else {
            NSLog("\(__FUNCTION__): Unexpected HealthKitManager call when health data not available")
            return
        }
        
        let readTypes = Set(arrayLiteral:
                                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!,
                                HKObjectType.workoutType())
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
    
    func observe(completion: ((success:Bool, error:NSError!) -> Void)!) {
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
                    NSLog("HealthKit observation error \(error), \(error!.userInfo)")
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
    
    func enableBackgroundDelivery(completion: ((success:Bool, error:NSError!) -> Void)!) {
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
                        NSLog("Enabled background delivery of health data")
                    } else {
                        NSLog("Error enabling background delivery of health data \(error), \(error!.userInfo)")
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
        
        var bloodGlucoseQueryAnchor: HKQueryAnchor?
        let bloodGlucoseQueryAnchorData = NSUserDefaults.standardUserDefaults().objectForKey("bloodGlucoseQueryAnchor")
        if (bloodGlucoseQueryAnchorData != nil) {
            bloodGlucoseQueryAnchor = NSKeyedUnarchiver.unarchiveObjectWithData(bloodGlucoseQueryAnchorData as! NSData) as? HKQueryAnchor
        }
        
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!
        let sampleQuery = HKAnchoredObjectQuery(type: sampleType,
            predicate: nil,
            anchor: bloodGlucoseQueryAnchor,
            limit: Int(HKObjectQueryNoLimit)) {
                [unowned self](query, newSamples, deletedSamples, newAnchor, error) -> Void in
                
                guard let samples = newSamples as? [HKQuantitySample], let deleted = deletedSamples else {
                    print("Unexpectedly unable to query for glucose samples from anchored object query: \(error?.localizedDescription)")
                    return
                }

                if (newAnchor != nil) {
                    let bloodGlucoseQueryAnchorData = NSKeyedArchiver.archivedDataWithRootObject(newAnchor!)
                    NSUserDefaults.standardUserDefaults().setObject(bloodGlucoseQueryAnchorData, forKey: "bloodGlucoseQueryAnchor")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }

                self.processNewBloodGlucoseSamples(samples)
                self.processDeletedBloodGlucoseSample(deleted)
            }
        healthStore?.executeQuery(sampleQuery)
    }
    
    @available(iOS 9, *)
    private func processNewBloodGlucoseSamples(samples: [HKQuantitySample]) {
        NSLog("********* PROCESSING \(samples.count) new samples ********* ")
        let serializer = OMHSerializer()
        for sample in samples {
            let jsonString = try! serializer.jsonForSample(sample)
            NSLog("Granola serialized sample: \(jsonString)");
        }
    }
    
    @available(iOS 9, *)
    private func processDeletedBloodGlucoseSample(samples: [HKDeletedObject]) {
        NSLog("********* PROCESSING \(samples.count) deleted samples ********* ")
        for sample in samples {
            NSLog("Processed deleted sample with UUID: \(sample.UUID)");
        }
    }
    
    private var bloodGlucoseObservationSuccessful = false
    private var bloodGlucoseObservationQuery: HKObserverQuery?
    private var bloodGlucoseBackgroundDeliveryEnabled = false
    private var bloodGlucoseQueryAnchor = Int(HKAnchoredObjectQueryNoAnchor)
}
