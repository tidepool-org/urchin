//
//  UserDropDownCell.swift
//  urchin
//
//  Created by Ethan Look on 6/19/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

let userCellHeight: CGFloat = 56.0
let userCellInset: CGFloat = 16
let userCellThickSeparator: CGFloat = 4
let userCellThinSeparator: CGFloat = 1

class UserDropDownCell: UITableViewCell {
    
    let borders = false
    
    var cellHeight: CGFloat
    
    let nameLabel: UILabel
    let rightView: UIImageView

    var group: Group!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.font = UIFont(name: "OpenSans", size: 17.5)!
        nameLabel.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        
        self.cellHeight = CGFloat(0)
        
        rightView = UIImageView(frame: CGRectZero)
        
        if (borders) {
            nameLabel.layer.borderWidth = 1
            nameLabel.layer.borderColor = UIColor.redColor().CGColor
            rightView.layer.borderWidth = 1
            rightView.layer.borderColor = UIColor.redColor().CGColor
            
        }
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        
        let rightImage = UIImage(named: "right") as UIImage!
        rightView.image = rightImage
        let imageWidth = rightImage.size.width
        let imageHeight = rightImage.size.height
        let imageX = self.frame.size.width + 2*userCellInset
        let imageY = CGFloat(0)
        rightView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight)
        
        self.addSubview(rightView)
        
        nameLabel.frame = CGRectMake(2*userCellInset, userCellInset, contentView.frame.width + userCellInset - rightView.frame.width, 20.0)
        
        contentView.addSubview(nameLabel)
        
        self.layoutMargins = UIEdgeInsetsZero
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithGroup(group: Group, arrow: Bool) {
        self.group = group
        
        nameLabel.frame = CGRectMake(6*userCellInset, userCellInset, contentView.frame.width + userCellInset, 20.0)
        self.nameLabel.text = group.name
        nameLabel.sizeToFit()
        rightView.frame.origin.y = nameLabel.frame.midY - rightView.frame.height / 2
        
        let separator = UIView(frame: CGRectMake(0, self.frame.height - userCellThinSeparator, self.frame.width, userCellThinSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
        
        if (!arrow) {
            self.rightView.hidden = true
        }
    }
    
    func configureAllUsers() {
        nameLabel.text = "All"
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        nameLabel.sizeToFit()
        rightView.frame.origin.y = nameLabel.frame.midY - rightView.frame.height / 2
        
        let separator = UIView(frame: CGRectMake(0, self.frame.height - userCellThickSeparator, self.frame.width, userCellThickSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
    }
    
    func configureLogout() {
        self.nameLabel.text = "Logout"
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        nameLabel.sizeToFit()
        nameLabel.frame.origin.y = nameLabel.frame.origin.y + userCellThickSeparator - userCellThinSeparator
        rightView.frame.origin.y = nameLabel.frame.midY - rightView.frame.height / 2
        
        let separator = UIView(frame: CGRectMake(0, 0, self.frame.width, userCellThickSeparator - userCellThinSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
    }
}