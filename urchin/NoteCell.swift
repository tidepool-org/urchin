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
    let separator: UIView = UIView()
    
    // Configure the note cell to contain... the note!
    func configureWithNote(note: Note, user: User, groupName: String) {
        
        self.note = note
        
        // Configure the username label, with the full name
        let usernameWidth = contentView.frame.width - (2 * noteCellInset)
        usernameLabel.frame.size = CGSize(width: usernameWidth, height: CGFloat.max)
        
        var attrUsernameLabel: NSMutableAttributedString
        if (groupName.isEmpty) {
            attrUsernameLabel = NSMutableAttributedString(string: note.user!.fullName!, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: mediumBoldFont])
        } else {
            let text = "\(note.user!.fullName!) to \(groupName)"
            attrUsernameLabel = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: mediumBoldFont])
            let length = count(" to ")
            let location = count(attrUsernameLabel.string) - (count(groupName) + length)
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
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timedateLabel)
        contentView.addSubview(messageLabel)
        
        // If the note was made by the current user, be able to edit it
        // otherwise, don't put the edit button in
        if (note.user!.userid == user.userid) {
            separator.frame = CGRect(x: noteCellInset, y: messageLabel.frame.maxY + noteCellInset, width: contentView.frame.width - 2 * noteCellInset, height: userCellThinSeparator)
            separator.backgroundColor = darkestGreyLowAlpha
            
            contentView.addSubview(separator)
            
            editButton.frame = CGRectZero
            let editTitle = NSAttributedString(string: editButtonTitle, attributes: [NSForegroundColorAttributeName: darkestGreyColor, NSFontAttributeName: smallRegularFont])
            editButton.setAttributedTitle(editTitle, forState: .Normal)
            editButton.sizeToFit()
            editButton.frame.size.height = noteCellInset + editButtonHeight + noteCellInset
            editButton.frame.size.width = editButton.frame.width + 2 * noteCellInset
            let editX = contentView.frame.width - (editButton.frame.width)
            let editY = separator.frame.maxY
            editButton.frame.origin = CGPoint(x: editX, y: editY)
            
            contentView.addSubview(editButton)
        } else {
            separator.removeFromSuperview()
            editButton.removeFromSuperview()
        }
    }
    
}