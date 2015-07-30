//
//  AddNoteVCAlertViewDelegate.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

extension AddNoteViewController: UIAlertViewDelegate {
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            NSLog("Cancel alert and return to note")
            break
        case 1:
            NSLog("Do not add note and close view controller")
            
            let notification = NSNotification(name: "doneAdding", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
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