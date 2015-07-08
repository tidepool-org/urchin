//
//  AddNoteView.swift
//  urchin
//
//  Created by Ethan Look on 7/8/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class AddNoteViewController: UIViewController {
    
    
    let timedateLabel: UILabel
    let changeDateButton: UIButton
    
    var datePickerShown: Bool = false
    var isAnimating: Bool = false
    let datePicker: UIDatePicker
    
    let separatorOne: UIView
    
    let messageBox: UITextView
    let postButton: UIButton
    
    
    
    let note: Note
    var user: User
    
    init(currentUser: User) {
        // UI Elements
        timedateLabel = UILabel(frame: CGRectZero)
        changeDateButton = UIButton(frame: CGRectZero)
        
        datePicker = UIDatePicker(frame: CGRectZero)
        
        separatorOne = UIView(frame: CGRectZero)
        
        messageBox = UITextView(frame: CGRectZero)
        postButton = UIButton(frame: CGRectZero)
        
        // data
        note = Note()
        note.user = currentUser
        note.messagetext = "This is a new note created from the new note view controller."
        user = currentUser
        
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
        dateFormatter.dateFormat = "h:mm a EEEE M.d.yy"
        var dateString = dateFormatter.stringFromDate(note.timestamp)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        timedateLabel.text = dateString
        timedateLabel.font = UIFont(name: "OpenSans", size: 17.5)!
        timedateLabel.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        timedateLabel.sizeToFit()
        timedateLabel.frame.origin.x = labelInset
        
        // configure change button
        changeDateButton.setAttributedTitle(NSAttributedString(string:"change",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
        changeDateButton.backgroundColor = UIColor.clearColor()
        changeDateButton.addTarget(self, action: "changeDatePressed:", forControlEvents: .TouchUpInside)
        changeDateButton.sizeToFit()
        changeDateButton.frame.origin.x = self.view.frame.width - (labelInset + changeDateButton.frame.width)
        
        // configure date picker
        datePicker.datePickerMode = .DateAndTime
        datePicker.frame.origin.x = 0
        datePicker.hidden = true
        datePicker.addTarget(self, action: "datePickerAction:", forControlEvents: .ValueChanged)
        
        // configure first separator
        separatorOne.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        separatorOne.frame.size = CGSize(width: self.view.frame.size.width, height: 1)
        separatorOne.frame.origin.x = 0
        
        // configure post button
        postButton.setAttributedTitle(NSAttributedString(string:"Post",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
        postButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        postButton.addTarget(self, action: "postNote:", forControlEvents: .TouchUpInside)
        postButton.frame.size = CGSize(width: 112, height: 41)
        postButton.frame.origin.x = self.view.frame.size.width - (labelInset + postButton.frame.width)
        
        uiElementLocation()
        separatorOne.frame.origin.y = timedateLabel.frame.maxY + labelInset
        postButton.frame.origin.y = self.view.frame.size.height - (labelInset + postButton.frame.height + 64)
        
        self.view.addSubview(timedateLabel)
        self.view.addSubview(changeDateButton)
        self.view.addSubview(datePicker)
        self.view.addSubview(separatorOne)
        self.view.addSubview(postButton)
        
    }
    
    func closeVC(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeDatePressed(sender: UIButton!) {
        if (!datePicker.hidden) {
            closeDatePicker()
        } else {
            openDatePicker()
        }
    }
    
    func closeDatePicker() {
        if (!datePicker.hidden) {
            self.animateDatePicker() {
                self.changeDateButton.setAttributedTitle(NSAttributedString(string:"change",
                    attributes:[NSForegroundColorAttributeName: UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
            }
        }
    }
    
    func openDatePicker() {
        if (datePicker.hidden) {
            self.animateDatePicker() {
                self.changeDateButton.setAttributedTitle(NSAttributedString(string:"done",
                    attributes:[NSForegroundColorAttributeName: UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
            }
        }
    }
    
    func animateDatePicker(completion: () -> Void) {
        if (!isAnimating) {
            isAnimating = true
            var switcher = false
            if (!self.datePicker.hidden) {
                UIView.animateWithDuration(0.2, animations: {
                    self.datePicker.alpha = 0.0
                })
                switcher = true
            }
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                self.uiElementLocation()
                }, completion: { (completed: Bool) -> Void in
                    if (!switcher) {
                        UIView.animateWithDuration(0.2, animations: {
                            self.datePicker.alpha = 1.0
                        })
                        self.datePicker.hidden = false
                    } else {
                        self.datePicker.hidden = true
                    }
                    self.isAnimating = false
                    if (completed) {
                        completion()
                    }
            })
        }
    }
    
    func datePickerAction(sender: UIDatePicker) {
        note.createdtime = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a EEEE M.d.yy"
        var dateString = dateFormatter.stringFromDate(note.createdtime)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        timedateLabel.text = dateString
        timedateLabel.sizeToFit()
    }
    
    func uiElementLocation() {
        timedateLabel.frame.origin.y = labelInset
        changeDateButton.frame.origin.y = timedateLabel.frame.midY - changeDateButton.frame.height / 2
        datePicker.frame.origin.y = timedateLabel.frame.maxY + labelInset / 2
        if (!datePicker.hidden) {
            separatorOne.frame.origin.y = timedateLabel.frame.maxY + labelInset
        } else {
           separatorOne.frame.origin.y = datePicker.frame.maxY + labelInset / 2
        }
        postButton.frame.origin.y = self.view.frame.size.height - (labelInset + postButton.frame.height)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}
