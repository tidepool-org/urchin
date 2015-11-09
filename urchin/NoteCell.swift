//
//  NotesTableViewCell.swift
//  urchin
//
//  Created by Ethan Look on 6/17/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class NoteCell: UITableViewCell {
    
    var note: Note?
    
    let usernameLabel: UILabel = UILabel()
    let timedateLabel: UILabel = UILabel()
    let editButton: UIButton = UIButton()
    var messageLabel: UILabel = UILabel()
    
    // Configure the note cell to contain... the note!
    func configureWithNote(note: Note, user: User, groupName: String) {
        
        self.note = note
        
        // If the note was made by the current user, be able to edit it
        // otherwise, don't put the edit button in
        editButton.frame = CGRectZero
        if (note.user!.userid == user.userid) {
            let editTitle = NSAttributedString(string: editButtonTitle, attributes: [NSForegroundColorAttributeName: darkestGreyColor, NSFontAttributeName: smallRegularFont])
            editButton.setAttributedTitle(editTitle, forState: .Normal)
            editButton.sizeToFit()
            let editX: CGFloat = contentView.frame.width - (editButton.frame.width + 2 * hitBoxAmount)
            editButton.frame.size.height = hitBoxAmount + editButtonHeight + hitBoxAmount
            editButton.frame.size.width = editButton.frame.width + 2 * hitBoxAmount
            editButton.frame.origin.x = editX
            
            let helperLabel = UILabel()
            helperLabel.font = mediumSemiboldFont
            helperLabel.text = "Howard"
            helperLabel.sizeToFit()
            editButton.frame.origin.y = (noteCellInset + helperLabel.frame.height) - (editButtonHeight + hitBoxAmount + 2)
            
            contentView.addSubview(editButton)
        } else {
            editButton.removeFromSuperview()
        }
        
        // Configure the username label, with the full name
        let usernameWidth = contentView.frame.width - (2 * noteCellInset + editButton.frame.width)
        usernameLabel.frame.size = CGSize(width: usernameWidth, height: CGFloat.max)
        
        var attrUsernameLabel: NSMutableAttributedString
        if (groupName.isEmpty) {
            attrUsernameLabel = NSMutableAttributedString(string: note.user!.fullName!, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: mediumSemiboldFont])
        } else {
            let text = "\(note.user!.fullName!) to \(groupName)"
            attrUsernameLabel = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: mediumSemiboldFont])
            let length = " to ".characters.count
            let location = attrUsernameLabel.string.characters.count - (groupName.characters.count + length)
            attrUsernameLabel.addAttributes([NSForegroundColorAttributeName: darkestGreyColor, NSFontAttributeName: mediumRegularFont], range: NSRange(location: location, length: length))
        }
        
        usernameLabel.attributedText = attrUsernameLabel
        usernameLabel.adjustsFontSizeToFitWidth = false
        usernameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        usernameLabel.numberOfLines = 0
        usernameLabel.sizeToFit()

        let usernameX = noteCellInset
        let usernameY = noteCellInset
        usernameLabel.frame.origin = CGPoint(x: usernameX, y: usernameY)
        
        // Configure the date label using extended dateFormatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = uniformDateFormat
        
        var dateString = dateFormatter.stringFromDate(note.timestamp)
        
        // Replace uppercase PM and AM with lowercase versions
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        timedateLabel.attributedText = NSMutableAttributedString(string: dateString, attributes: [NSForegroundColorAttributeName: darkestGreyColor, NSFontAttributeName: smallRegularFont])
        timedateLabel.sizeToFit()
        // Position timedateLabel
        let timedateX = noteCellInset
        let timedateY = usernameLabel.frame.maxY + labelSpacing / 2
        timedateLabel.frame.origin = CGPoint(x: timedateX, y: timedateY)
        
        // Configure the message label, leverage the hashtag bolder
        messageLabel.frame.size = CGSize(width: contentView.frame.width - 2 * noteCellInset, height: CGFloat.max)
        let hashtagBolder = HashtagBolder()
        let attributedText = hashtagBolder.boldHashtags(note.messagetext)
        attributedText.addAttribute(NSForegroundColorAttributeName, value: noteTextColor, range: NSRange(location: 0, length: attributedText.length))
        messageLabel.attributedText = attributedText
        messageLabel.adjustsFontSizeToFitWidth = false
        messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
        let messageX = noteCellInset
        let messageY = timedateLabel.frame.maxY + 2 * labelSpacing
        messageLabel.frame.origin = CGPoint(x: messageX, y: messageY)
        
        messageLabel.userInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "copyToClipboard")
        doubleTap.numberOfTapsRequired = 2
        messageLabel.addGestureRecognizer(doubleTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "copyToClipboard")
        messageLabel.addGestureRecognizer(longPress)
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timedateLabel)
        contentView.addSubview(messageLabel)
    }
    
    func copyToClipboard() {
        print(messageLabel.text!)
        
        UIPasteboard.generalPasteboard().string = messageLabel.text!
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.messageLabel.alpha = 0.1
        }) { (completion) -> Void in
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.messageLabel.alpha = 1.0
            }, completion: { (completed) -> Void in
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.messageLabel.alpha = 0.1
                }, completion: { (completed) -> Void in
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.messageLabel.alpha = 1.0
                    })
                })
            })
        }
    }
}