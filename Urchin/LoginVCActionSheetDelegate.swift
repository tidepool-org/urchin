//
//  LoginVCActionSheetDelegate.swift
//  urchin
//
//  Created by Ethan Look on 7/31/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

extension LogInViewController: UIActionSheetDelegate {
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch actionSheet.buttonTitleAtIndex(buttonIndex) {
        case "Development":
            NSLog("Switched to development server")
            baseURL = develURL
            break
        case "Production":
            NSLog("Switched to production server")
            baseURL = prodURL
            break
        default:
            NSLog("Server selection: case not handled")
            break
        }
    }
    
}