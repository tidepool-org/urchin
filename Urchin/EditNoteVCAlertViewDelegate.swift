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
    }
    
}