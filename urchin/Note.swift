//
//  Note.swift
//  urchin
//
//  Created by Ethan Look on 6/17/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Note {
    
    var id: String
    var userid: String
    var groupid: String
    var timestamp: NSDate
    var createdtime: NSDate
    var messagetext: String
    var user: User?
    
    init(id: String, userid: String, groupid: String, timestamp: NSDate, createdtime: NSDate, messagetext: String, user: User) {
        self.id = id
        self.userid = userid
        self.groupid = groupid
        self.timestamp = timestamp
        self.createdtime = createdtime
        self.messagetext = messagetext
        self.user = user
    }
    
    init() {
        self.id = ""
        self.userid = ""
        self.groupid = ""
        self.timestamp = NSDate()
        self.createdtime = NSDate()
        self.messagetext = ""
    }
    
    func dictionaryFromNote() -> [String: AnyObject] {
        let dateFormatter = NSDateFormatter()
        let dateFormatterTwo = NSDateFormatter()
        let patient: [String: AnyObject] = [
            "aboutMe": self.user!.patient!.aboutMe!,
            "birthday": dateFormatter.stringFromRegDate(self.user!.patient!.birthday!),
            "diagnosisDate": dateFormatter.stringFromRegDate(self.user!.patient!.diagnosisDate!)
        ]
        let userDict: [String: AnyObject] = [
            "fullName": self.user!.fullName!,
            "patient": patient
        ]
        let jsonObject: [String: AnyObject] = [
            "message": [
                "createdtime": dateFormatterTwo.isoStringFromDate(self.createdtime),
                "groupid": self.groupid,
                "guid": NSUUID().UUIDString,
                "messagetext": self.messagetext,
                "parentmessage": NSNull(),
                "timestamp": dateFormatterTwo.isoStringFromDate(self.timestamp),
                "user": userDict,
                "userid": self.userid
            ]
        ]
        return jsonObject
    }
}