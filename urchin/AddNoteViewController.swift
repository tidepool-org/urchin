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

let hashtagHeight: CGFloat = 41
let defaultMessage: String = "What's going on?"

class AddNoteViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var dropDownMenu: UITableView!
    var isDropDownDisplayed: Bool = false
    var isDropDownAnimating: Bool = false
    var dropDownHeight: CGFloat
    var opaqueOverlay: UIView!
    var overlayHeight: CGFloat
    
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
    var group: Group
    var groups: [Group]
    let user: User
    
    var keyboardFrame: CGRect
    
    init(user: User, group: Group, groups: [Group]) {
        // UI Elements
        self.dropDownHeight = CGFloat(groups.count) * userCellHeight + CGFloat(groups.count-1)*userCellThinSeparator
        self.overlayHeight = CGFloat(0)
        
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
        note = Note()
        note.user = user
        note.groupid = group.groupid
        note.messagetext = ""
        self.group = group
        self.groups = groups
        self.user = user
        
        keyboardFrame = CGRectZero
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        configureTitleView(group.name)
        
        var closeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "closex")!, style: .Plain, target: self, action: "closeVC:")
        self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
        
        var rightDropDownMenuButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "down"), style: .Plain, target: self, action: "dropDownMenuPressed")
        self.navigationItem.setRightBarButtonItem(rightDropDownMenuButton, animated: true)
    
        // configure date label
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE M.d.yy h:mm a"
        var dateString = dateFormatter.stringFromDate(note.timestamp)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        timedateLabel.text = dateString
        timedateLabel.font = UIFont(name: "OpenSans", size: 17.5)!
        timedateLabel.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        timedateLabel.sizeToFit()
        timedateLabel.frame.origin.x = labelInset
        timedateLabel.frame.origin.y = labelInset
        
        // configure change button
        changeDateLabel.text = "change"
        changeDateLabel.font = UIFont(name: "OpenSans", size: 17.5)
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
        let hashtagsViewH = 3 * hashtagHeight + 2 * labelInset + 4 * labelSpacing
        hashtagsView.frame.size = CGSize(width: self.view.frame.width, height: hashtagsViewH)
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
        postButton.setAttributedTitle(NSAttributedString(string:"Post",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
        postButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        postButton.addTarget(self, action: "postNote:", forControlEvents: .TouchUpInside)
        postButton.frame.size = CGSize(width: 112, height: 41)
        postButton.frame.origin.x = self.view.frame.size.width - (labelInset + postButton.frame.width)
        postButton.frame.origin.y = self.view.frame.size.height - (labelInset + postButton.frame.height + 64)
        
        self.view.addSubview(postButton)
        
        // configure message box
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
        
        self.view.addSubview(cameraButton)
        
        // configure location button
        let location = UIImage(named: "location") as UIImage!
        locationButton.setImage(location, forState: .Normal)
        locationButton.addTarget(self, action: "locationPressed:", forControlEvents: .TouchUpInside)
        locationButton.frame.size = location.size
        let locationX = cameraButton.frame.maxX + 2 * labelInset
        let locationY = postButton.frame.midY - locationButton.frame.height / 2
        locationButton.frame.origin = CGPoint(x: locationX, y: locationY)
        
        self.view.addSubview(locationButton)
        
        overlayHeight = self.view.frame.height
        opaqueOverlay = UIView(frame: CGRectMake(0, -overlayHeight, self.view.frame.width, overlayHeight))
        opaqueOverlay.backgroundColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 0.75)
        let tapGesture = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        tapGesture.numberOfTapsRequired = 1
        opaqueOverlay.addGestureRecognizer(tapGesture)
        self.view.addSubview(opaqueOverlay)
        
        let dropDownWidth = self.view.frame.width
        self.dropDownMenu = UITableView(frame: CGRect(x: CGFloat(0), y: -dropDownHeight, width: dropDownWidth, height: dropDownHeight))
        
        dropDownMenu.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        dropDownMenu.rowHeight = userCellHeight
        dropDownMenu.separatorInset.left = userCellInset
        dropDownMenu.registerClass(UserDropDownCell.self, forCellReuseIdentifier: NSStringFromClass(UserDropDownCell))
        dropDownMenu.dataSource = self
        dropDownMenu.delegate = self
        dropDownMenu.separatorStyle = UITableViewCellSeparatorStyle.None
        if (dropDownMenu.contentSize.height <= dropDownMenu.frame.size.height) {
            dropDownMenu.scrollEnabled = false;
        }
        else {
            dropDownMenu.scrollEnabled = true;
        }
        
        self.view.addSubview(dropDownMenu)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func configureTitleView(text: String) {
        let titleView = UILabel()
        titleView.text = text
        titleView.font = UIFont(name: "OpenSans", size: 25)!
        titleView.textColor = UIColor.whiteColor()
        let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        titleView.userInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    func closeVC(sender: UIBarButtonItem!) {
        if (!messageBox.text.isEmpty && messageBox.text != defaultMessage) {
            let alert = UIAlertController(title: "Discard Changes?", message: "You have made changes to this note. Would you like to discard these changes?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Discard",
                style: UIAlertActionStyle.Destructive,
                handler: {(alert: UIAlertAction!) in
                    self.view.endEditing(true)
                    self.closeDatePicker(false)
                    self.dismissViewControllerAnimated(true, completion: nil)}))
            alert.addAction(UIAlertAction(title: "Cancel",
                style: UIAlertActionStyle.Default,
                handler: nil))
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
                let hashtagsViewH = 3 * hashtagHeight + 2 * labelInset + 4 * labelSpacing
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: hashtagsViewH)
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
                
                let hashtagsViewH = labelInset + hashtagHeight + labelInset
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: hashtagsViewH)
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
                            self.changeDateLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
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
                
                let hashtagsViewH = 3 * hashtagHeight + 2 * labelInset + 4 * labelSpacing
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: hashtagsViewH)
                self.hashtagsView.pageHashtagArrangement()
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
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
                            self.changeDateLabel.font = UIFont(name: "OpenSans", size: 17.5)!
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
        dateFormatter.dateFormat = "EEEE M.d.yy h:mm a"
        var dateString = dateFormatter.stringFromDate(datePicker.date)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        timedateLabel.text = dateString
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
    
    func postNote(sender: UIButton!) {
        if (messageBox.text != defaultMessage && !messageBox.text.isEmpty) {
            self.note.messagetext = self.messageBox.text
            self.note.groupid = self.group.groupid
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
            let notification = NSNotification(name: "addNote", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func hashtagPressed(sender: UIButton!) {
        if (messageBox.text == defaultMessage) {
            messageBox.text = sender.titleLabel!.text!
        } else {
            if (self.messageBox.text.hasSuffix(" ")) {
                messageBox.text = messageBox.text + sender.titleLabel!.text!
            } else {
                messageBox.text = messageBox.text + " " + sender.titleLabel!.text!
            }
        }
        textViewDidChange(messageBox)
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text != defaultMessage) {
            
            let hashtagBolder = HashtagBolder()
            let attributedText = hashtagBolder.boldHashtags(textView.text)
            
            textView.attributedText = attributedText
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == defaultMessage) {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // shift things back down and stuff
        if textView.text.isEmpty {
            textView.text = defaultMessage
            textView.textColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        if (!isAnimating) {
//            view.endEditing(true)
//        }
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
    
    func dropDownMenuPressed() {
        view.endEditing(true)
        if (isDropDownDisplayed) {
            configureTitleView(group.name)
            self.hideDropDownMenu()
        } else {
            configureTitleView("")
            self.showDropDownMenu()
        }
    }
    
    func hideDropDownMenu() {
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = -dropDownHeight
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = -overlayHeight
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            self.isDropDownDisplayed = false
        }
    }
    
    func showDropDownMenu() {
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = 0.0
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = 0.0
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            self.isDropDownDisplayed = true
        }
    }
    
    func animateDropDownToFrame(frame: CGRect, obstructionFrame: CGRect, completion:() -> Void) {
        if (!isDropDownAnimating) {
            isDropDownAnimating = true
            UIView.animateKeyframesWithDuration(0.5, delay: 0.0, options: nil, animations: { () -> Void in
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
        
        cell.configureWithGroup(groups[indexPath.row], arrow: false)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = UserDropDownCell(style: .Default, reuseIdentifier: nil)
        cell.configureWithGroup(groups[indexPath.row], arrow: false)
        return cell.cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = dropDownMenu.cellForRowAtIndexPath(indexPath) as! UserDropDownCell
        configureTitleView(cell.group.name)
        self.group = cell.group
        self.note.groupid = self.group.groupid
        self.dropDownMenuPressed()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}
