//
//  UserMetadata.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class UserMetadata {
    
    var metaid: String
    var value: Value
    
    init(metaid: String, value: Value) {
        self.metaid = metaid
        self.value = value
    }
    
}