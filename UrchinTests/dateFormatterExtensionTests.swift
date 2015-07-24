//
//  dateFormatterExtensionTests.swift
//  urchin
//
//  Created by Ethan Look on 7/21/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import UIKit
import XCTest

class dateFormatterExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAttributedStringFromDate() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        let date = NSDate(timeIntervalSince1970: 946729800)
        let expected = NSMutableAttributedString(string: "Saturday 1.1.00 12:30pm", attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 12.5)!])
        expected.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Bold", size: 12.5)!, range: NSRange(location: 16, length: 7))
        
        XCTAssertEqual(dateFormatter.attributedStringFromDate(date), expected, "Assert that the date formatter properly bolds to expected.")
    }
    
    func testDateFromISOString() {
        let dateFormatter = NSDateFormatter()
        let dateString = "2015-06-04T13:45:36+00:00"
        let expected = NSDate(timeIntervalSince1970: 1433425536)
        XCTAssertEqual(dateFormatter.dateFromISOString(dateString), expected, "Assert that date formatter converts to NSDate properly.")
    }
    
    func testISOStringFromDate() {
        let dateFormatter = NSDateFormatter()
        let date = NSDate(timeIntervalSince1970: 1433425536)
        let expected = "2015-06-04T13:45:36Z"
        
        XCTAssertEqual(dateFormatter.isoStringFromDate(date, zone: NSTimeZone(name: "GMT")), expected, "Assert that date formatter converts NSDate to ISO 8601 properly.")
    }

    func testStringFromRegDate() {
        let dateFormatter = NSDateFormatter()
        let date = NSDate(timeIntervalSince1970: 823521600)
        let expected = "1996-02-05"
        
        XCTAssertEqual(dateFormatter.stringFromRegDate(date), expected, "Assert that a NSDate for a day, such as a birthday, converts to a string properly.")
    }

}
