//
//  Patient.swift
//  urchin
//
//  Created by Ethan Look on 6/19/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Patient {
    
    var birthday: NSDate
    var diagnosisDate: NSDate
    var aboutMe: String
    
    init(birthday: NSDate, diagnosisDate: NSDate, aboutMe: String) {
        self.birthday = birthday
        self.diagnosisDate = diagnosisDate
        self.aboutMe = aboutMe
    }
    
}