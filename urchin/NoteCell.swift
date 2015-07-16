//
//  NotesTableViewCell.swift
//  urchin
//
//  Created by Ethan Look on 6/17/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

let noteCellHeight: CGFloat = 128
let noteCellInset: CGFloat = 16
let labelSpacing: CGFloat = 6

class NoteCell: UITableViewCell {
    
    var note: Note?
    
    let usernameLabel: UILabel = UILabel()
    let timedateLabel: UILabel = UILabel()
    let editButton: UIButton = UIButton()
    var messageLabel: UILabel = UILabel()
    
    // Configure the note cell to contain... the note!
    func configureWithNote(note: Note, user: User) {
        
        self.note = note
        
        // Configure the username label, with the full name
        let usernameWidth = (contentView.frame.width - 2*noteCellInset) / 2
        usernameLabel.frame.size = CGSize(width: usernameWidth, height: CGFloat.max)
        usernameLabel.text = note.user!.fullName
        usernameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        usernameLabel.textColor = UIColor.blackColor()
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
        // use a one line helper label to determine 
        // where the bottom of the first line of the name label is
        let helperLabel = UILabel(frame: CGRectZero)
        helperLabel.text = "Howard"
        helperLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
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
        if (note.user === user) {
            editButton.frame = CGRectZero
            let editTitle = NSAttributedString(string: "edit", attributes: [NSForegroundColorAttributeName: UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1), NSFontAttributeName: UIFont(name: "OpenSans", size: 12.5)!])
            editButton.setAttributedTitle(editTitle, forState: .Normal)
            editButton.sizeToFit()
            editButton.frame.size.height = 12.5
            let editX = contentView.frame.width - (noteCellInset + editButton.frame.width)
            let editY = messageLabel.frame.maxY + 2 * labelSpacing
            editButton.frame.origin = CGPoint(x: editX, y: editY)
            
            contentView.addSubview(editButton)
        } else {
            editButton.removeFromSuperview()
        }
    }
    
}