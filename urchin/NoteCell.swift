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
    
    var cellHeight: CGFloat
    
    let usernameLabel: UILabel
    let timedateLabel: UILabel
    let messageLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        usernameLabel = UILabel(frame: CGRectZero)
        usernameLabel.font = UIFont.boldSystemFontOfSize(17)
        usernameLabel.textColor = UIColor(red: 57/255, green: 61/255, blue: 70/255, alpha: 1)
        
        timedateLabel = UILabel(frame: CGRectZero)
        timedateLabel.font = UIFont.systemFontOfSize(17)
        timedateLabel.textColor = UIColor(red: 84/255, green: 92/255, blue: 104/255, alpha: 1)

        messageLabel = UILabel(frame: CGRectZero)
        messageLabel.font = UIFont.systemFontOfSize(17)
        messageLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageLabel.numberOfLines = 0
        
        cellHeight = CGFloat(0)
        
        if (borders) {
            usernameLabel.layer.borderWidth = 1
            usernameLabel.layer.borderColor = UIColor.redColor().CGColor
            
            timedateLabel.layer.borderWidth = 1
            timedateLabel.layer.borderColor = UIColor.redColor().CGColor
            
            messageLabel.layer.borderWidth = 1
            messageLabel.layer.borderColor = UIColor.redColor().CGColor
        }
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        usernameLabel.frame = CGRectMake(noteCellInset, noteCellInset, contentView.frame.width + noteCellInset, 20.0)
        timedateLabel.frame = CGRectMake(noteCellInset, noteCellInset + usernameLabel.frame.height + labelSpacing, contentView.frame.width + noteCellInset, 20.0)
        messageLabel.frame = CGRectMake(noteCellInset, noteCellInset + usernameLabel.frame.height + timedateLabel.frame.height + 3*labelSpacing, contentView.frame.width - 2*noteCellInset, CGFloat.max)

        contentView.addSubview(usernameLabel)
        contentView.addSubview(timedateLabel)
        contentView.addSubview(messageLabel)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithNote(note: Note) {
        usernameLabel.text = note.user.fullName
        usernameLabel.sizeToFit()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a EEEE M.d.yy"
        var dateString = dateFormatter.stringFromDate(note.timestamp)
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        timedateLabel.text = dateString
        timedateLabel.sizeToFit()
        
        messageLabel.text = note.messagetext
        var messageLabelFrame = messageLabel.frame
        messageLabelFrame.size.width = contentView.frame.width - 2*noteCellInset
        messageLabel.frame = messageLabelFrame
        messageLabel.sizeToFit()
        messageLabel.frame = CGRect(x: noteCellInset, y: noteCellInset + usernameLabel.frame.height + timedateLabel.frame.height + 3*labelSpacing, width: messageLabel.frame.width, height: messageLabel.frame.height)
        
        cellHeight = noteCellInset + usernameLabel.frame.height + labelSpacing + timedateLabel.frame.height + labelSpacing + messageLabel.frame.height + noteCellInset
    }
    
    
}