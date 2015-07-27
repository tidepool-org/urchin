//
//  hashtagBolderTests.swift
//  urchinTests
//
//  Created by Ethan Look on 6/17/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import UIKit
import XCTest

class hashtagBolderTests: XCTestCase {
    
    let hashtagBolder = HashtagBolder()
    
    override func setUp() {
        super.setUp()
        // Setup code. This method is called before the invocation of each test method in the class.
        // No setup needed.
    }
    
    override func tearDown() {
        // Teardown code. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmpty() {
        XCTAssertEqual(hashtagBolder.boldHashtags(""), NSAttributedString(), "Assert that an empty string passed returns an empty attributed string")
    }
    
    func testNoHashtags() {
        // String that does not contain hashtags, to be passed through hashtagBolder.
        let text = "This is text that does not contain hashtags. No hashtags are present."
        
        // Expected attributed output has no bolded portions.
        let expected = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!, NSForegroundColorAttributeName: UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)])
        
        // Assert that the output and the expected string are indeed the same string (by content and attributes, not instance).
        XCTAssertEqual(hashtagBolder.boldHashtags(text), expected, "Assert that a string containing no hashtags is unbolded.")
    }
    
    func testWithHashtags() {
        
        // String that does contain hashtags, to be passed through the hashtagBolder.
        let text = "This #is text #that? does #contain! #hashtags. #hashtags are present."
        
        // Expected attributed output that has bolded portions.
        let expected = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!, NSForegroundColorAttributeName: UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)])
        // Oh, and bold it.
        expected.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: NSRange(location: 5, length: 3))
        expected.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: NSRange(location: 14, length: 5))
        expected.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: NSRange(location: 26, length: 8))
        expected.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: NSRange(location: 36, length: 9))
        expected.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: NSRange(location: 47, length: 9))
        
        // Assert that the output and the expected string are indeed the same string (by content and attributes, not instance).
        XCTAssertEqual(hashtagBolder.boldHashtags(text), expected, "Assert that a string containing hashtags is properly bolded.")
    }
    
    func testPerformanceExample() {
        // Test the speed of the hashtag bolder. Repeating hashtags take the most time.
        let text = "#first #second #first #second #first #second #first #second #first #second #first #second #first #second #first #second #first #second #first #second #first #second #first #second #first #second #first #second"
        self.measureBlock() {
            let attrStr = self.hashtagBolder.boldHashtags(text)
        }
    }
    
}
