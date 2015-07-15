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
    
    var hashtags = [NSManagedObject]()
    var pagedHashtagButtons: [[[UIButton]]] = []
    var hashtagButtons: [UIButton] = []
    var hashtagsPage: Int = 0
    var linearHashtagsPage: Int = 0
    var totalLinearHashtagsWidth: CGFloat = 0
    
    var hashtagsCollapsed: Bool = false
    var isAnimating: Bool = false
    
    func configureHashtagsView() {
        self.fetchHashtags()
        self.configureHashtagButtons()
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: "swipeHashtagViewRight:")
        self.addGestureRecognizer(swipeGestureRight)
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: "swipeHashtagViewLeft:")
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeGestureLeft)
        self.userInteractionEnabled = true
    }
    
    func swipeHashtagViewLeft(sender: UISwipeGestureRecognizer!) {
        if (hashtagsCollapsed) {
            // hashtags are collapsed, swipe in linear arrangement
            
            let numberPages = Int(totalLinearHashtagsWidth / (self.frame.width / 2))
            
            if (linearHashtagsPage < numberPages && !isAnimating) {
                isAnimating = true
                UIView.animateKeyframesWithDuration(0.2, delay: 0.0, options: nil, animations: { () -> Void in
                    self.linearHashtagsPage += 1
                    self.linearHashtagArrangement()
                    }, completion: { (completed: Bool) -> Void in
                        self.isAnimating = false
                })
            }
        } else {
            // hashtags are expanded, swipe in page arrangement
            if (hashtagsPage < pagedHashtagButtons.count - 1 && !isAnimating) {
                isAnimating = true
                UIView.animateKeyframesWithDuration(0.2, delay: 0.0, options: nil, animations: { () -> Void in
                    self.hashtagsPage += 1
                    self.pageHashtagArrangement()
                    }, completion: { (completed: Bool) -> Void in
                        self.isAnimating = false
                })
            }
        }
    }

    func swipeHashtagViewRight(sender: UISwipeGestureRecognizer!) {
        if (hashtagsCollapsed) {
            // hashtags are collapsed, swipe in linear arrangement
            if (linearHashtagsPage > 0 && !isAnimating) {
                isAnimating = true
                UIView.animateKeyframesWithDuration(0.2, delay: 0.0, options: nil, animations: { () -> Void in
                    self.linearHashtagsPage -= 1
                    self.linearHashtagArrangement()
                    }, completion: { (completed: Bool) -> Void in
                        self.isAnimating = false
                })
            }
            
        } else {
            // hashtags are expanded, swipe in page arrangement
            if (hashtagsPage > 0 && !isAnimating) {
                isAnimating = true
                UIView.animateKeyframesWithDuration(0.2, delay: 0.0, options: nil, animations: { () -> Void in
                    self.hashtagsPage -= 1
                    self.pageHashtagArrangement()
                    }, completion: { (completed: Bool) -> Void in
                        self.isAnimating = false
                })
            }
        }
    }
    
    func handleHashtagCoreData(text: String) {
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Hashtag")
        
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            var found = false
            
            for result in results {
                if (result.valueForKey("text") as! String == text) {
                    found = true
                    
                    let usages = (result.valueForKey("usages") as! Int) + 1
                    result.setValue(usages, forKey: "usages")
                    
                    var errorTwo: NSError?
                    if !managedContext.save(&errorTwo) {
                        println("Could not save \(errorTwo), \(errorTwo?.userInfo)")
                    }
                    
                    break
                }
            }
            
            if (!found) {
                let entity =  NSEntityDescription.entityForName("Hashtag",
                    inManagedObjectContext:
                    managedContext)
                
                let hashtag = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                hashtag.setValue(text, forKey: "text")
                hashtag.setValue(1, forKey: "usages")
                
                var errorTwo: NSError?
                if !managedContext.save(&errorTwo) {
                    println("Could not save \(errorTwo), \(errorTwo?.userInfo)")
                }
            }
            
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func fetchHashtags() {
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Hashtag")
        
        let sortDescriptor = NSSortDescriptor(key: "usages", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            self.hashtags = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        if (self.hashtags.count == 0) {
            self.getAndSetDefaultHashtags()
        }
    }
    
    func getAndSetDefaultHashtags() {
        let defaults = ["#exercise", "#low", "#high", "#meal", "#snack", "#stress", "#pumpfail", "#cgmfail", "#success", "#juicebox", "#pumpchange", "#cgmchange"]
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        for text in defaults {
            let entity =  NSEntityDescription.entityForName("Hashtag",
                inManagedObjectContext:
                managedContext)
            
            let hashtag = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            hashtag.setValue(text, forKey: "text")
            hashtag.setValue(1, forKey: "usages")
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            hashtags.append(hashtag)
        }
    }
    
    func configureHashtagButtons() {
        
        var index = 0
        var row = 0
        var col = 0
        var page = 0
        
        var buttonPage: [[UIButton]] = []
        var buttonRow: [UIButton] = []
        
        while (true) {
            
            if (index >= hashtags.count) {
                break
            }
            
            if (row > 2) {
                row = 0
                col = 0
                page += 1
                pagedHashtagButtons.append(buttonPage)
                buttonPage = []
                continue
            }
            
            let hashtagButton = configureHashtagButton(index)
            
            var buttonX: CGFloat
            
            if (col == 0) {
                buttonX = CGFloat(page) * self.frame.width + labelInset
            } else {
                buttonX = buttonRow[col - 1].frame.maxX + 2 * labelSpacing
            }
            
            if ((buttonX + hashtagButton.frame.width) > (CGFloat(page + 1) * self.frame.width - labelInset)) {
                buttonPage.append(buttonRow)
                buttonRow = []
                row++
                col = 0
                continue
            } else {
                totalLinearHashtagsWidth += hashtagButton.frame.width + 2 * labelSpacing
                buttonRow.append(hashtagButton)
                hashtagButtons.append(hashtagButton)
            }
            
            buttonRow[col].frame.origin.x = buttonX
            
            index++
            col++
        }
        totalLinearHashtagsWidth -= 2 * labelSpacing
        buttonPage.append(buttonRow)
        pagedHashtagButtons.append(buttonPage)
        pageHashtagArrangement()
    }
    
    func pageHashtagArrangement() {
        var page = 0
        for bPage in pagedHashtagButtons {
            var row = 0
            for bRow in bPage {
                
                let buttonY = labelInset + CGFloat(row) * (hashtagHeight + 1.5 * labelSpacing)
                
                var totalButtonWidth: CGFloat = CGFloat(0)
                var i = 0
                for button in bRow {
                    totalButtonWidth += button.frame.width + 2 * labelSpacing
                    i++
                }
                
                let totalWidth = totalButtonWidth - 2 * labelSpacing
                let halfWidth = totalWidth / 2
                
                var buttonX = CGFloat(page - hashtagsPage) * (self.frame.width - 3.0 * labelInset) + self.frame.width / 2 - halfWidth
                var col = 0
                for button in bRow {
                    button.frame.origin = CGPoint(x: buttonX, y: buttonY)
                    self.addSubview(button)
                    buttonX = button.frame.maxX + 2 * labelSpacing
                    col++
                }
                
                row++
            }
            page++
        }
    }
    
    func linearHashtagArrangement() {
        var index = 0
        for button in hashtagButtons {
            button.frame.origin.y = labelInset
            if (index == 0) {
                button.frame.origin.x = labelInset - CGFloat(linearHashtagsPage) * self.frame.width / 2
            } else {
                button.frame.origin.x = hashtagButtons[index - 1].frame.maxX + 2 * labelSpacing
            }
            index++
        }
    }
    
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
    
    func hashtagPressed(sender: UIButton!) {
        let notification = NSNotification(name: "hashtagPressed", object: nil, userInfo: ["hashtag":sender.titleLabel!.text!])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}