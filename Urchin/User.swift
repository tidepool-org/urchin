/*
* Copyright (c) 2015, Tidepool Project
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the associated License, which is identical to the BSD 2-Clause
* License as published by the Open Source Initiative at opensource.org.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the License for more details.
*
* You should have received a copy of the License along with this program; if
* not, you can obtain one from Tidepool Project at tidepool.org.
*/

import Foundation

class User {
    
    var fullName: String?
    let userid: String
    var patient: Patient?
    
    init(userid: String, apiConnector: APIConnector, notesVC: NotesViewController?) {
        self.userid = userid
        
        apiConnector.findProfile(self, notesVC: notesVC)
    }
    
    init(userid: String) {
        self.userid = userid
    }
    
    /// Indicates whether the current user logged in is associated with a Data Storage Account
    var isDSAUser: Bool {
        return patient != nil
    }

    func processUserDict(userDict: NSDictionary) {
        if let name = userDict["fullName"] as? String {
            self.fullName = name
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.patient = Patient()
        
        if let patientDict = userDict["patient"] as? NSDictionary {
            if let birthdayString = patientDict["birthday"] as? String {
                self.patient!.birthday = dateFormatter.dateFromString(birthdayString)!
            }
            if let diagnosisString = patientDict["diagnosisDate"] as? String {
                self.patient!.diagnosisDate = dateFormatter.dateFromString(diagnosisString)!
            }
            if let aboutMe = patientDict["aboutMe"] as? String {
                self.patient!.aboutMe = aboutMe
            }
            if let aboutMe = patientDict["about"] as? String {
                self.patient!.aboutMe = aboutMe
            }
        }
    }
}