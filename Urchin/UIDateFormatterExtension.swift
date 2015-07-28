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
        self.dateFormat = uniformDateFormat
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
        let attrStr = NSMutableAttributedString(string: dateString, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: smallRegularFont])
        attrStr.addAttribute(NSFontAttributeName, value: smallBoldFont, range: NSRange(location: attrStr.length - count, length: count))
        
        return attrStr
    }
    
    func dateFromISOString(string: String) -> NSDate {
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.timeZone = NSTimeZone.localTimeZone()
        self.dateFormat = iso8601dateOne
        if let date = self.dateFromString(string) {
            return date
        } else {
            self.dateFormat = iso8601dateTwo
            return self.dateFromString(string)!
        }
    }
    
    func isoStringFromDate(date: NSDate, zone: NSTimeZone?) -> String {
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        if (zone != nil) {
            self.timeZone = zone
        } else {
            self.timeZone = NSTimeZone.localTimeZone()
        }
        self.dateFormat = iso8601dateOne
        return self.stringFromDate(date)
    }
    
    func stringFromRegDate(date:NSDate) -> String {
        self.dateFormat = regularDateFormat
        return stringFromDate(date)
    }
    
}
