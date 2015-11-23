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
import UIKit

extension EditNoteViewController: UIAlertViewDelegate {
    
    // Handle alert view events
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if (alertView.title == editAlertTitle && alertView.message == editAlertMessage) {
            switch buttonIndex {
            case 0:
                NSLog("Discard edits from note")
                
                let notification = NSNotification(name: "doneEditing", object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
                
                self.view.endEditing(true)
                self.closeDatePicker(false)
                self.dismissViewControllerAnimated(true, completion: nil)
                
                break
            case 1:
                NSLog("Save edited note")
                
                self.saveNote()
                
                break
            default:
                NSLog("Unknown case occurred with alert. Closing alert.")
                break
            }
        } else if (alertView.title == trashAlertTitle && alertView.message == trashAlertMessage) {
            switch buttonIndex {
            case 0:
                NSLog("Do not trash note")
            
                break
            case 1:
                NSLog("Trash note")
                
                // Done editing note
                let notification = NSNotification(name: "doneEditing", object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
                
                let notificationTwo = NSNotification(name: "deleteNote", object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notificationTwo)
                
                self.view.endEditing(true)
                self.closeDatePicker(false)
                self.dismissViewControllerAnimated(true, completion: nil)
                
                break
            default:
                NSLog("Unknown case occurred with alert. Closing alert.")
                break
            }
        }
    }
    
}