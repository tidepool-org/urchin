//
//  HashtagsView.swift
//  urchin
//
//  Created by Ethan Look on 7/14/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HashtagsView: UIView {
    
    // Hashtags from CoreData
    var hashtags = [NSManagedObject]()
    
    // Vertical hashtag arrangement, and linear hashtag arrangement
    var verticalHashtagButtons: [[UIButton]] = []
    var hashtagButtons: [UIButton] = []
    
    // Keep track of the total widths
    var totalLinearHashtagsWidth: CGFloat = 0
    var totalVerticalHashtagsHeight: CGFloat = 0
    
    // Called to set up the view
    func configureHashtagsView() {
        // Fetch the hashtags from core data, arrange them
        self.fetchHashtags()
        self.configureHashtagButtons()
        
        self.userInteractionEnabled = true
    }
    
    // Save a hashtag in CoreDate
    func handleHashtagCoreData(text: String) {
        
        // Store the appDelegate
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        // store the mangagedContext
        let managedContext = appDelegate.managedObjectContext!
        
        // Open a new fetch request for a Hashtag
        let fetchRequest = NSFetchRequest(entityName:"Hashtag")
        
        var error: NSError?
        
        // Execute the fetch from CoreData
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        // If there are results
        if let results = fetchedResults {
            // keep track of whether or not the hashtag in question was fount
            var found = false
            
            for result in results {
                // Check each result
                if (result.valueForKey("text") as! String == text) {
                    // Fount it!
                    found = true
                    
                    // Increment the number of times the hashtag has been used
                    let usages = (result.valueForKey("usages") as! Int) + 1
                    result.setValue(usages, forKey: "usages")
                    
                    // Attempt to save the hashtag
                    var errorTwo: NSError?
                    if !managedContext.save(&errorTwo) {
                        NSLog("Could increase number of usages for hashtag \(text): \(errorTwo), \(errorTwo?.userInfo)")
                    }
                    
                    break
                }
            }
            
            // If the hashtag was never found
            if (!found) {
                // Store a new hashtag!
                
                // Initialize the new entity
                let entity =  NSEntityDescription.entityForName("Hashtag",
                    inManagedObjectContext:
                    managedContext)
                
                // Let it be a hashtag in the managedContext
                let hashtag = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                // Set the text and number of times it has been used (1)
                hashtag.setValue(text, forKey: "text")
                hashtag.setValue(1, forKey: "usages")
                
                // Save the hashtag
                var errorTwo: NSError?
                if !managedContext.save(&errorTwo) {
                    NSLog("Could not save new hashtag \(text): \(errorTwo), \(errorTwo?.userInfo)")
                }
            }
            
        } else {
            NSLog("Could not fetch hashtags to handle hashtag \(text): \(error), \(error!.userInfo)")
        }
    }
    
    // Get the hashtags for use!
    func fetchHashtags() {
        
        // Store the appDelegate
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Store the managedContext
        let managedContext = appDelegate.managedObjectContext!
        
        // Open a new fetch request
        let fetchRequest = NSFetchRequest(entityName:"Hashtag")
        
        // Sort based upon usages
        let sortDescriptor = NSSortDescriptor(key: "usages", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var error: NSError?
        
        // Execute the fetch
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        // If there were results
        if let results = fetchedResults {
            // Let hashtags be the results
            self.hashtags = results
        } else {
            NSLog("Could not fetch hashtags: \(error), \(error!.userInfo)")
        }
        
        // If it didn't find any hashtags (first time using app)
        // Get and set the default set
        if (self.hashtags.count == 0) {
            self.getAndSetDefaultHashtags()
        }
    }
    
    // Only called if there are no hashtags saved in CoreData
    func getAndSetDefaultHashtags() {
        // For now, the defaults are predefined here
        // Eventually, fetch from the Tidepool platform
        let defaults = ["#low", "#exercise", "#meal", "#depressed", "#stress", "#site", "#sitechange", "#sensor", "#sensorchange", "#juicebox", "#devicesetting"]
        
        // Store the appDelegate
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Store the managedContext
        let managedContext = appDelegate.managedObjectContext!
        
        // For each default hashtag...
        for text in defaults {
            
            // Create an entity for use
            let entity =  NSEntityDescription.entityForName("Hashtag",
                inManagedObjectContext:
                managedContext)
            
            // Let that entity be a hashtag NSManagedObject
            let hashtag = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            // Set the text and usages (1)
            hashtag.setValue(text, forKey: "text")
            hashtag.setValue(1, forKey: "usages")
            
            // Save the hashtag in CoreData
            var error: NSError?
            if !managedContext.save(&error) {
                NSLog("Could not save default hashtag \(text): \(error), \(error?.userInfo)")
            }
            
            // Append the hashtag to the list of hashtags
            hashtags.append(hashtag)
        }
    }
    
    // Create and configure the hashtag buttons
    func configureHashtagButtons() {
        
        /* Keep track of:
                - which number hashtag
                - which row
                - which column
        */
        var index = 0
        var row = 0
        var col = 0
        
        // Keep track of the current row that is being worked on
        var buttonRow: [UIButton] = []
        
        // Infinite loop!!!
        while (true) {
            
            // jk
            if (index >= hashtags.count) {
                // Break if there are no more hashtags
                break
            }
            
            // Configure the individual hashtag button
            let hashtagButton = configureHashtagButton(index)
            
            var buttonX: CGFloat
            
            // If it's the first one in a row, it's a label inset in
            // All other's in the row are based upon the previous hashtag in the row
            if (col == 0) {
                buttonX = labelInset
            } else {
                buttonX = buttonRow[col - 1].frame.maxX + horizontalHashtagSpacing
            }
            
            // If the hashtag spills over to the next page, start a new row
            if ((buttonX + hashtagButton.frame.width) > (UIScreen.mainScreen().bounds.width - labelInset)) {

                totalVerticalHashtagsHeight += hashtagHeight + verticalHashtagSpacing
                
                // Append the current row and reset/increment values
                verticalHashtagButtons.append(buttonRow)
                buttonRow = []
                row++
                col = 0
                continue
            } else {
                // The button didn't spill over! Add to the totalLinearHashtagsWidth and append the button to the row
                totalLinearHashtagsWidth += hashtagButton.frame.width + horizontalHashtagSpacing
                buttonRow.append(hashtagButton)
                hashtagButtons.append(hashtagButton)
            }
            
            // Set the x origin (used for determining the position of the next hashtagButton)
            buttonRow[col].frame.origin.x = buttonX
            
            // Increment the index and column
            index++
            col++
        }
        
        // Take off the extra bit from the end of the totalLinearHashtagsWidth
        totalLinearHashtagsWidth -= horizontalHashtagSpacing
        
        // If the last button row has more hashtags, increase the totalVerticalHashtagsHeight
        if (buttonRow.count > 0) {
            totalVerticalHashtagsHeight += hashtagHeight
            
            // Append the most recent buttonRow to the verticalHashtagButtons
            verticalHashtagButtons.append(buttonRow)
        } else {
            // Else take the extra bit off (spacing between rows)
            totalVerticalHashtagsHeight -= verticalHashtagSpacing
        }
        
        // Arrange in pages arrangement
        verticalHashtagArrangement()
    }
    
    // For when the HashtagsView is expanded
    func verticalHashtagArrangement() {
        
        var row = 0
        for bRow in verticalHashtagButtons {
            
            // y origin is based upon which row the hashtag is in
            let buttonY = labelInset + CGFloat(row) * (hashtagHeight + verticalHashtagSpacing)
            
            // Find the total width of the row
            var totalButtonWidth: CGFloat = CGFloat(0)
            var i = 0
            for button in bRow {
                totalButtonWidth += button.frame.width + horizontalHashtagSpacing
                i++
            }
            
            // Determine the width between the outer margins
            let totalWidth = totalButtonWidth - 2 * labelSpacing
            // Take the halfWidth
            let halfWidth = totalWidth / 2

            // x origin of the left most button in the row
            // (page - hashtagsPage) for paging
            var buttonX = UIScreen.mainScreen().bounds.width / 2 - halfWidth
            
            var col = 0
            for button in bRow {
             
                button.frame.origin = CGPoint(x: buttonX, y: buttonY)
                self.addSubview(button)
                
                // increase the buttonX for the next button
                buttonX = button.frame.maxX + horizontalHashtagSpacing
                
                col++
            }
            
            row++
        }
    }
    
    // For when the HashtagsView is condensed
    func linearHashtagArrangement() {
        var index = 0
        for button in hashtagButtons {
            button.frame.origin.y = labelInset
            
            // If it is the first button, it's x origin is just the labelInset
            // Else, it's x origin is based upon the previous button
            if (index == 0) {
                button.frame.origin.x = labelInset
            } else {
                button.frame.origin.x = hashtagButtons[index - 1].frame.maxX + horizontalHashtagSpacing
            }
            index++
        }
    }
    
    // Create the hashtag button with the correct attributes based upon the index
    // Returns the button that was created
    func configureHashtagButton(index: Int) -> UIButton {
        let hashtagButton = UIButton(frame: CGRectZero)
        let hashtag = hashtags[index]
        let hashtagText = hashtag.valueForKey("text") as! String
        hashtagButton.setAttributedTitle(NSAttributedString(string: hashtagText,
            attributes:[NSForegroundColorAttributeName: blackishColor, NSFontAttributeName: mediumRegularFont]), forState: .Normal)
        hashtagButton.frame.size.height = hashtagHeight
        hashtagButton.sizeToFit()
        hashtagButton.frame.size.width = hashtagButton.frame.width + 4 * labelSpacing
        hashtagButton.backgroundColor = hashtagColor
        hashtagButton.layer.cornerRadius = hashtagButton.frame.height / 2
        hashtagButton.layer.borderWidth = hashtagBorderWidth
        hashtagButton.layer.borderColor = hashtagBorderColor.CGColor
        hashtagButton.addTarget(self, action: "hashtagPressed:", forControlEvents: .TouchUpInside)
        
        return hashtagButton
    }
    
    // A hashtag button was pressed, so send a notification with userInfo to the AddNoteVC or EditNoteVC
    func hashtagPressed(sender: UIButton!) {
        let notification = NSNotification(name: "hashtagPressed", object: nil, userInfo: ["hashtag":sender.titleLabel!.text!])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}