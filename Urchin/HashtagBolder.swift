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
    
    // A function to identify, then bold, the hashtags in some text
    // returns an attributed string
    func boldHashtags(text: NSString) -> NSAttributedString {
        
        // convert to attributed string
        let attributedText = NSMutableAttributedString(string: text as String)
        attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!, NSForegroundColorAttributeName: UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)], range: NSRange(location: 0, length: attributedText.length))
        
        // break apart the words
        let words = text.componentsSeparatedByString(" ")
        
        // keep track of the words that have been bolded
        var boldedWords = Dictionary<String, Int>()
        
        for word in words {
            if (word.hasPrefix("#")) {
                // a hashtag was found!
                
                // algorithm to end the hashtag on punctuation or symbols
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
                
                // the word without punctuation and symbols
                let newword = (word as! NSString).substringToIndex(charsInHashtag)
                
                // check to see if the hashtag has been used before
                if (boldedWords[newword] != nil) {
                    // it has been used before!
                    // how many times?
                    let previousOccurances = boldedWords[newword]!
                    
                    // let's take the full text for using
                    var textHolder = text
                    
                    // chop the full text apart until the (previousOccurances) time the hashtag is fount
                    // backwards search used
                    var i = 0
                    while (true) {
                        if (i == previousOccurances) {
                            break
                        }
                        let range: NSRange = textHolder.rangeOfString(newword, options: NSStringCompareOptions.BackwardsSearch)
                        textHolder = textHolder.substringToIndex(range.location + range.length - 1)
                        i++
                    }
                    
                    // now, using a backwards search and the choped up string, the first time the hashtag is used is the occurance that we are looking for!
                    // I have the range!
                    let range: NSRange = textHolder.rangeOfString(newword, options: NSStringCompareOptions.BackwardsSearch)
                    // make that range BOLD!
                    attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: range)
                    
                    boldedWords[newword]! += 1
                } else {
                    // It's the first time we've found this hashtag
                    // Let's keep track of it, shall we?
                    boldedWords[newword] = 1
                    let range: NSRange = text.rangeOfString(newword, options: NSStringCompareOptions.BackwardsSearch)
                    // Oh, and bold it.
                    attributedText.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17.5)!], range: range)
                }
            }
        }
        
        return attributedText
    }
    
}