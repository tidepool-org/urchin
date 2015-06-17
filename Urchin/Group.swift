//
//  Group.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Group {
    
    var groupid: String
    var members: [User]
    
    init(groupid: String, members: [User]) {
        self.groupid = groupid
        self.members = members
    }
    
}