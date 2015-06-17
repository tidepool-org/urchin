//
//  User.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class User {
    
    var userid: String
    var username: String
    var userMetadata: UserMetadata
    
    init(userid: String, username: String, userMetadata: UserMetadata) {
        self.userid = userid
        self.username = username
        self.userMetadata = userMetadata
    }
    
}