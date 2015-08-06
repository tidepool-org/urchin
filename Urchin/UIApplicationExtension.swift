//
//  UIApplicationExtension.swift
//  urchin
//
//  Created by Ethan Look on 7/29/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuildServer() -> String {
        let version = appVersion(), build = appBuild()
        
        var serverName: String = ""
        for server in servers {
            if (server.1 == baseURL) {
                serverName = server.0
                break
            }
        }
        
        return serverName.isEmpty ? "v.\(version) (\(build))" : "v.\(version) (\(build)) on \(serverName)"
    }
}