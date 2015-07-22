//
//  UIDateFormatterExtension.swift
//  urchin
//
//  Created by Ethan Look on 7/15/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//
//  Extension to format the dates consistently through the application.
//

import UIKit

public extension NSDateFormatter {
    
    func attributedStringFromDate(date: NSDate) -> NSMutableAttributedString {
        // Date format being used.
        self.dateFormat = "EEEE M.d.yy h:mma"
        var dateString = self.stringFromDate(date)
        
        // Replace uppercase PM and AM with lowercase versions
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // Count backwards until the first space (will bold)
        var count = 0
        for char in reverse(dateString) {
            if (char == " ") {
                break
            } else {
                count++
            }
        }

        // Bold the last (count) characters (the time)
        let attrStr = NSMutableAttributedString(string: dateString, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 12.5)!])
        attrStr.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Bold", size: 12.5)!, range: NSRange(location: attrStr.length - count, length: count))
        
        return attrStr
    }
    
    func dateFromISOString(string: String) -> NSDate {
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.timeZone = NSTimeZone.localTimeZone()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = self.dateFromString(string) {
            return date
        } else {
            self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return self.dateFromString(string)!
        }
    }
    
    func isoStringFromDate(date: NSDate) -> String {
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.timeZone = NSTimeZone.localTimeZone()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return self.stringFromDate(date)
    }
    
    func stringFromRegDate(date:NSDate) -> String {
        self.dateFormat = "yyyy-MM-dd"
        return stringFromDate(date)
    }
    
}