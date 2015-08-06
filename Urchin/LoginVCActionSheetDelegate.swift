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
        let serverName = actionSheet.buttonTitleAtIndex(buttonIndex)
        
        apiConnector.saveServer(serverName)
        
        version.text = UIApplication.versionBuildServer()
        version.sizeToFit()
        version.frame.origin.x = self.view.frame.width / 2 - version.frame.width / 2
                
        NSLog("Switched to \(serverName) server")
    }
    
}