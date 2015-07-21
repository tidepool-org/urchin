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

class EditNoteViewController: UIViewController, UITextViewDelegate, UIAlertViewDelegate {
    
    // UI Elements
    
    // date & time, change label
    let timedateLabel: UILabel
    let changeDateLabel: UILabel
    
    // datePicker helpers, and datePicker
    var datePickerShown: Bool = false
    var isAnimating: Bool = false
    let datePicker: UIDatePicker
    
    // Separator between date and hashtagsView
    let separatorOne: UIView
    
    //hashtagsView for appending hashtags to messages
    let hashtagsView: HashtagsView
    
    // Separator between hashtags and messageBox
    let separatorTwo: UIView
    
    // Cover so hashtags are partially hidden when condensed
    //      might not be necessary now that hashtags jump to linear arrangement
    let coverUp: UIView
    
    // More UI Elements
    let messageBox: UITextView
    let postButton: UIButton
    let cameraButton: UIButton
    let locationButton: UIButton
    
    // Original note, edited note, and the full name for the group
    let note: Note
    let editedNote: Note
    let groupFullName: String
    
    // Keyboard frame for positioning UI Elements
    var keyboardFrame: CGRect
    
    init(note: Note, groupFullName: String) {
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
        self.editedNote = Note()
        editedNote.createdtime = note.createdtime
        editedNote.messagetext = note.messagetext
        self.groupFullName = groupFullName
        
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
        
        // Set background color to light grey color for dark navigationBar
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        // If device is running < iOS 8.0, make navigationBar NOT translucent
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0 {
            self.navigationController?.navigationBar.translucent = false
        }
        
        // Configure title with group / team name
        // Title does not need tapGesture actions --> group is fixed
        self.title = groupFullName
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]
        
        // Configure close button (always present)
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
        separatorOne.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        separatorOne.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorOne.frame.origin.x = 0
        separatorOne.frame.origin.y = timedateLabel.frame.maxY + labelInset
        
        self.view.addSubview(separatorOne)
        
        // configure hashtags view (initially completely expanded)
        hashtagsView.backgroundColor = UIColor.clearColor()
        hashtagsView.frame.size = CGSize(width: self.view.frame.width, height: expandedHashtagsViewH)
        hashtagsView.frame.origin.x = 0
        hashtagsView.frame.origin.y = separatorOne.frame.maxY
        hashtagsView.configureHashtagsView()
        
        self.view.addSubview(hashtagsView)
        
        // configure second separator between hashtags and messageBox
        separatorTwo.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        separatorTwo.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorTwo.frame.origin.x = 0
        separatorTwo.frame.origin.y = hashtagsView.frame.maxY
        
        self.view.addSubview(separatorTwo)
        
        // configure backround view to cover things
        //      behind message box, so hashtags don't show in that section
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
        //      initializes with default placeholder text
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
        
        // camera button not added to view. feature not yet supported.
//        self.view.addSubview(cameraButton)
        
        // configure location button
        let location = UIImage(named: "location") as UIImage!
        locationButton.setImage(location, forState: .Normal)
        locationButton.addTarget(self, action: "locationPressed:", forControlEvents: .TouchUpInside)
        locationButton.frame.size = location.size
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
        if (note.messagetext != messageBox.text || note.timestamp != datePicker.date) {
            // If the note has been changed, show an alert
            let alert = UIAlertView()
            alert.delegate = self
            alert.title = "Save Changes?"
            alert.message = "You have made changes to this note. Would you like to save these changes?"
            alert.addButtonWithTitle("Discard")
            alert.addButtonWithTitle("Save")
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
    
    // Handle alert view events
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            println("Discard")
            
            let notification = NSNotification(name: "doneEditing", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            self.view.endEditing(true)
            self.closeDatePicker(false)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            break
        case 1:
            println("Save")
            
            self.saveNote()
            
            break
        default:
            println("uh oh")
            break
        }
    }
    
    // Toggle the datepicker open or closed depending on if it is currently showing
    // Called by the changeDateView
    func changeDatePressed(sender: UIView!) {
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
            UIView.animateWithDuration(0.2, animations: {
                self.datePicker.alpha = 0.0
            })
            // Move all affected UI elements with animation
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                // UI element location (and some sizing)
                self.separatorOne.frame.origin.y = self.timedateLabel.frame.maxY + labelInset
                //          note: hashtagsView completely expanded
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
                    // On completion, hide datePicker completely
                    self.datePicker.hidden = true
                    self.isAnimating = false
                    // change the changeDateLabel back to 'change'
                    self.changeDateLabel.text = "change"
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
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                // UI element location (and some sizing)
                self.separatorOne.frame.origin.y = self.datePicker.frame.maxY + labelInset / 2
                //          note: hashtags view completely closed, with height 0.0
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
                    // On completion, fade in the datePicker
                    UIView.animateWithDuration(0.2, animations: {
                        self.datePicker.alpha = 1.0
                    })
                    // Set datePicker to show
                    self.datePicker.hidden = false
                    self.isAnimating = false
                    if (completed) {
                        // change the changeDateLabel to prompt done/close action
                        self.changeDateLabel.text = "done"
                        self.changeDateLabel.sizeToFit()
                        self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                    }
            })
        }
    }
    
    // Toggle the hashtags view between open completely and condensed
    func toggleHashtags() {
        if (hashtagsView.hashtagsCollapsed) {
            openHashtagsCompletely()
        } else {
            closeHashtagsPartially()
        }
    }
    
    // Animations for resizing the hashtags view to be condensed
    func closeHashtagsPartially() {
        if (!hashtagsView.hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                // size hashtags view to condensed size
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: condensedHashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.hashtagsView.linearHashtagArrangement()
                // position affected UI elements
                self.separatorTwo.frame.origin.y = self.hashtagsView.frame.maxY
                let coverUpH = self.view.frame.height - self.separatorTwo.frame.maxY
                self.coverUp.frame.size = CGSize(width: self.view.frame.width, height: coverUpH)
                self.coverUp.frame.origin = CGPoint(x: 0, y: self.separatorTwo.frame.maxY)
                if (UIDevice.currentDevice().modelName != "iPhone 4S") {
                    // Not an iPhone 4s
                    
                    // Move up controls
                    self.postButton.frame.origin.y = self.view.frame.height - (self.keyboardFrame.height + labelInset + self.postButton.frame.height)
                    self.cameraButton.frame.origin.y = self.postButton.frame.midY - self.cameraButton.frame.height / 2
                    self.locationButton.frame.origin.y = self.postButton.frame.midY - self.locationButton.frame.height / 2
                    // REsize messageBox
                    let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                    self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                    self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                } else {
                    // An iPhone 4S
                    
                    // Do not move up controls, just resize messageBox
                    let messageBoxH = self.view.frame.height - (self.separatorTwo.frame.maxY + self.keyboardFrame.height + 2 * labelInset)
                    self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                    self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                }
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        // For iPhone 4S, change the button to be 'done'
                        if (UIDevice.currentDevice().modelName == "iPhone 4S") {
                            self.changeDateLabel.text = "done"
                            self.changeDateLabel.font = UIFont(name: "OpenSans-Bold", size: 12.5)!
                            self.changeDateLabel.sizeToFit()
                            self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                        }
                        
                        // hashtags now collapsed
                        self.hashtagsView.hashtagsCollapsed = true
                    }
            })
        }
    }
    
    // Open hashtagsView completely to full view with animation
    func openHashtagsCompletely() {
        if (hashtagsView.hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                // hashtagsView has expanded size
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: expandedHashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.hashtagsView.pageHashtagArrangement()
                // position affected UI elements
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
                            // If iPhone 4S, change back from 'done' to 'change'
                            self.changeDateLabel.text = "change"
                            self.changeDateLabel.font = UIFont(name: "OpenSans", size: 12.5)!
                            self.changeDateLabel.sizeToFit()
                            self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                        }
                        
                        // hashtagsView no longer collapsed
                        self.hashtagsView.hashtagsCollapsed = false
                    }
            })
        }
    }
    
    // Called when date picker date has changed
    func datePickerAction(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(datePicker.date)
        timedateLabel.sizeToFit()
    }
    
    // Camera functionality currently not developed. Just shows alert if camera button pressed.
    func cameraPressed(sender: UIButton!) {
        let alert = UIAlertController(title: "Photos Not Supported", message: "Unfortunately, including photos in a note is not currently supported. We are working hard to add this feature soon.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Location functionality currently not developed. Just shows alert if location button pressed.
    func locationPressed(sender: UIButton!) {
        let alert = UIAlertController(title: "Location Not Supported", message: "Unfortunately, including location in a note is not currently supported. We are working hard to add this feature soon.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // saveNote action from saveNoteButton
    func saveNote() {
        if ((note.messagetext != messageBox.text || note.timestamp != datePicker.date) && messageBox.text != defaultMessage && !messageBox.text.isEmpty) {
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
                    self.hashtagsView.handleHashtagCoreData(newword)
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
        // unwrap the hashtag from userInfo
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let hashtag = userInfo["hashtag"]!
        
        // append hashtag to messageBox.text
        if (messageBox.text == defaultMessage) {
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
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text != defaultMessage) {
            // use hashtagBolder extension to bold the hashtags
            let hashtagBolder = HashtagBolder()
            let attributedText = hashtagBolder.boldHashtags(textView.text)
            
            // set textView (messageBox) text to new attributed text
            textView.attributedText = attributedText
        }
        if ((note.messagetext != textView.text || note.timestamp != datePicker.date) && textView.text != defaultMessage && !textView.text.isEmpty) {
            postButton.alpha = 1.0
        } else {
            postButton.alpha = 0.5
        }
    }
    
    // textViewDidBeginEditing, clear the messageBox if default message
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == defaultMessage) {
            textView.text = nil
        }
    }
    
    // textViewDidEndEditing, if empty set back to default message
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultMessage
            textView.textColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
        }
    }
    
    // Handle touches in the view
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            // determine if the touch (first touch) is in the hashtagsView
            let touchLocation = touch.locationInView(self.view)
            let viewFrame = self.view.convertRect(hashtagsView.frame, fromView: hashtagsView.superview)
            
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
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}
