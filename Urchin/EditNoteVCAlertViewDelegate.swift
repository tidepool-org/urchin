//
//  EditNoteVCAlertViewDelegate.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

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