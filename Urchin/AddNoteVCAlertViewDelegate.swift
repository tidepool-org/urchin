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