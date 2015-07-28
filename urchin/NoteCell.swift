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
    func configureWithNote(note: Note, user: User) {
        
        self.note = note
        
        // Configure the date label size first using extended dateFormatter
        // Later will position, but need size to properly size the usernameLabel
        let dateFormatter = NSDateFormatter()
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(note.timestamp)
        timedateLabel.sizeToFit()
        
        // Configure the username label, with the full name
        let usernameWidth = contentView.frame.width - (2 * noteCellInset + timedateLabel.frame.width + 2 * labelSpacing)
        usernameLabel.frame.size = CGSize(width: usernameWidth, height: CGFloat.max)
        usernameLabel.text = note.user!.fullName
        usernameLabel.font = mediumBoldFont
        usernameLabel.textColor = noteTextColor
        usernameLabel.adjustsFontSizeToFitWidth = false
        usernameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        usernameLabel.numberOfLines = 0
        usernameLabel.sizeToFit()
        let usernameX = noteCellInset
        let usernameY = noteCellInset
        usernameLabel.frame.origin = CGPoint(x: usernameX, y: usernameY)
        
        // Position timedateLabel
        // use a one line helper label to determine 
        // where the bottom of the first line of the name label is
        let helperLabel = UILabel(frame: CGRectZero)
        helperLabel.text = "Howard"
        helperLabel.font = mediumBoldFont
        helperLabel.sizeToFit()
        helperLabel.frame.origin = usernameLabel.frame.origin
        let timedateX = contentView.frame.width - (noteCellInset + timedateLabel.frame.width)
        let timedateY = helperLabel.frame.maxY - (timedateLabel.frame.height + 2)
        timedateLabel.frame.origin = CGPoint(x: timedateX, y: timedateY)
        
        // Configure the message label, leverage the hashtag bolder
        messageLabel.frame.size = CGSize(width: contentView.frame.width - 2 * noteCellInset, height: CGFloat.max)
        let hashtagBolder = HashtagBolder()
        let attributedText = hashtagBolder.boldHashtags(note.messagetext)
        messageLabel.attributedText = attributedText
        messageLabel.adjustsFontSizeToFitWidth = false
        messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
        let messageX = noteCellInset
        let messageY = usernameLabel.frame.maxY + 2 * labelSpacing
        messageLabel.frame.origin = CGPoint(x: messageX, y: messageY)
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timedateLabel)
        contentView.addSubview(messageLabel)
        
        // If the note was made by the current user, be able to edit it
        // otherwise, don't put the edit button in
        if (note.user!.userid == user.userid) {
            editButton.frame = CGRectZero
            let editTitle = NSAttributedString(string: editButtonTitle, attributes: [NSForegroundColorAttributeName: tealColor, NSFontAttributeName: smallRegularFont])
            editButton.setAttributedTitle(editTitle, forState: .Normal)
            editButton.sizeToFit()
            editButton.frame.size.height = 2 * labelSpacing + editButtonHeight + noteCellInset
            editButton.frame.size.width = editButton.frame.width + 2 * noteCellInset
            let editX = contentView.frame.width - (editButton.frame.width)
            let editY = messageLabel.frame.maxY
            editButton.frame.origin = CGPoint(x: editX, y: editY)
            
            contentView.addSubview(editButton)
        } else {
            editButton.removeFromSuperview()
        }
    }
    
}