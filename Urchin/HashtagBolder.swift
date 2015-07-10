//
//  HashtagBolder.swift
//  urchin
//
//  Created by Ethan Look on 7/10/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class HashtagBolder {
    
    func boldHashtags(text: NSString) -> NSAttributedString {
        
        let attributedText = NSMutableAttributedString(string: text as String)
        attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!, NSForegroundColorAttributeName: UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)], range: NSRange(location: 0, length: attributedText.length))
        let words = text.componentsSeparatedByString(" ")
        
        var boldedWords = Dictionary<String, Int>()
        
        for word in words {
            if (word.hasPrefix("#")) {
                if (boldedWords[word as! String] != nil) {
                    let previousOccurances = boldedWords[word as! String]!
                    var textHolder = text
                    
                    var i = 0
                    while (true) {
                        if (i == previousOccurances) {
                            break
                        }
                        let range: NSRange = textHolder.rangeOfString(word as! String, options: NSStringCompareOptions.BackwardsSearch)
                        textHolder = textHolder.substringToIndex(range.location + range.length - 1)
                        i++
                    }
                    let range: NSRange = textHolder.rangeOfString(word as! String, options: NSStringCompareOptions.BackwardsSearch)
                    attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: range)
                    
                    boldedWords[word as! String]! += 1
                } else {
                    boldedWords[word as! String] = 1
                    let range: NSRange = text.rangeOfString(word as! String, options: NSStringCompareOptions.BackwardsSearch)
                    attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: range)
                }
            }
        }
        
        return attributedText
    }
    
}