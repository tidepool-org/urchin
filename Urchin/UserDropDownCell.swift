//
//  UserDropDownCell.swift
//  urchin
//
//  Created by Ethan Look on 6/19/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

let userCellHeight: CGFloat = 52.5
let userCellInset: CGFloat = 16
let userCellThickSeparator: CGFloat = 4
let userCellThinSeparator: CGFloat = 1

class UserDropDownCell: UITableViewCell {
    
    let borders = false
    
    var cellHeight: CGFloat
    
    let nameLabel: UILabel

    var user: User!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.font = UIFont.systemFontOfSize(17)
        nameLabel.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        
        self.cellHeight = CGFloat(0)
        
        if (borders) {
            nameLabel.layer.borderWidth = 1
            nameLabel.layer.borderColor = UIColor.redColor().CGColor
        }
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        
        nameLabel.frame = CGRectMake(2*userCellInset, userCellInset, contentView.frame.width + userCellInset, 20.0)
        
        contentView.addSubview(nameLabel)
        
        self.layoutMargins = UIEdgeInsetsZero
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithGroup(user: User) {
        self.user = user
        
        nameLabel.frame = CGRectMake(6*userCellInset, userCellInset, contentView.frame.width + userCellInset, 20.0)
        self.nameLabel.text = user.fullName
        nameLabel.sizeToFit()
        
        let separator = UIView(frame: CGRectMake(0, self.frame.height - userCellThinSeparator, self.frame.width, userCellThinSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
    }
    
    func configureAllUsers() {
        self.nameLabel.text = "All"
        nameLabel.font = UIFont.boldSystemFontOfSize(17)
        nameLabel.sizeToFit()
        
        let separator = UIView(frame: CGRectMake(0, self.frame.height - userCellThickSeparator, self.frame.width, userCellThickSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
    }
    
    func configureLogout() {
        self.nameLabel.text = "Logout"
        nameLabel.font = UIFont.boldSystemFontOfSize(17)
        nameLabel.sizeToFit()
        nameLabel.frame.origin.y = nameLabel.frame.origin.y + userCellThickSeparator - userCellThinSeparator
        
        let separator = UIView(frame: CGRectMake(0, 0, self.frame.width, userCellThickSeparator - userCellThinSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
    }
}