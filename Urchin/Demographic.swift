//
//  Demographic.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Demographic {
    
    var birthdate: NSDate
    var zipcode: Int
    var gender: String
    
    init(birthdate: NSDate, zipcode: Int, gender: String) {
        self.birthdate = birthdate
        self.zipcode = zipcode
        self.gender = gender
    }
    
}