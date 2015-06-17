//
//  PatientData.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class PatientData {
    
    var patientid: String
    var health: Health
    var demographic: Demographic
    
    init(patientid: String, health: Health, demographic: Demographic) {
        self.patientid = patientid
        self.health = health
        self.demographic = demographic
    }
    
}