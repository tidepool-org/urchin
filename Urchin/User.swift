//
//  User.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class User {
    
    let firstName: String
    let lastName: String
    let fullName: String
    let shortName: String
    let patient: Patient
    
    init(firstName: String, lastName: String, patient: Patient) {
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = firstName + " " + lastName
        self.shortName = firstName
        self.patient = patient
    }
}