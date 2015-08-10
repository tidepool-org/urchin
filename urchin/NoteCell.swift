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
        
        // Configure the username label, with the full name
        let usernameWidth = contentView.frame.width - (2 * noteCellInset)
        usernameLabel.frame.size = CGSize(width: usernameWidth, height: CGFloat.max)
        let attrUsernameLabel = NSMutableAttributedString(string: note.user!.fullName! + groupName, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: mediumBoldFont])
        attrUsernameLabel.addAttributes([NSForegroundColorAttributeName: darkestGreyColor, NSFontAttributeName: mediumRegularFont], range: NSRange(location: count(note.user!.fullName!), length: count(groupName)))
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
        timedateLabel.attributedText = dateFormatter.attributedStringFromDate(note.timestamp)
        timedateLabel.sizeToFit()
        // Position timedateLabel
        let timedateX = noteCellInset
        let timedateY = usernameLabel.frame.maxY + labelSpacing
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
        let messageY = timedateLabel.frame.maxY + labelSpacing
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