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
        return HKHealthStore.isHealthDataAvailable()
    }()
    
    func authorize(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        let readTypes = Set(arrayLiteral:
                                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!,
                                HKObjectType.workoutType())
        if (isHealthDataAvailable) {
            healthStore!.requestAuthorizationToShareTypes(nil, readTypes: readTypes) { (success, error) -> Void in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "requestedHealthKitAuthorization");
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
        if (!bloodGlucoseObservationSuccessful) {
            if (bloodGlucoseObservationQuery != nil) {
                healthStore?.stopQuery(bloodGlucoseObservationQuery!)
            }
            
            let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!
            bloodGlucoseObservationQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) {
                query, completionHandler, error in
                if error == nil {
                    self.bloodGlucoseObservationSuccessful = true
                    self.readMostRecentSample()

                } else {
                    NSLog("HealthKit observation error \(error), \(error!.userInfo)")
                }

                if (completion != nil) {
                    completion(success:error == nil, error:error)
                }

                completionHandler()
            }
            healthStore?.executeQuery(bloodGlucoseObservationQuery!)
        } else {
            if (completion != nil) {
                completion(success:true, error:nil)
            }
        }
    }
    
    func enableBackgroundDelivery(completion: ((success:Bool, error:NSError!) -> Void)!) {
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
    
    // TODO: my - 0 - Need to use HKAnchoredObjectQuery
    func readMostRecentSample()
    {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
        let past = NSDate.distantPast()
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        let sampleQuery = HKSampleQuery(
                                sampleType: sampleType!,
                                predicate: mostRecentPredicate,
                                limit: limit,
                                sortDescriptors: [sortDescriptor]) {                                    
            (sampleQuery, results, error ) -> Void in
            
            if (error != nil) {
                return;
            }
            
            // Get the first sample
            if let sample = results!.first as? HKQuantitySample {
                // create and use a serializer instance
                let serializer = OMHSerializer()
                let jsonString = try! serializer.jsonForSample(sample)
                NSLog("Granola sample: \(jsonString)");
            }
        }
        healthStore?.executeQuery(sampleQuery)
    }
    
    private var bloodGlucoseObservationSuccessful = false
    private var bloodGlucoseObservationQuery: HKObserverQuery?
    private var bloodGlucoseBackgroundDeliveryEnabled = false
}
