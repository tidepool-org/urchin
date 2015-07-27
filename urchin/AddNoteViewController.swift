//
//  AddNoteView.swift
//  urchin
//
//  Created by Ethan Look on 7/8/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let hashtagHeight: CGFloat = 36.0
let expandedHashtagsViewH: CGFloat = 2 * labelInset + 3 * hashtagHeight + 3 * labelSpacing
let condensedHashtagsViewH: CGFloat = 2 * labelInset + hashtagHeight
let defaultMessage: String = "What's going on?"

class AddNoteViewController: UIViewController {
    
    // DropDownMenu
    var dropDownMenu: UITableView!
    // Helpers for dropDownMenu and Animations
    var isDropDownDisplayed: Bool = false
    var isDropDownAnimating: Bool = false
    var dropDownHeight: CGFloat
    // Overlay to go with dropDownMenu
    var opaqueOverlay: UIView!
    var overlayHeight: CGFloat = 0
    
    // Global so it can be removed and added back at will
    let closeButton: UIBarButtonItem = UIBarButtonItem()
    
    // Current time and 'button' to change time
    let timedateLabel: UILabel = UILabel()
    let changeDateLabel: UILabel = UILabel()
    
    // datePicker and helpers for animation
    var datePickerShown: Bool = false
    var isAnimating: Bool = false
    let datePicker: UIDatePicker = UIDatePicker()
    
    // Separator between date/time and hashtags
    let separatorOne: UIView = UIView()
    
    // hashtagsView for putting hashtags in your messages
    let hashtagsScrollView: HashtagsScrollView = HashtagsScrollView()
    
    // Separator between hashtags and messageBox
    let separatorTwo: UIView = UIView()
    
    // UI Elements
    let messageBox: UITextView = UITextView()
    let postButton: UIButton = UIButton()
    let cameraButton: UIButton = UIButton()
    let locationButton: UIButton = UIButton()
    
    // Data
    let note: Note
    var group: User
    var groups: [User]
    let user: User
    
    // Keyboard frame for positioning UI Elements, initially zero
    var keyboardFrame: CGRect = CGRectZero
    
    init(user: User, group: User, groups: [User]) {
        
        // UI Elements
        self.dropDownHeight = CGFloat(groups.count) * userCellHeight + CGFloat(groups.count-1)*userCellThinSeparator
        
        // data
        note = Note()
        note.user = user
        note.groupid = group.userid
        note.messagetext = ""
        self.group = group
        self.groups = groups
        self.user = user
        
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
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        // If device is running < iOS 8.0, make navigationBar NOT translucent
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0 {
            self.navigationController?.navigationBar.translucent = false
        }
        
        // Configure title to initial group (may be changed later with dropDown)
        configureTitleView(group.fullName!)
        
        // Configure 'x' to close VC
        closeButton.image = UIImage(named: "closex")!
        closeButton.style = .Plain
        closeButton.target = self
        closeButton.action = "closeVC:"
        // navigationBar begins with leftBarButtonItem to close VC
        self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
        
        // Configure rightDropDownMenuButton to trigger dropDownMenu toggle
        var rightDropDownMenuButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "down"), style: .Plain, target: self, action: "dropDownMenuPressed")
        self.navigationItem.setRightBarButtonItem(rightDropDownMenuButton, animated: true)
    
        // configure date label
        let dateFormatter = NSDateFormatter()
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(note.timestamp)
        timedateLabel.sizeToFit()
        timedateLabel.frame.origin.x = labelInset
        timedateLabel.frame.origin.y = labelInset
        
        // configure change date label
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
        // tapGesture in view triggers animation
        let tap = UITapGestureRecognizer(target: self, action: "changeDatePressed:")
        changeDateView.addGestureRecognizer(tap)
        // add labels to view
        changeDateView.addSubview(timedateLabel)
        changeDateView.addSubview(changeDateLabel)
        
        self.view.addSubview(changeDateView)
        
        // configure date picker
        datePicker.datePickerMode = .DateAndTime
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
        
        // configure hashtags view --> begins with expanded height
        hashtagsScrollView.frame.size = CGSize(width: self.view.frame.width, height: expandedHashtagsViewH)
        hashtagsScrollView.frame.origin.x = 0
        hashtagsScrollView.frame.origin.y = separatorOne.frame.maxY
        hashtagsScrollView.configureHashtagsScrollView()
        
        view.addSubview(hashtagsScrollView)
        
        // configure second separator between hashtags and messageBox
        separatorTwo.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        separatorTwo.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorTwo.frame.origin.x = 0
        separatorTwo.frame.origin.y = hashtagsScrollView.frame.maxY
        
        self.view.addSubview(separatorTwo)
        
        // configure post button
        postButton.setAttributedTitle(NSAttributedString(string:"Post",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
        postButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        postButton.alpha = 0.5
        postButton.addTarget(self, action: "postNote:", forControlEvents: .TouchUpInside)
        postButton.frame.size = CGSize(width: 112, height: 41)
        postButton.frame.origin.x = self.view.frame.size.width - (labelInset + postButton.frame.width)
        postButton.frame.origin.y = self.view.frame.size.height - (labelInset + postButton.frame.height + 64)
        
        self.view.addSubview(postButton)
        
        // configure message box
        //      initializes with default placeholder text
        messageBox.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        messageBox.font = UIFont(name: "OpenSans", size: 17.5)!
        messageBox.text = defaultMessage
        messageBox.textColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
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
        
        // Configure overlay for dropDownMenu, so user cannot touch not while dropDownMenu is exposed
        overlayHeight = self.view.frame.height
        opaqueOverlay = UIView(frame: CGRectMake(0, -overlayHeight, self.view.frame.width, overlayHeight))
        opaqueOverlay.backgroundColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 0.75)
        let tapGesture = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        tapGesture.numberOfTapsRequired = 1
        opaqueOverlay.addGestureRecognizer(tapGesture)
        self.view.addSubview(opaqueOverlay)
        
        // Configure dropDownMenu, width same as view width
        //          No need to fetch groups --> VC is initialized with user's groups
        let dropDownWidth = self.view.frame.width
        self.dropDownMenu = UITableView(frame: CGRect(x: CGFloat(0), y: -dropDownHeight, width: dropDownWidth, height: dropDownHeight))
        dropDownMenu.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        dropDownMenu.rowHeight = userCellHeight
        dropDownMenu.separatorInset.left = userCellInset
        dropDownMenu.registerClass(UserDropDownCell.self, forCellReuseIdentifier: NSStringFromClass(UserDropDownCell))
        dropDownMenu.dataSource = self
        dropDownMenu.delegate = self
        dropDownMenu.separatorStyle = UITableViewCellSeparatorStyle.None
        // If content fits, scroll disabled for dropDownMenu
        if (dropDownMenu.contentSize.height <= dropDownMenu.frame.size.height) {
            dropDownMenu.scrollEnabled = false
        }
        else {
            dropDownMenu.scrollEnabled = true
        }
        
        self.view.addSubview(dropDownMenu)
        
        
        // Add observers for notificationCenter to handle keyboard events
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        // Add an observer to notificationCenter to handle hashtagPress events from HashtagsView
        notificationCenter.addObserver(self, selector: "hashtagPressed:", name: "hashtagPressed", object: nil)
    }
    
    // Configure title of navigationBar to given string
    func configureTitleView(text: String) {
        // UILabel used
        let titleView = UILabel()
        titleView.text = text
        titleView.font = UIFont(name: "OpenSans", size: 17.5)!
        titleView.textColor = UIColor.whiteColor()
        let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        self.navigationItem.titleView = titleView
        
        // tapGesture triggers dropDownMenu to toggle
        let recognizer = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        titleView.userInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    // close the VC on button press from leftBarButtonItem
    func closeVC(sender: UIBarButtonItem!) {
        if (!messageBox.text.isEmpty && messageBox.text != defaultMessage) {
            // If the note has been edited, show an alert
            // DOES NOT show alert if date or group has been changed
            var alert = UIAlertView()
            alert.delegate = self
            alert.title = "Discard Note?"
            alert.message = "If you close this note, your note will be lost."
            alert.addButtonWithTitle("Cancel")
            alert.addButtonWithTitle("Okay")
            alert.show()
        } else {
            // Note has not been edited, dismiss the VC
            let notification = NSNotification(name: "doneAdding", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            self.view.endEditing(true)
            self.closeDatePicker(false)
            self.dismissViewControllerAnimated(true, completion: nil)
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
                self.hashtagsScrollView.sizeZeroHashtagsView()
                self.hashtagsScrollView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.separatorOne.frame.minY
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
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                // size hashtags view to condensed size
                self.hashtagsScrollView.linearHashtagsView()
                self.hashtagsScrollView.frame.origin.y = self.separatorOne.frame.maxY
                // position affected UI elements
                self.separatorTwo.frame.origin.y = self.hashtagsScrollView.frame.maxY
                if (UIDevice.currentDevice().modelName != "iPhone 4S") {
                    // Not an iPhone 4s
                    
                    // Move up controls
                    self.postButton.frame.origin.y = self.view.frame.height - (self.keyboardFrame.height + labelInset + self.postButton.frame.height)
                    self.cameraButton.frame.origin.y = self.postButton.frame.midY - self.cameraButton.frame.height / 2
                    self.locationButton.frame.origin.y = self.postButton.frame.midY - self.locationButton.frame.height / 2
                    // Resize messageBox
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
                        if (UIDevice.currentDevice().modelName == "iPhone 4S") {
                            // For iPhone 4S, change the button to be 'done'
                            self.changeDateLabel.text = "done"
                            self.changeDateLabel.font = UIFont(name: "OpenSans-Bold", size: 12.5)!
                            self.changeDateLabel.sizeToFit()
                            self.changeDateLabel.frame.origin.x = self.view.frame.width - (labelInset + self.changeDateLabel.frame.width)
                        }
                        
                        // hashtags now collapsed
                        self.hashtagsScrollView.hashtagsCollapsed = true
                    }
            })
        }
    }
    
    // Open hashtagsView completely to full view
    func openHashtagsCompletely() {
        if (hashtagsScrollView.hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
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
                        if (UIDevice.currentDevice().modelName == "iPhone 4S") {
                            // If iPhone 4S, change back from 'done' to 'change'
                            self.changeDateLabel.text = "change"
                            self.changeDateLabel.font = UIFont(name: "OpenSans", size: 12.5)!
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
    
    // postNote action from postNoteButton
    func postNote(sender: UIButton!) {
        if (messageBox.text != defaultMessage && !messageBox.text.isEmpty) {
            // if messageBox has text (not default message or empty) --> set the note to have values
            self.note.messagetext = self.messageBox.text
            self.note.groupid = self.group.userid
            self.note.timestamp = self.datePicker.date
            self.note.userid = self.note.user!.userid
            
            // Identify hashtags
            let words = self.note.messagetext.componentsSeparatedByString(" ")
            
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
            
            let notification = NSNotification(name: "doneAdding", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            // Send notification to NotesVC to handle new note that was just created
            let notificationTwo = NSNotification(name: "addNote", object: nil)
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
    
    // Handle touches in the view
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            
            // determine if the touch (first touch) is in the hashtagsView
            let touchLocation = touch.locationInView(self.view)
            let viewFrame = self.view.convertRect(hashtagsScrollView.frame, fromView: hashtagsScrollView.superview)
            
            if !CGRectContainsPoint(viewFrame, touchLocation) {
                // if outside hashtagsView, endEditing, close keyboard, animate, etc.
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
    
    // Toggle the dropDownMenu
    func dropDownMenuPressed() {
        // End editing
        view.endEditing(true)
        // toggle the dropDownMenu open or closed
        if (isDropDownDisplayed) {
            // Configure title with the current group name
            configureTitleView(group.fullName!)
            // Put the closeButton back as the leftBarButtonItem
            self.navigationItem.leftBarButtonItem = closeButton
            // Finally, close the dropDownMenu
            self.hideDropDownMenu()
        } else {
            // Change the title to prompt group selection
            configureTitleView("Note for...")
            // Remove the leftBarButtonItem
            self.navigationItem.leftBarButtonItem = nil
            // Finally, show the dropDownMenu
            self.showDropDownMenu()
        }
    }
    
    // Animate the dropDownMenu and opaqueOverlay back up
    func hideDropDownMenu() {
        // Set the destination frames
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = -dropDownHeight
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = -overlayHeight
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            // In completion, dropDownMenu no longer displayed --> reload the dropDownMenu
            self.isDropDownDisplayed = false
            self.dropDownMenu.reloadData()
        }
    }
    
    // Animate the dropDownMenu and opaqueOverlay down
    func showDropDownMenu() {
        // Set destination frames
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = 0.0
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = 0.0
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            // In completion, dropDownMenu now displayed
            self.isDropDownDisplayed = true
        }
    }
    
    // Animations for dropDownMenu and opaqueOverlay
    func animateDropDownToFrame(frame: CGRect, obstructionFrame: CGRect, completion:() -> Void) {
        if (!isDropDownAnimating) {
            isDropDownAnimating = true
            UIView.animateKeyframesWithDuration(0.5, delay: 0.0, options: nil, animations: { () -> Void in
                // Animate to new frames
                self.dropDownMenu.frame = frame
                self.opaqueOverlay.frame = obstructionFrame
                }, completion: { (completed: Bool) -> Void in
                    self.isDropDownAnimating = false
                    if (completed) {
                        completion()
                    }
            })
        }
    }
    
    // Lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
}
