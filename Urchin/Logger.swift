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
import MessageUI
import CocoaLumberjack

class Logger: NSObject, MFMailComposeViewControllerDelegate {
    static let sharedInstance = Logger()
    private override init() {
        super.init()
        
        // Set up Xcode and system logging
        DDASLLogger.sharedInstance().logFormatter = LogFormatter()
        DDTTYLogger.sharedInstance().logFormatter = LogFormatter()
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        // Set up file logging
        fileLogger.logFormatter = LogFormatter()
        fileLogger.rollingFrequency = 60 * 60 * 4; // 2 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 12;
        DDLog.addLogger(fileLogger);
        
        // Set log level
        defaultDebugLevel = DDLogLevel.Off
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(Logger.loggingEnabledKey)?.boolValue {
            defaultDebugLevel = DDLogLevel.Verbose
            DDLogVerbose("Logs are enabled")
        } else {
            DDLogVerbose("Logs are disabled, clearing logs")
            self.clearLogs()
        }
    }
    
    func clearLogs() {
        DDLogVerbose("trace")
        
        DDLog.flushLog()

        let logFileInfos = fileLogger.logFileManager.unsortedLogFileInfos()
        for logFileInfo in logFileInfos {
            if let logFilePath = logFileInfo.filePath {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(logFilePath)
                    logFileInfo.reset()
                    DDLogInfo("Removed log file: \(logFilePath)")
                } catch let error as NSError {
                    DDLogError("Failed to remove log file at path: \(logFilePath) error: \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func enableLogging() {
        DDLogVerbose("trace")

        defaultDebugLevel = DDLogLevel.Verbose
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: Logger.loggingEnabledKey);
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func disableLogging() {
        DDLogVerbose("trace")

        defaultDebugLevel = DDLogLevel.Off
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: Logger.loggingEnabledKey);
        NSUserDefaults.standardUserDefaults().synchronize()

        self.clearLogs()
    }
    
    func emailLogs(presentingViewController: UIViewController) {
        DDLogVerbose("trace")

        DDLog.flushLog()
        
        let logFilePaths = fileLogger.logFileManager.sortedLogFilePaths() as! [String]
        var logFileDataArray = [NSData]()
        for logFilePath in logFilePaths {
            let fileURL = NSURL(fileURLWithPath: logFilePath)
            if let logFileData = try? NSData(contentsOfURL: fileURL, options: NSDataReadingOptions.DataReadingMappedIfSafe) {
                // Insert at front to reverse the order, so that oldest logs appear first.
                logFileDataArray.insert(logFileData, atIndex: 0)
            }
        }
        
        if (logFilePaths.count > 0) {
            if MFMailComposeViewController.canSendMail() {
                let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                composeVC.setSubject("Logs for \(appName)")
                composeVC.setMessageBody("", isHTML: false)
                
                let attachmentData = NSMutableData()
                for logFileData in logFileDataArray {
                    attachmentData.appendData(logFileData)
                }
                composeVC.addAttachmentData(attachmentData, mimeType: "text/plain", fileName: "\(appName).txt")
                presentingViewController.presentViewController(composeVC, animated: true, completion: nil)
            } else {
                var alert: UIAlertController?
                let title = "Email Logs"
                let message = "Unable to send mail."
                DDLogInfo(message)
                alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alert!.addAction(UIAlertAction(title: addAlertOkay, style: .Default, handler: nil))
                presentingViewController.presentViewController(alert!, animated: true, completion: nil)
            }
        } else {
            var alert: UIAlertController?
            let title = "Email Logs"
            let message = "There are no logs to email. Logs are either disabled or no logs have occurred since enabling logs."
            DDLogInfo(message)
            alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert!.addAction(UIAlertAction(title: addAlertOkay, style: .Default, handler: nil))
            presentingViewController.presentViewController(alert!, animated: true, completion: nil)
        }
    }

    func mailComposeController(controller: MFMailComposeViewController, result: MFMailComposeResult, error: NSError?) {
        DDLogVerbose("trace")

        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private static let loggingEnabledKey = "LoggingEnabled-v2"
    private let fileLogger = DDFileLogger()
}
