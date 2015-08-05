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

class EditNoteViewController: UIViewController {
    
    // UI Elements
    
    // date & time, change label
    let timedateLabel: UILabel = UILabel()
    let changeDateLabel: UILabel = UILabel()
    
    // datePicker helpers, and datePicker
    var datePickerShown: Bool = false
    var isAnimating: Bool = false
    let datePicker: UIDatePicker = UIDatePicker()
    
    // Separator between date and hashtagsView
    let separatorOne: UIView = UIView()
    
    //hashtagsView for appending hashtags to messages
    let hashtagsScrollView: HashtagsScrollView
    
    // Separator between hashtags and messageBox
    let separatorTwo: UIView = UIView()
    
    // More UI Elements
    let messageBox: UITextView = UITextView()
    let postButton: UIButton = UIButton()
    let cameraButton: UIButton = UIButton()
    let locationButton: UIButton = UIButton()
    
    let apiConnector: APIConnector
    
    // Original note, edited note, and the full name for the group
    let note: Note
    let editedNote: Note
    let groupFullName: String
    let previousDate: NSDate
    
    // Keyboard frame for positioning UI Elements
    var keyboardFrame: CGRect = CGRectZero
    
    init(apiConnector: APIConnector, note: Note, groupFullName: String) {
        
        self.apiConnector = apiConnector
        self.hashtagsScrollView = HashtagsScrollView(apiConnector: apiConnector)
        
        // data
        self.note = note
        self.editedNote = Note()
        editedNote.createdtime = note.createdtime
        editedNote.messagetext = note.messagetext
        self.groupFullName = groupFullName
        
        self.previousDate = note.timestamp
        
        // Initialize keyboard frame of size Zero
        keyboardFrame = CGRectZero
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set status bar to light color for dark navigationBar
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color to light grey color
        self.view.backgroundColor = lightGreyColor
        
        // If device is running < iOS 8.0, make navigationBar NOT translucent
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0 {
            self.navigationController?.navigationBar.translucent = false
        }
        
        // Configure title with group / team name
        // Title does not need tapGesture actions --> group is fixed
        self.title = groupFullName
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: navBarTitleColor, NSFontAttributeName: mediumRegularFont]
        
        // Configure close button (always present)
        var closeButton: UIBarButtonItem = UIBarButtonItem(image: closeX, style: .Plain, target: self, action: "closeVC:")
        self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
        
        // configure date label
        let dateFormatter = NSDateFormatter()
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(note.timestamp)
        timedateLabel.sizeToFit()
        timedateLabel.frame.origin.x = labelInset
        timedateLabel.frame.origin.y = labelInset
        
        // configure change button
        changeDateLabel.text = changeDateText
        changeDateLabel.font = smallRegularFont
        changeDateLabel.textColor = tealColor
        changeDateLabel.sizeToFit()
        changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + changeDateLabel.frame.width)
        changeDateLabel.frame.origin.y = timedateLabel.frame.midY - changeDateLabel.frame.height / 2
        
        // Create a whole view to add the date label and change label to
        //      --> user can click anywhere in view to trigger change date animation
        let changeDateH = labelInset + timedateLabel.frame.height + labelInset
        let changeDateView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: changeDateH))
        changeDateView.backgroundColor = UIColor.clearColor()
        // tapGesture triggers animation
        let tap = UITapGestureRecognizer(target: self, action: "changeDatePressed:")
        changeDateView.addGestureRecognizer(tap)
        // add labels to view
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
        
        // configure first separator between date and hashtags
        separatorOne.backgroundColor = darkestGreyColor
        separatorOne.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorOne.frame.origin.x = 0
        separatorOne.frame.origin.y = timedateLabel.frame.maxY + labelInset
        
        self.view.addSubview(separatorOne)
        
        // configure hashtags view --> begins with expanded height
        hashtagsScrollView.frame.size = CGSize(width: self.view.frame.width, height: expandedHashtagsViewH)
        hashtagsScrollView.frame.origin.x = 0
        hashtagsScrollView.frame.origin.y = separatorOne.frame.maxY
        hashtagsScrollView.configureHashtagsScrollView()
        
        view.addSubview(hashtagsScrollView)
        
        // configure second separator between hashtags and messageBox
        separatorTwo.backgroundColor = darkestGreyColor
        separatorTwo.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorTwo.frame.origin.x = 0
        separatorTwo.frame.origin.y = hashtagsScrollView.frame.maxY
        
        self.view.addSubview(separatorTwo)
        
        // configure post button
        postButton.setAttributedTitle(NSAttributedString(string: postButtonSave,
            attributes:[NSForegroundColorAttributeName: postButtonTextColor, NSFontAttributeName: mediumRegularFont]), forState: UIControlState.Normal)
        postButton.backgroundColor = tealColor
        postButton.alpha = 0.5
        postButton.addTarget(self, action: "saveNote", forControlEvents: .TouchUpInside)
        postButton.frame.size = CGSize(width: postButtonW, height: postButtonH)
        postButton.frame.origin.x = self.view.frame.size.width - (labelInset + postButton.frame.width)
        let navBarH = self.navigationController!.navigationBar.frame.size.height
        let statusBarH = UIApplication.sharedApplication().statusBarFrame.size.height
        postButton.frame.origin.y = self.view.frame.size.height - (labelInset + postButton.frame.height + navBarH + statusBarH)
        
        self.view.addSubview(postButton)
        
        // configure message box
        //      initializes with default placeholder text
        messageBox.backgroundColor = lightGreyColor
        messageBox.font = mediumRegularFont
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
        cameraButton.setImage(cameraImage, forState: .Normal)
        cameraButton.addTarget(self, action: "cameraPressed:", forControlEvents: .TouchUpInside)
        cameraButton.frame.size = cameraImage.size
        let cameraX = 2 * labelInset
        let cameraY = postButton.frame.midY - cameraButton.frame.height / 2
        cameraButton.frame.origin = CGPoint(x: cameraX, y: cameraY)
        
        // camera button not added to view. feature not yet supported.
//        self.view.addSubview(cameraButton)
        
        // configure location button
        locationButton.setImage(locationImage, forState: .Normal)
        locationButton.addTarget(self, action: "locationPressed:", forControlEvents: .TouchUpInside)
        locationButton.frame.size = locationImage.size
        let locationX = cameraButton.frame.maxX + 2 * labelInset
        let locationY = postButton.frame.midY - locationButton.frame.height / 2
        locationButton.frame.origin = CGPoint(x: locationX, y: locationY)
        
        // location button not added to view. feature not yet supported.
//        self.view.addSubview(locationButton)
        
        // Add observers for notificationCenter to handle keyboard events
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        // Add an observer to notificationCenter to handle hashtagPress events from HashtagsView
        notificationCenter.addObserver(self, selector: "hashtagPressed:", name: "hashtagPressed", object: nil)
    }

    // close the VC on button press from leftBarButtonItem
    func closeVC(sender: UIBarButtonItem!) {
        self.apiConnector.trackMetric("Clicked Close Add or Edit Note")
        
        if (note.messagetext != messageBox.text || note.timestamp != datePicker.date) {
            // If the note has been changed, show an alert
            let alert = UIAlertView()
            alert.delegate = self
            alert.title = editAlertTitle
            alert.message = editAlertMessage
            alert.addButtonWithTitle(editAlertDiscard)
            alert.addButtonWithTitle(editAlertSave)
            alert.show()
        } else {
            // Note has not been edited, dismiss the VC
            let notification = NSNotification(name: "doneEditing", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            self.view.endEditing(true)
            self.closeDatePicker(false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Toggle the datepicker open or closed depending on if it is currently showing
    // Called by the changeDateView
    func changeDatePressed(sender: UIView!) {
        self.apiConnector.trackMetric("Clicked Change Date")

        if (!datePicker.hidden) {
            closeDatePicker(false)
        } else {
            openDatePicker()
        }
    }
    
    // Closes the date picker with an animation
    //      if hashtagsAfter, will toggleHashtags following completion
    func closeDatePicker(hashtagsAfter: Bool) {
        if (!datePicker.hidden && !isAnimating) {
            isAnimating = true
            // Fade out the date picker with an animation
            UIView.animateWithDuration(datePickerFadeTime, animations: {
                self.datePicker.alpha = 0.0
            })
            // Move all affected UI elements with animation
            UIView.animateKeyframesWithDuration(animationTime, delay: 0.0, options: nil, animations: { () -> Void in
                // UI element location (and some sizing)
                self.separatorOne.frame.origin.y = self.timedateLabel.frame.maxY + labelInset
                //          note: hashtagsView completely expanded
                self.hashtagsScrollView.pagedHashtagsView()
                self.hashtagsScrollView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.hashtagsScrollView.frame.maxY
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    // On completion, hide datePicker completely
                    self.datePicker.hidden = true
                    self.isAnimating = false
                    // change the changeDateLabel back to 'change'
                    self.changeDateLabel.text = changeDateText
                    self.changeDateLabel.sizeToFit()
                    self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                    if (hashtagsAfter) {
                        self.toggleHashtags()
                    }
            })
        }
    }
    
    // Opens the date picker with an animation
    func openDatePicker() {
        if (datePicker.hidden && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(animationTime, delay: 0.0, options: nil, animations: { () -> Void in
                
                // UI element location (and some sizing)
                self.separatorOne.frame.origin.y = self.datePicker.frame.maxY + labelInset / 2
                //          note: hashtags view completely closed, with height 0.0
                self.hashtagsScrollView.sizeZeroHashtagsView()
                self.hashtagsScrollView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.separatorOne.frame.minY
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    // On completion, fade in the datePicker
                    UIView.animateWithDuration(datePickerFadeTime, animations: {
                        self.datePicker.alpha = 1.0
                    })
                    // Set datePicker to show
                    self.datePicker.hidden = false
                    self.isAnimating = false
                    if (completed) {
                        // change the changeDateLabel to prompt done/close action
                        self.changeDateLabel.text = doneDateText
                        self.changeDateLabel.sizeToFit()
                        self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                    }
            })
        }
    }
    
    // Toggle the hashtags view between open completely and condensed
    func toggleHashtags() {
        if (hashtagsScrollView.hashtagsCollapsed) {
            openHashtagsCompletely()
        } else {
            closeHashtagsPartially()
        }
    }
    
    // Animations for resizing the hashtags view to be condensed
    func closeHashtagsPartially() {
        if (!hashtagsScrollView.hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(animationTime, delay: 0.0, options: nil, animations: { () -> Void in
                
                // size hashtags view to condensed size
                self.hashtagsScrollView.linearHashtagsView()
                self.hashtagsScrollView.frame.origin.y = self.separatorOne.frame.maxY
                // position affected UI elements
                self.separatorTwo.frame.origin.y = self.hashtagsScrollView.frame.maxY
                var separatorToBottom: CGFloat = self.view.frame.height - self.separatorTwo.frame.maxY
                if (separatorToBottom > 300) {
                    // Larger device
                    
                    // Move up controls
                    self.postButton.frame.origin.y = self.view.frame.height - (self.keyboardFrame.height + labelInset + self.postButton.frame.height)
                    self.cameraButton.frame.origin.y = self.postButton.frame.midY - self.cameraButton.frame.height / 2
                    self.locationButton.frame.origin.y = self.postButton.frame.midY - self.locationButton.frame.height / 2
                    // Resize messageBox
                    let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                    self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                    self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                } else {
                    // Smaller device
                    
                    // Do not move up controls, just resize messageBox
                    let messageBoxH = self.view.frame.height - (self.separatorTwo.frame.maxY + self.keyboardFrame.height + 2 * labelInset)
                    self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                    self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                }
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        var separatorToBottom: CGFloat = self.view.frame.height - self.separatorTwo.frame.maxY
                        if (separatorToBottom < 300) {
                            self.changeDateLabel.text = doneDateText
                            self.changeDateLabel.font = smallBoldFont
                            self.changeDateLabel.sizeToFit()
                            self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                        }
                        
                        // hashtags now collapsed
                        self.hashtagsScrollView.hashtagsCollapsed = true
                    }
            })
        }
    }
    
    // Open hashtagsView completely to full view with animation
    func openHashtagsCompletely() {
        if (hashtagsScrollView.hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(animationTime, delay: 0.0, options: nil, animations: { () -> Void in
                
                // hashtagsView has expanded size
                self.hashtagsScrollView.pagedHashtagsView()
                self.hashtagsScrollView.frame.origin.y = self.separatorOne.frame.maxY
                // position affected UI elements
                self.separatorTwo.frame.origin.y = self.hashtagsScrollView.frame.maxY
                self.postButton.frame.origin.y = self.view.frame.height - (labelInset + self.postButton.frame.height)
                self.cameraButton.frame.origin.y = self.postButton.frame.midY - self.cameraButton.frame.height / 2
                self.locationButton.frame.origin.y = self.postButton.frame.midY - self.locationButton.frame.height / 2
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        if (self.changeDateLabel.text == doneDateText) {
                            // If label says 'done', change back to 'change'
                            self.changeDateLabel.text = changeDateText
                            self.changeDateLabel.font = smallRegularFont
                            self.changeDateLabel.sizeToFit()
                            self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                        }
                        
                        // hashtagsView no longer collapsed
                        self.hashtagsScrollView.hashtagsCollapsed = false
                    }
            })
        }
    }
    
    // Called when date picker date has changed
    func datePickerAction(sender: UIDatePicker) {
        let calendar = NSCalendar.currentCalendar()
        let compCurr = calendar.components((.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute), fromDate: datePicker.date)
        let compWas = calendar.components((.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute), fromDate: previousDate)
        
        if (compCurr.day != compWas.day || compCurr.month != compWas.month || compCurr.year != compWas.year) {
            self.apiConnector.trackMetric("Date Changed")
        }
        if (compCurr.hour != compWas.hour) {
            self.apiConnector.trackMetric("Hour Changed")
        }
        if (compCurr.minute != compWas.minute) {
            self.apiConnector.trackMetric("Minute Changed")
        }
        
        let dateFormatter = NSDateFormatter()
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(datePicker.date)
        timedateLabel.sizeToFit()
        textViewDidChange(messageBox)
    }
    
    // Camera functionality currently not developed.
    func cameraPressed(sender: UIButton!) {
        // Do nothing
    }
    
    // Location functionality currently not developed.
    func locationPressed(sender: UIButton!) {
        // Do nothing
    }
    
    // saveNote action from saveNoteButton
    func saveNote() {
        if ((note.messagetext != messageBox.text || note.timestamp != datePicker.date) && messageBox.text != defaultMessage && !messageBox.text.isEmpty) {
            self.apiConnector.trackMetric("Clicked Save Note")
            
            // if messageBox has text (not default message or empty) --> set the note to have values
            // groupid does not change
            self.editedNote.messagetext = self.messageBox.text
            self.editedNote.timestamp = self.datePicker.date
            
            // Identify hashtags
            let words = self.editedNote.messagetext.componentsSeparatedByString(" ")
            
            for word in words {
                if (word.hasPrefix("#")) {
                    // hashtag found!
                    // algorithm to determine length of hashtag without symbols or punctuation (common practice)
                    var charsInHashtag: Int = 0
                    let symbols = NSCharacterSet.symbolCharacterSet()
                    let punctuation = NSCharacterSet.punctuationCharacterSet()
                    for char in word.unicodeScalars {
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
                    
                    let newword = (word as NSString).substringToIndex(charsInHashtag)
                    
                    // Save the hashtag in CoreData
                    self.hashtagsScrollView.hashtagsView.handleHashtagCoreData(newword)
                }
            }
            
            // End editing and close the datePicker
            self.view.endEditing(true)
            self.closeDatePicker(false)
            
            let notification = NSNotification(name: "doneEditing", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            // Send notification to NotesVC to handle edited note
            let notificationTwo = NSNotification(name: "saveNote", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notificationTwo)
            
            // close the VC
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Handle hashtagPressed notification from hashtagsView (hashtag button was pressed)
    func hashtagPressed(notification: NSNotification) {
        
        self.apiConnector.trackMetric("Clicked Hashtag")

        // unwrap the hashtag from userInfo
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let hashtag = userInfo["hashtag"]!
        
        // append hashtag to messageBox.text
        if (messageBox.text == defaultMessage || messageBox.text.isEmpty) {
            // currently default message
            messageBox.text = hashtag
        } else {
            // not default message, check if there's already a space
            if (self.messageBox.text.hasSuffix(" ")) {
                // already a space, append hashtag
                messageBox.text = messageBox.text + hashtag
            } else {
                // no space yet, throw a space in before hashtag
                messageBox.text = messageBox.text + " " + hashtag
            }
        }
        // call textViewDidChange to format hashtags with bolding
        textViewDidChange(messageBox)
    }
    
    // Handle touches in the view
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            // determine if the touch (first touch) is in the hashtagsView
            let touchLocation = touch.locationInView(self.view)
            let viewFrame = self.view.convertRect(hashtagsScrollView.frame, fromView: hashtagsScrollView.superview)
            
            // if outside hashtagsView, endEditing, close keyboard, animate, etc.
            if !CGRectContainsPoint(viewFrame, touchLocation) {
                if (!isAnimating) {
                    view.endEditing(true)
                }
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    // UIKeyboardWillShowNotification
    func keyboardWillShow(notification: NSNotification) {
        // Take the keyboardFrame for positioning
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        if (!datePicker.hidden) {
            // datePicker shown, close it, then condense the hashtags
            self.closeDatePicker(true)
        } else {
            // condense the hashtags
            self.closeHashtagsPartially()
        }
    }
    
    // UIKeyboardDidShowNotification
    func keyboardDidShow(notification: NSNotification) {
        // Take the keyboard frame for positioning
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    }
    
    // UIKeyboardWillHideNotification
    func keyboardWillHide(notification: NSNotification) {
        // Open up the hashtagsView all the way!
        self.openHashtagsCompletely()
    }
    
    // Lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
}
