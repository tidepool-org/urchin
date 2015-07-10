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
    
    let borders = false
    
    var cellHeight: CGFloat = CGFloat()
    
    let usernameLabel: UILabel = UILabel()
    let timedateLabel: UILabel = UILabel()
    var messageLabel: UILabel = UILabel()
    
    func configureWithNote(note: Note) {
        
        usernameLabel.text = note.user!.fullName
        usernameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        usernameLabel.textColor = UIColor.blackColor()
        usernameLabel.sizeToFit()
        let usernameX = noteCellInset
        let usernameY = noteCellInset
        usernameLabel.frame.origin = CGPoint(x: usernameX, y: usernameY)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE M.d.yy h:mm a"
        var dateString = dateFormatter.stringFromDate(note.timestamp)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        timedateLabel.text = dateString
        timedateLabel.font = UIFont(name: "OpenSans", size: 12.5)!
        timedateLabel.textColor = UIColor.blackColor()
        timedateLabel.sizeToFit()
        let timedateX = contentView.frame.width - (noteCellInset + timedateLabel.frame.width)
        let timedateY = usernameLabel.frame.midY - timedateLabel.frame.height / 2
        timedateLabel.frame.origin = CGPoint(x: timedateX, y: timedateY)
        
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
        
        cellHeight = noteCellInset + usernameLabel.frame.height + 2 * labelSpacing + messageLabel.frame.height + noteCellInset
        
        if (borders) {
            usernameLabel.layer.borderWidth = 1
            usernameLabel.layer.borderColor = UIColor.redColor().CGColor
            
            timedateLabel.layer.borderWidth = 1
            timedateLabel.layer.borderColor = UIColor.redColor().CGColor
            
            messageLabel.layer.borderWidth = 1
            messageLabel.layer.borderColor = UIColor.redColor().CGColor
            
            self.contentView.layer.borderWidth = 1
            self.contentView.layer.borderColor = UIColor.blueColor().CGColor
        }
        
        self.contentView.frame.size = CGSize(width: self.contentView.frame.width, height: cellHeight)
//        println("cell height: \(self.contentView.frame.height) expected: \(cellHeight)")
    }
    
    
}