//
//  User.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class User {
    
    var fullName: String?
    let userid: String
    var patient: Patient?
    
    init(userid: String, apiConnector: APIConnector) {
        self.userid = userid
        
        apiConnector.findProfile(self)
    }
    
    init(userid: String) {
        self.userid = userid
    }
    
    func processUserDict(userDict: NSDictionary) {
        if let name = userDict["fullName"] as? String {
            self.fullName = name
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.patient = Patient()
        
        if let patientDict = userDict["patient"] as? NSDictionary {
            if let birthdayString = patientDict["birthday"] as? String {
                self.patient!.birthday = dateFormatter.dateFromString(birthdayString)!
            }
            if let diagnosisString = patientDict["diagnosisDate"] as? String {
                self.patient!.diagnosisDate = dateFormatter.dateFromString(diagnosisString)!
            }
            if let aboutMe = patientDict["aboutMe"] as? String {
                self.patient!.aboutMe = aboutMe
            }
            if let aboutMe = patientDict["about"] as? String {
                self.patient!.aboutMe = aboutMe
            }
        }
    }
}