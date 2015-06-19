//
//  Note.swift
//  urchin
//
//  Created by Ethan Look on 6/17/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Note {
    
    let id: String
    let userid: String
    let groupid: String
    let timestamp: NSDate
    let createdtime: NSDate
    let messagetext: String
    let user: User
    
    init(id: String, userid: String, groupid: String, timestamp: NSDate, createdtime: NSDate, messagetext: String, user: User) {
        self.id = id
        self.userid = userid
        self.groupid = groupid
        self.timestamp = timestamp
        self.createdtime = createdtime
        self.messagetext = messagetext
        self.user = user
    }
    
}