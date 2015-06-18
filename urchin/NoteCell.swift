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
let labelSpacing: CGFloat = 8

class NoteCell: UITableViewCell {
    
    let usernameLabel: UILabel
    let timedateLabel: UILabel
    let textView: UITextView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        usernameLabel = UILabel(frame: CGRectMake(noteCellInset, noteCellInset, 100.0, 17.0))
        usernameLabel.font = UIFont.systemFontOfSize(17)
        
        timedateLabel = UILabel(frame: CGRectMake(noteCellInset, noteCellInset + usernameLabel.frame.height + labelSpacing, 100.0, 17.0))
        timedateLabel.font = UIFont.systemFontOfSize(17)

        textView = UITextView(frame: CGRectMake(noteCellInset, noteCellInset + usernameLabel.frame.height + timedateLabel.frame.height + 2*labelSpacing, 100.0, 17.0))
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(usernameLabel)
        contentView.addSubview(timedateLabel)
        contentView.addSubview(textView)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithNote(note: Note) {
        usernameLabel.text = "Ethan Look"
        timedateLabel.text = "Right now on Today"
        println(note.text)
        textView.text = note.text
        println(textView.text)
    }
    
    
}