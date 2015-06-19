//
//  UserDropDownCell.swift
//  urchin
//
//  Created by Ethan Look on 6/19/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

let userCellHeight: CGFloat = 64
let userCellInset: CGFloat = 16

class UserDropDownCell: UITableViewCell {
    
    let borders = true
    
    var cellHeight: CGFloat
    
    let nameLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.font = UIFont.boldSystemFontOfSize(17)
        nameLabel.textColor = UIColor(red: 57/255, green: 61/255, blue: 70/255, alpha: 1)
        
        self.cellHeight = CGFloat(0)
        
        if (borders) {
            nameLabel.layer.borderWidth = 1
            nameLabel.layer.borderColor = UIColor.redColor().CGColor
        }
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.frame = CGRectMake(userCellInset, userCellInset, contentView.frame.width + userCellInset, 20.0)
        
        contentView.addSubview(nameLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithGroup(user: User) {
        self.nameLabel.text = user.fullName
        nameLabel.sizeToFit()
        
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset
    }
}