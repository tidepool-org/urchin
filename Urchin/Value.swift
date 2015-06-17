//
//  Value.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Value {
    
    var profile: Profile
    var groups: Groups
    var patientData: PatientData
    
    init(profile: Profile, groups: Groups, patientData: PatientData) {
        self.profile = profile
        self.groups = groups
        self.patientData = patientData
    }
    
}