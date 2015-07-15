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
                var charsInHashtag: Int = 0
                let symbols = NSCharacterSet.symbolCharacterSet()
                let punctuation = NSCharacterSet.punctuationCharacterSet()
                for char in (word as! String).unicodeScalars {
                    if (char == "#" && charsInHashtag == 0) {
                        charsInHashtag++
                        continue
                    }
                    if (!punctuation.longCharacterIsMember(char.value) && !symbols.longCharacterIsMember(char.value)) {
                        charsInHashtag++
                    } else {
                        break
                    }
                }
                
                let newword = (word as! NSString).substringToIndex(charsInHashtag)
                
                if (boldedWords[newword] != nil) {
                    let previousOccurances = boldedWords[newword]!
                    var textHolder = text
                    
                    var i = 0
                    while (true) {
                        if (i == previousOccurances) {
                            break
                        }
                        let range: NSRange = textHolder.rangeOfString(newword, options: NSStringCompareOptions.BackwardsSearch)
                        textHolder = textHolder.substringToIndex(range.location + range.length - 1)
                        i++
                    }
                    let range: NSRange = textHolder.rangeOfString(newword, options: NSStringCompareOptions.BackwardsSearch)
                    attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: range)
                    
                    boldedWords[newword]! += 1
                } else {
                    
                    boldedWords[newword] = 1
                    let range: NSRange = text.rangeOfString(newword, options: NSStringCompareOptions.BackwardsSearch)
                    attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: range)
                }
            }
        }
        
        return attributedText
    }
    
}