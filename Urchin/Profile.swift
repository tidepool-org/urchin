//
//  Profile.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Profile {
    
    var fullname: String
    var shortname: String
    var publicbio: String
    
    init(fullname: String, shortname: String, publicbio: String) {
        self.fullname = fullname
        self.shortname = shortname
        self.publicbio = publicbio
    }
    
}