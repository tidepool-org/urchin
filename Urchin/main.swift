/*
 * Copyright (c) 2016, Tidepool Project
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

import UIKit
import CocoaLumberjack

class App: UIApplication {
    override init() {
        // Set up Xcode and system logging
        DDASLLogger.sharedInstance().logFormatter = LogFormatter()
        DDTTYLogger.sharedInstance().logFormatter = LogFormatter()
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        // Set up file logging
        fileLogger = DDFileLogger()
        fileLogger.logFormatter = LogFormatter()
        fileLogger.rollingFrequency = 60 * 60 * 4; // 2 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 12;
        // Clear log files
        // Don't clear log files, let's leave them so we can debug background delivery of glucose data
        //        let logFileInfos = fileLogger.logFileManager.unsortedLogFileInfos()
        //        for logFileInfo in logFileInfos {
        //            if let logFilePath = logFileInfo.filePath {
        //                do {
        //                    try NSFileManager.defaultManager().removeItemAtPath(logFilePath)
        //                    logFileInfo.reset()
        //                    DDLogInfo("Removed log file: \(logFilePath)")
        //                } catch let error as NSError {
        //                    DDLogError("Failed to remove log file at path: \(logFilePath) error: \(error), \(error.userInfo)")
        //                }
        //            }
        //        }
        // Add file logger
        DDLog.addLogger(fileLogger);
        
        // Set up log level
#if DEBUG
        defaultDebugLevel = DDLogLevel.Verbose
#else
        if NSUserDefaults.standardUserDefaults().boolForKey("LoggingEnabled") {
            defaultDebugLevel = DDLogLevel.Verbose
        } else {
            defaultDebugLevel = DDLogLevel.Off
        }
#endif
        DDLogVerbose("traced")
    }
}

    
UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(App), NSStringFromClass(AppDelegate))