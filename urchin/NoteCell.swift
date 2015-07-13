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
        
        usernameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        timedateLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        messageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timedateLabel)
        contentView.addSubview(messageLabel)
        
//        createConstraints()
        
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
//        println("cell height: \(self.contentView.frame.height) expected: \(cellHeight)")
    }
    
    func createConstraints() {
        // Views to add constraints to
        let views = Dictionary(dictionaryLiteral: ("username", usernameLabel), ("date", timedateLabel), ("message", messageLabel))
        
        // Horizontal Constraints
        let horizontalConstraintsOne = NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(labelInset)-[username]", options: nil, metrics: nil, views: views)
        let horizontalConstraintsTwo = NSLayoutConstraint.constraintsWithVisualFormat("H:[date]-\(labelInset)-|", options: nil, metrics: nil, views: views)
        let horizontalConstraintsThree = NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(labelInset)-[message]-\(labelInset)-|", options: nil, metrics: nil, views: views)
        self.addConstraints(horizontalConstraintsOne)
        self.addConstraints(horizontalConstraintsTwo)
        self.addConstraints(horizontalConstraintsThree)
        
        let verticalConstraintOne = NSLayoutConstraint(item: usernameLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: labelInset)
        let verticalConstraintTwo = NSLayoutConstraint(item: timedateLabel, attribute: .CenterY, relatedBy: .Equal, toItem: usernameLabel, attribute: .CenterY, multiplier: 1, constant: 0)
        let verticalConstraintThree = NSLayoutConstraint(item: messageLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -labelInset)
        let verticalConstraintFour = NSLayoutConstraint(item: usernameLabel, attribute: .Bottom, relatedBy: .Equal, toItem: messageLabel, attribute: .Top, multiplier: 1, constant: 2*labelSpacing)
        self.addConstraint(verticalConstraintOne)
        self.addConstraint(verticalConstraintTwo)
        self.addConstraint(verticalConstraintThree)
        self.addConstraint(verticalConstraintFour)
    }
    
    
}