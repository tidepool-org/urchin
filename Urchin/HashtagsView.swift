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
    
    // Paged hashtag arrangement, and linear hashtag arrangement
    var pagedHashtagButtons: [[[UIButton]]] = []
    var hashtagButtons: [UIButton] = []
    
    // Keep track of the total widths
    var totalLinearHashtagsWidth: CGFloat = 0
    var totalPagedHashtagsWidth: CGFloat = 0
    
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
                        println("Could not save \(errorTwo), \(errorTwo?.userInfo)")
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
                    println("Could not save \(errorTwo), \(errorTwo?.userInfo)")
                }
            }
            
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
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
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        // If it didn't find any hashtags (first time using app)
        // Get and set the default set
        if (self.hashtags.count == 0) {
            self.getAndSetDefaultHashtags()
        }
    }
    
    // Only called once if there are no hashtags saved in CoreData
    func getAndSetDefaultHashtags() {
        // For now, the defaults are predefined here
        // Eventually, fetch from the Tidepool platform
        let defaults = ["#exercise", "#low", "#high", "#meal", "#snack", "#stress", "#pumpfail", "#cgmfail", "#success", "#juicebox", "#pumpchange", "#cgmchange"]
        
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
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            // Append the hashtag to the list of hashtags
            hashtags.append(hashtag)
        }
    }
    
    // Create and configure the hashtag buttons
    func configureHashtagButtons() {
        
        /* Keep track of:
                - which number hashtag
                - which page
                - which row
                - which column
        */
        var index = 0
        var row = 0
        var col = 0
        var page = 0
        
        // Keep track of the current page and row that is being worked on
        var buttonPage: [[UIButton]] = []
        var buttonRow: [UIButton] = []
        
        // Infinite loop!!!
        while (true) {
            
            // jk
            if (index >= hashtags.count) {
                // Break if there are no more hashtags
                break
            }
            
            // If it's the end of the third row, reset for the next page
            if (row > 2) {
                row = 0
                col = 0
                page += 1
                // Append the page and clear it
                pagedHashtagButtons.append(buttonPage)
                buttonPage = []
                continue
            }
            
            // Configure the individual hashtag button
            let hashtagButton = configureHashtagButton(index)
            
            var buttonX: CGFloat
            
            // If it's the first one in a row, it's a label inset in
            // All other's in the row are based upon the previous hashtag in the row
            if (col == 0) {
                buttonX = CGFloat(page) * UIScreen.mainScreen().bounds.width + labelInset
            } else {
                buttonX = buttonRow[col - 1].frame.maxX + 2 * labelSpacing
            }
            
            // If the hashtag spills over to the next page, start a new row
            if ((buttonX + hashtagButton.frame.width) > (CGFloat(page + 1) * UIScreen.mainScreen().bounds.width - labelInset)) {
                // Append the row current row and reset/increment values
                buttonPage.append(buttonRow)
                buttonRow = []
                row++
                col = 0
                continue
            } else {
                // The button didn't spill over! Add to the totalLinearHashtagsWidth and append the button to the row
                totalLinearHashtagsWidth += hashtagButton.frame.width + 2 * labelSpacing
                buttonRow.append(hashtagButton)
                hashtagButtons.append(hashtagButton)
            }
            
            // Set the x origin to the left allign position
            buttonRow[col].frame.origin.x = buttonX
            
            // Increment the index and column
            index++
            col++
        }
        // Take off the extra bit from the end of the totalLinearHashtagsWidth
        totalLinearHashtagsWidth -= 2 * labelSpacing
        // Append the most recent buttonRow to the buttonPage
        buttonPage.append(buttonRow)
        // Append the most recent buttonPage to all of the pages
        pagedHashtagButtons.append(buttonPage)
        // Arrange in pages arrangement
        pageHashtagArrangement()
    }
    
    // For when the HashtagsView is expanded
    func pageHashtagArrangement() {
        
        // For determining the total width of paged hashtags
        // Keep track of the total width of each row
        // Longest row will determine total width of paged hashtags
        var rowZeroWidth: CGFloat = 0.0
        var rowOneWidth: CGFloat = 0.0
        var rowTwoWidth: CGFloat = 0.0
        
        var page = 0
        for bPage in pagedHashtagButtons {
            var row = 0
            for bRow in bPage {
                var col = 0
                for button in bRow {
                    // y origin is based upon which row the hashtag is in
                    let buttonY = labelInset + CGFloat(row) * (hashtagHeight + 1.5 * labelSpacing)
                    
                    // buttonX is dependant on the first button on the first page for each row
                    var buttonX: CGFloat
                    if (page == 0 && col == 0) {
                        // First button on first page for each row
                        // labelInset with a variant for the current page
                        buttonX = labelInset
                    } else if (col == 0) {
                        // First button on any other page, in any row
                        // Based upon the maxX of the last button on the previous page in the same row
                        buttonX = pagedHashtagButtons[page - 1][row][pagedHashtagButtons[page - 1][row].count - 1].frame.maxX + 2 * labelSpacing
                    } else {
                        // Any other button
                        // Based upon the previous button in the row (same page)
                        buttonX = bRow[col - 1].frame.maxX + 2 * labelSpacing
                    }
                    
                    button.frame.origin = CGPoint(x: buttonX, y: buttonY)
                    self.addSubview(button)
                    
                    // Keep track of row width
                    if (row == 0) {
                        rowZeroWidth += button.frame.width + 2 * labelSpacing
                    } else if (row == 1) {
                        rowOneWidth += button.frame.width + 2 * labelSpacing
                    } else if (row == 2) {
                        rowTwoWidth += button.frame.width + 2 * labelSpacing
                    }
                    
                    col++
                }
                row++
            }
            page++
        }
        
        // Compensate for extra spacing added for last label
        rowZeroWidth -= 2 * labelSpacing
        rowOneWidth -= 2 * labelSpacing
        rowTwoWidth -= 2 * labelSpacing
        
        // Set the total paged width to the maximum of the three
        totalPagedHashtagsWidth = max(rowZeroWidth, rowOneWidth, rowTwoWidth)
    }
    
    // For when the HashtagsView is condensed
    func linearHashtagArrangement() {
        var index = 0
        for button in hashtagButtons {
            button.frame.origin.y = labelInset
            
            // If it is the first button, it's x origin is based upon which linearHashtagsPage the user is on
            // Else, it's x origin is based upon the previous button
            if (index == 0) {
                button.frame.origin.x = labelInset
            } else {
                button.frame.origin.x = hashtagButtons[index - 1].frame.maxX + 2 * labelSpacing
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
            attributes:[NSForegroundColorAttributeName: UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: .Normal)
        hashtagButton.frame.size.height = hashtagHeight
        hashtagButton.sizeToFit()
        hashtagButton.frame.size.width = hashtagButton.frame.width + 4 * labelSpacing
        hashtagButton.backgroundColor = UIColor.whiteColor()
        hashtagButton.layer.cornerRadius = hashtagButton.frame.height / 2
        hashtagButton.layer.borderWidth = 1
        hashtagButton.layer.borderColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1).CGColor
        hashtagButton.addTarget(self, action: "hashtagPressed:", forControlEvents: .TouchUpInside)
        
        return hashtagButton
    }
    
    // A hashtag button was pressed, so send a notification with userInfo to the AddNoteVC or EditNoteVC
    func hashtagPressed(sender: UIButton!) {
        let notification = NSNotification(name: "hashtagPressed", object: nil, userInfo: ["hashtag":sender.titleLabel!.text!])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}