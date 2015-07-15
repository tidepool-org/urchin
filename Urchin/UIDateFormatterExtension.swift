//
//  UIDateFormatterExtension.swift
//  urchin
//
//  Created by Ethan Look on 7/15/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import UIKit

public extension NSDateFormatter {
    
    func attributedStringFromDate(date: NSDate) -> NSMutableAttributedString {
        self.dateFormat = "EEEE M.d.yy h:mma"
        var dateString = self.stringFromDate(date)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var count = 0
        for char in reverse(dateString) {
            if (char == " ") {
                break
            } else {
                count++
            }
        }

        let attrStr = NSMutableAttributedString(string: dateString, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 12.5)!])
        attrStr.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Bold", size: 12.5)!, range: NSRange(location: attrStr.length - count, length: count))
        return attrStr
    }
    
}
