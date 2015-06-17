//
//  Groups.swift
//  Urchin
//
//  Created by Ethan Look on 6/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class Groups {
    
    var team: Group
    var uploaders: Group
    var viewers: Group
    var patients: Group
    var invited: Group
    var invitedby: Group
    
    init() {
        // Groups are optional
        team = Group(groupid: "team", members: [])
        uploaders = Group(groupid: "uploaders", members: [])
        viewers = Group(groupid: "viewers", members: [])
        patients = Group(groupid: "patients", members: [])
        invited = Group(groupid: "invited", members: [])
        invitedby = Group(groupid: "invitedby", members: [])
    }
    
}