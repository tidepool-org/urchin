//
//  AddNoteView.swift
//  urchin
//
//  Created by Ethan Look on 7/8/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

let hashtagHeight: CGFloat = 41

class AddNoteViewController: UIViewController, UITextViewDelegate {
    
    let hashtags = ["#exercise", "#low", "#high", "#meal", "#snack", "#stress", "#pumpfail", "#cgmfail", "#success"]
    var hashtagButtons: [UIButton] = []
    
    
    let timedateLabel: UILabel
    let changeDateLabel: UILabel
    
    var datePickerShown: Bool = false
    var isAnimating: Bool = false
    let datePicker: UIDatePicker
    
    let separatorOne: UIView
    
    let hashtagsView: UIView
    var hashtagsCollapsed: Bool
    
    let separatorTwo: UIView
    
    let messageBox: UITextView
    let postButton: UIButton
    
    let note: Note
    var user: User
    
    var keyboardFrame: CGRect
    
    init(currentUser: User) {
        // UI Elements
        timedateLabel = UILabel(frame: CGRectZero)
        changeDateLabel = UILabel(frame: CGRectZero)
        
        datePicker = UIDatePicker(frame: CGRectZero)
        
        separatorOne = UIView(frame: CGRectZero)
        
        hashtagsView = UIView(frame: CGRectZero)
        hashtagsCollapsed = false
        
        separatorTwo = UIView(frame: CGRectZero)
        
        messageBox = UITextView(frame: CGRectZero)
        postButton = UIButton(frame: CGRectZero)
        
        // data
        note = Note()
        note.user = currentUser
        note.messagetext = "This is a new note created from the new note view controller."
        user = currentUser
        
        keyboardFrame = CGRectZero
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        self.title = user.fullName
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 25)!]
        
        var closeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "closex")!, style: .Plain, target: self, action: "closeVC:")
        self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
    
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
        changeDateLabel.text = "change date"
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
        let hashtagsViewH = labelInset + 3 * hashtagHeight + 4 * labelSpacing + labelInset
        hashtagsView.frame.size = CGSize(width: self.view.frame.width, height: hashtagsViewH)
        hashtagsView.frame.origin.x = 0
        hashtagsView.frame.origin.y = separatorOne.frame.maxY
        
        self.view.addSubview(hashtagsView)
        
        // configure second separator
        separatorTwo.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        separatorTwo.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorTwo.frame.origin.x = 0
        separatorTwo.frame.origin.y = hashtagsView.frame.maxY
        
        self.view.addSubview(separatorTwo)

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
        messageBox.backgroundColor = UIColor.clearColor()
        messageBox.font = UIFont(name: "OpenSans", size: 17.5)!
        messageBox.text = "Type a note..."
        messageBox.textColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
        let messageBoxW = self.view.frame.width - 2 * labelInset
        let messageBoxH = (postButton.frame.minY - separatorTwo.frame.maxY) - 2 * labelInset
        messageBox.frame.size = CGSize(width: messageBoxW, height: messageBoxH)
        messageBox.frame.origin.x = labelInset
        messageBox.frame.origin.y = separatorTwo.frame.maxY + labelInset
        messageBox.delegate = self
        messageBox.autocapitalizationType = UITextAutocapitalizationType.Sentences
        messageBox.autocorrectionType = UITextAutocorrectionType.Default
        messageBox.spellCheckingType = UITextSpellCheckingType.Default
        messageBox.keyboardAppearance = UIKeyboardAppearance.Dark
        messageBox.keyboardType = UIKeyboardType.Default
        messageBox.returnKeyType = UIReturnKeyType.Default
        messageBox.secureTextEntry = false
        
        self.view.addSubview(messageBox)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        if (true) {
            messageBox.layer.borderWidth = 1
            messageBox.layer.borderColor = UIColor.redColor().CGColor
        }
    }
    
    func closeVC(sender: UIBarButtonItem!) {
        closeDatePicker(false)
        self.dismissViewControllerAnimated(true, completion: nil)
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
                let hashtagsViewH = labelInset + 3 * hashtagHeight + 4 * labelSpacing + labelInset
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: hashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.hashtagsView.frame.maxY
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    self.datePicker.hidden = true
                    self.isAnimating = false
                    self.changeDateLabel.text = "change date"
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
        if (hashtagsCollapsed) {
            openHashtagsCompletely()
        } else {
            closeHashtagsPartially()
        }
    }
    
    func closeHashtagsPartially() {
        if (!hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                let hashtagsViewH = labelInset + hashtagHeight + labelInset
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: hashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.hashtagsView.frame.maxY
                self.postButton.frame.origin.y = self.view.frame.height - (self.keyboardFrame.height + labelInset + self.postButton.frame.height)
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        self.hashtagsCollapsed = true
                    }
            })
        }
    }
    
    func openHashtagsCompletely() {
        if (hashtagsCollapsed && !isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                
                let hashtagsViewH = labelInset + 3 * hashtagHeight + 4 * labelSpacing + labelInset
                self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.frame.width, height: hashtagsViewH)
                self.hashtagsView.frame.origin.y = self.separatorOne.frame.maxY
                self.separatorTwo.frame.origin.y = self.hashtagsView.frame.maxY
                self.postButton.frame.origin.y = self.view.frame.height - (labelInset + self.postButton.frame.height)
                let messageBoxH = (self.postButton.frame.minY - self.separatorTwo.frame.maxY) - 2 * labelInset
                self.messageBox.frame.size = CGSize(width: self.messageBox.frame.width, height: messageBoxH)
                self.messageBox.frame.origin.y = self.separatorTwo.frame.maxY + labelInset
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        self.hashtagsCollapsed = false
                    }
            })
        }
    }
    
    func datePickerAction(sender: UIDatePicker) {
        note.timestamp = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE M.d.yy h:mm a"
        var dateString = dateFormatter.stringFromDate(note.timestamp)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        timedateLabel.text = dateString
        timedateLabel.sizeToFit()
    }
    

    
    func postNote(sender: UIButton!) {
        if (messageBox.text != "Type a note...") {
            let notification = NSNotification(name: "addNote", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text != "Type a note...") {
            note.messagetext = textView.text
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        // shift things up and stuff
        if textView.textColor == UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1) {
            textView.text = nil
            textView.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // shift things back down and stuff
        if textView.text.isEmpty {
            textView.text = "Type a note..."
            textView.textColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
        } else {
            note.messagetext = textView.text
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!isAnimating) {
            view.endEditing(true)
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
