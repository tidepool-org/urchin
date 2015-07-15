//
//  EditNoteViewController.swift
//  urchin
//
//  Created by Ethan Look on 7/13/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditNoteViewController: UIViewController, UITextViewDelegate {
    
    let timedateLabel: UILabel
    let changeDateLabel: UILabel
    
    var datePickerShown: Bool = false
    var isAnimating: Bool = false
    let datePicker: UIDatePicker
    
    let separatorOne: UIView
    
    let hashtagsView: HashtagsView
    
    let separatorTwo: UIView
    let coverUp: UIView
    
    let messageBox: UITextView
    let postButton: UIButton
    let cameraButton: UIButton
    let locationButton: UIButton
    
    let note: Note
    
    var keyboardFrame: CGRect
    
    init(note: Note) {
        // UI Elements
        timedateLabel = UILabel(frame: CGRectZero)
        changeDateLabel = UILabel(frame: CGRectZero)
        
        datePicker = UIDatePicker(frame: CGRectZero)
        
        separatorOne = UIView(frame: CGRectZero)
        
        hashtagsView = HashtagsView(frame: CGRectZero)
        
        separatorTwo = UIView(frame: CGRectZero)
        coverUp = UIView(frame: CGRectZero)
        
        messageBox = UITextView(frame: CGRectZero)
        postButton = UIButton(frame: CGRectZero)
        cameraButton = UIButton(frame: CGRectZero)
        locationButton = UIButton(frame: CGRectZero)
        
        // data
        self.note = note
        
        keyboardFrame = CGRectZero
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        self.title = note.user!.fullName
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]
        
        var closeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "closex")!, style: .Plain, target: self, action: "closeVC:")
        self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
        
        // configure date label
        let dateFormatter = NSDateFormatter()
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(note.timestamp)
        timedateLabel.sizeToFit()
        timedateLabel.frame.origin.x = labelInset
        timedateLabel.frame.origin.y = labelInset
        
        // configure change button
        changeDateLabel.text = "change"
        changeDateLabel.font = UIFont(name: "OpenSans", size: 12.5)
        changeDateLabel.textColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        changeDateLabel.sizeToFit()
        changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + changeDateLabel.frame.width)
        changeDateLabel.frame.origin.y = timedateLabel.frame.midY - changeDateLabel.frame.height / 2
        
        let changeDateH = labelInset + timedateLabel.frame.height + labelInset
        let changeDateView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: changeDateH))
        changeDateView.backgroundColor = UIColor.clearColor()
        let tap = UITapGestureRecognizer(target: self, action: "changeDatePressed:")
        changeDateView.addGestureRecognizer(tap)
        changeDateView.addSubview(timedateLabel)
        changeDateView.addSubview(changeDateLabel)
        
        self.view.addSubview(changeDateView)
        
        // configure date picker
        datePicker.datePickerMode = .DateAndTime
        datePicker.date = note.timestamp
        datePicker.frame.origin.x = 0
        datePicker.frame.origin.y = timedateLabel.frame.maxY + labelInset / 2
        datePicker.hidden = true
        datePicker.addTarget(self, action: "datePickerAction:", forControlEvents: .ValueChanged)
        
        self.view.addSubview(datePicker)
        
        // configure first separator
        separatorOne.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        separatorOne.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorOne.frame.origin.x = 0
        separatorOne.frame.origin.y = timedateLabel.frame.maxY + labelInset
        
        self.view.addSubview(separatorOne)
        
        // configure hashtags view
        hashtagsView.backgroundColor = UIColor.clearColor()
        hashtagsView.frame.size = CGSize(width: self.view.frame.width, height: expandedHashtagsViewH)
        hashtagsView.frame.origin.x = 0
        hashtagsView.frame.origin.y = separatorOne.frame.maxY
        hashtagsView.configureHashtagsView()
        
        self.view.addSubview(hashtagsView)
        
        // configure second separator
        separatorTwo.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        separatorTwo.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorTwo.frame.origin.x = 0
        separatorTwo.frame.origin.y = hashtagsView.frame.maxY
        
        self.view.addSubview(separatorTwo)
        
        // configure backround view to cover things
        coverUp.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        let coverUpH = self.view.frame.height - separatorTwo.frame.maxY
        coverUp.frame.size = CGSize(width: self.view.frame.width, height: coverUpH)
        coverUp.frame.origin = CGPoint(x: 0, y: separatorTwo.frame.maxY)
        
        self.view.addSubview(coverUp)
        
        // configure post button
        postButton.setAttributedTitle(NSAttributedString(string:"Save",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
        postButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        postButton.addTarget(self, action: "saveNote", forControlEvents: .TouchUpInside)
        postButton.frame.size = CGSize(width: 112, height: 41)
        postButton.frame.origin.x = self.view.frame.size.width - (labelInset + postButton.frame.width)
        postButton.frame.origin.y = self.view.frame.size.height - (labelInset + postButton.frame.height + 64)
        
        self.view.addSubview(postButton)
        
        // configure message box
        messageBox.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        messageBox.font = UIFont(name: "OpenSans", size: 17.5)!
        let hashtagBolder = HashtagBolder()
        let attributedText = hashtagBolder.boldHashtags(note.messagetext)
        messageBox.attributedText = attributedText
        let messageBoxW = self.view.frame.width - 2 * labelInset
        let messageBoxH = (postButton.frame.minY - separatorTwo.frame.maxY) - 2 * labelInset
        messageBox.frame.size = CGSize(width: messageBoxW, height: messageBoxH)
        messageBox.frame.origin.x = labelInset
        messageBox.frame.origin.y = separatorTwo.frame.maxY + labelInset
        messageBox.delegate = self
        messageBox.autocapitalizationType = UITextAutocapitalizationType.Sentences
        messageBox.autocorrectionType = UITextAutocorrectionType.No
        messageBox.spellCheckingType = UITextSpellCheckingType.Default
        messageBox.keyboardAppearance = UIKeyboardAppearance.Dark
        messageBox.keyboardType = UIKeyboardType.Default
        messageBox.returnKeyType = UIReturnKeyType.Default
        messageBox.secureTextEntry = false
        
        self.view.addSubview(messageBox)
        
        // configure camera button
        let camera = UIImage(named: "camera") as UIImage!
        cameraButton.setImage(camera, forState: .Normal)
        cameraButton.addTarget(self, action: "cameraPressed:", forControlEvents: .TouchUpInside)
        cameraButton.frame.size = camera.size
        let cameraX = 2 * labelInset
        let cameraY = postButton.frame.midY - cameraButton.frame.height / 2
        cameraButton.frame.origin = CGPoint(x: cameraX, y: cameraY)
        
//        self.view.addSubview(cameraButton)
        
        // configure location button
        let location = UIImage(named: "location") as UIImage!
        locationButton.setImage(location, forState: .Normal)
        locationButton.addTarget(self, action: "locationPressed:", forControlEvents: .TouchUpInside)
        locationButton.frame.size = location.size
        let locationX = cameraButton.frame.maxX + 2 * labelInset
        let locationY = postButton.frame.midY - locationButton.frame.height / 2
        locationButton.frame.origin = CGPoint(x: locationX, y: locationY)
        
//        self.view.addSubview(locationButton)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func closeVC(sender: UIBarButtonItem!) {
        if (note.messagetext != messageBox.text || note.timestamp != datePicker.date) {
            let alert = UIAlertController(title: "Save Changes?", message: "You have made changes to this note. Would you like to save these changes?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Discard",
                style: UIAlertActionStyle.Destructive,
                handler: {(alert: UIAlertAction!) in
                    self.view.endEditing(true)
                    self.closeDatePicker(false)
                    self.dismissViewControllerAnimated(true, completion: nil)}))
            alert.addAction(UIAlertAction(title: "Save",
                style: UIAlertActionStyle.Default,
                handler: {(alert: UIAlertAction!) in self.saveNote()}))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.view.endEditing(true)
            self.closeDatePicker(false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func changeDatePressed(sender: UIView!) {
        if (!datePicker.hidden) {
            closeDatePicker(false)
        } else {
            openDatePicker()
        }
    }
    
    func closeDatePicker(hashtagsAfter: Bool) {
        if (!datePicker.hidden && !isAnimating) {
            isAnimating = true
            UIView.animateWithDuration(0.2, animations: {
                self.datePicker.alpha = 0.0
            })
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                self.separatorOne.frame.origin.y = self.timedateLabel.frame.maxY + labelInset
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: expandedHashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.hashtagsView.frame.maxY
                let coverUpH = self.view.frame.height - self.separatorTwo.frame.maxY
                self.coverUp.frame.size = CGSize(width: self.view.frame.width, height: coverUpH)
                self.coverUp.frame.origin = CGPoint(x: 0, y: self.separatorTwo.frame.maxY)
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    self.datePicker.hidden = true
                    self.isAnimating = false
                    self.changeDateLabel.text = "change"
                    self.changeDateLabel.sizeToFit()
                    self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                    if (hashtagsAfter) {
                        self.toggleHashtags()
                    }
            })
        }
    }
    
    func openDatePicker() {
        if (datePicker.hidden && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                self.separatorOne.frame.origin.y = self.datePicker.frame.maxY + labelInset / 2
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: 0.0)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.separatorOne.frame.minY
                let coverUpH = self.view.frame.height - self.separatorTwo.frame.maxY
                self.coverUp.frame.size = CGSize(width: self.view.frame.width, height: coverUpH)
                self.coverUp.frame.origin = CGPoint(x: 0, y: self.separatorTwo.frame.maxY)
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    UIView.animateWithDuration(0.2, animations: {
                        self.datePicker.alpha = 1.0
                    })
                    self.datePicker.hidden = false
                    self.isAnimating = false
                    if (completed) {
                        self.changeDateLabel.text = "done"
                        self.changeDateLabel.sizeToFit()
                        self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                    }
            })
        }
    }
    
    func toggleHashtags() {
        if (hashtagsView.hashtagsCollapsed) {
            openHashtagsCompletely()
        } else {
            closeHashtagsPartially()
        }
    }
    
    func closeHashtagsPartially() {
        if (!hashtagsView.hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: condensedHashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.hashtagsView.linearHashtagArrangement()
                self.separatorTwo.frame.origin.y = self.hashtagsView.frame.maxY
                let coverUpH = self.view.frame.height - self.separatorTwo.frame.maxY
                self.coverUp.frame.size = CGSize(width: self.view.frame.width, height: coverUpH)
                self.coverUp.frame.origin = CGPoint(x: 0, y: self.separatorTwo.frame.maxY)
                if (UIDevice.currentDevice().modelName != "iPhone 4S") {
                    // Not an iPhone 4s
                    
                    self.postButton.frame.origin.y = self.view.frame.height - (self.keyboardFrame.height + labelInset + self.postButton.frame.height)
                    self.cameraButton.frame.origin.y = self.postButton.frame.midY - self.cameraButton.frame.height / 2
                    self.locationButton.frame.origin.y = self.postButton.frame.midY - self.locationButton.frame.height / 2
                    let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                    self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                    self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                } else {
                    // An iPhone 4S
                    
                    let messageBoxH = self.view.frame.height - (self.separatorTwo.frame.maxY + self.keyboardFrame.height + 2 * labelInset)
                    self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                    self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                }
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        if (UIDevice.currentDevice().modelName == "iPhone 4S") {
                            self.changeDateLabel.text = "done"
                            self.changeDateLabel.font = UIFont(name: "OpenSans-Bold", size: 12.5)!
                            self.changeDateLabel.sizeToFit()
                            self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                        }
                        
                        self.hashtagsView.hashtagsCollapsed = true
                    }
            })
        }
    }
    
    func openHashtagsCompletely() {
        if (hashtagsView.hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: expandedHashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.hashtagsView.pageHashtagArrangement()
                self.separatorTwo.frame.origin.y = self.hashtagsView.frame.maxY
                let coverUpH = self.view.frame.height - self.separatorTwo.frame.maxY
                self.coverUp.frame.size = CGSize(width: self.view.frame.width, height: coverUpH)
                self.coverUp.frame.origin = CGPoint(x: 0, y: self.separatorTwo.frame.maxY)
                self.postButton.frame.origin.y = self.view.frame.height - (labelInset + self.postButton.frame.height)
                self.cameraButton.frame.origin.y = self.postButton.frame.midY - self.cameraButton.frame.height / 2
                self.locationButton.frame.origin.y = self.postButton.frame.midY - self.locationButton.frame.height / 2
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        if (UIDevice.currentDevice().modelName == "iPhone 4S") {
                            self.changeDateLabel.text = "change"
                            self.changeDateLabel.font = UIFont(name: "OpenSans", size: 12.5)!
                            self.changeDateLabel.sizeToFit()
                            self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                        }
                        
                        self.hashtagsView.hashtagsCollapsed = false
                    }
            })
        }
    }
    
    func datePickerAction(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(datePicker.date)
        timedateLabel.sizeToFit()
    }
    
    func cameraPressed(sender: UIButton!) {
        let alert = UIAlertController(title: "Photos Not Supported", message: "Unfortunately, including photos in a note is not currently supported. We are working hard to add this feature soon.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func locationPressed(sender: UIButton!) {
        let alert = UIAlertController(title: "Location Not Supported", message: "Unfortunately, including location in a note is not currently supported. We are working hard to add this feature soon.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveNote() {
        if (messageBox.text != "Type a note..." && !messageBox.text.isEmpty) {
            self.note.messagetext = self.messageBox.text
            self.note.timestamp = self.datePicker.date
            
            // Identify hashtags
            let words = self.note.messagetext.componentsSeparatedByString(" ")
            
            for word in words {
                if (word.hasPrefix("#")) {
                    self.hashtagsView.handleHashtagCoreData(word)
                }
            }
            
            self.view.endEditing(true)
            self.closeDatePicker(false)
            let notification = NSNotification(name: "saveNote", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func hashtagPressed(notification: NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let hashtag = userInfo["hashtag"]!
        if (messageBox.text == defaultMessage) {
            messageBox.text = hashtag
        } else {
            if (self.messageBox.text.hasSuffix(" ")) {
                messageBox.text = messageBox.text + hashtag
            } else {
                messageBox.text = messageBox.text + " " + hashtag
            }
        }
        textViewDidChange(messageBox)
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text != "Type a note...") {
            
            let hashtagBolder = HashtagBolder()
            let attributedText = hashtagBolder.boldHashtags(textView.text)
            
            textView.attributedText = attributedText
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == "Type a note...") {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type a note..."
            textView.textColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            let touchLocation = touch.locationInView(self.view)
            let viewFrame = self.view.convertRect(hashtagsView.frame, fromView: hashtagsView.superview)
            
            if !CGRectContainsPoint(viewFrame, touchLocation) {
                if (!isAnimating) {
                    view.endEditing(true)
                }
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        if (!datePicker.hidden) {
            self.closeDatePicker(true)
        } else {
            self.closeHashtagsPartially()
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.openHashtagsCompletely()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}
