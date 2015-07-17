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
    
    // used in heightForRowAtIndexPath
    // #### TODO: Remove dependancy on cellHeight ####
    var cellHeight: CGFloat
    
    // UI elements
    let nameLabel: UILabel
    let rightView: UIImageView

    // Group for the cell
    var group: User!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // Configure nameLabel
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.font = UIFont(name: "OpenSans", size: 17.5)!
        nameLabel.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        
        // set cellHeight to 0
        self.cellHeight = CGFloat(0)
        
        // Initialize the right view
        rightView = UIImageView(frame: CGRectZero)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Set background color to dark green
        self.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        
        // Configure right image to a lovely right arrow
        let rightImage = UIImage(named: "right") as UIImage!
        rightView.image = rightImage
        let imageWidth = rightImage.size.width
        let imageHeight = rightImage.size.height
        let imageX = self.frame.size.width + 2*userCellInset
        let imageY = CGFloat(0)
        rightView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight)
        
        self.addSubview(rightView)
        
        // Configure the name label
        nameLabel.frame = CGRectMake(2*userCellInset, userCellInset, contentView.frame.width + userCellInset - rightView.frame.width, 20.0)
        
        contentView.addSubview(nameLabel)
        
        // No margins
        self.layoutMargins = UIEdgeInsetsZero
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell to hold a group
    // if arrow, place the right arrow
    // if bold, bold the name
    func configureWithGroup(group: User, arrow: Bool, bold: Bool) {
        self.group = group
        
        // configure the name label with the group name
        nameLabel.frame = CGRectMake(6*userCellInset, userCellInset, contentView.frame.width + userCellInset, 20.0)
        self.nameLabel.text = group.fullName
        if (bold) {
            nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        } else {
            nameLabel.font = UIFont(name: "OpenSans", size: 17.5)!
        }
        nameLabel.sizeToFit()
        rightView.frame.origin.y = nameLabel.frame.midY - rightView.frame.height / 2
        
        // configure the thin separator at the bottom of the cell
        let separator = UIView(frame: CGRectMake(0, self.frame.height - userCellThinSeparator, self.frame.width, userCellThinSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        // determine cell height based upon uielements
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
        
        // hide the right arrow if necessary
        if (!arrow) {
            self.rightView.hidden = true
            
            nameLabel.frame.origin.x = self.frame.width / 2 - nameLabel.frame.width / 2
        }
    }
    
    func configureAllUsers() {
        // Configure nameLabel to be 'All', or #nofilter
        nameLabel.text = "All"
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        nameLabel.sizeToFit()
        nameLabel.frame.origin.y = userCellThickSeparator + userCellInset
        rightView.frame.origin.y = nameLabel.frame.midY - rightView.frame.height / 2
        
        // configure thick separator at the top
        let separator = UIView(frame: CGRectMake(0, 0, self.frame.width, userCellThickSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        // configure thin separator at the bottom
        let separatorTwo = UIView(frame: CGRectMake(0, self.frame.height - userCellThinSeparator, self.frame.width, userCellThinSeparator))
        separatorTwo.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separatorTwo)
        
        // determine the cell height based upon UI elements
        self.cellHeight = userCellThickSeparator + userCellInset + nameLabel.frame.height + userCellInset + userCellThinSeparator
    }
    
    func configureLogout() {
        // Configure the name label to be 'Logout'... for logging out
        self.nameLabel.text = "Logout"
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        nameLabel.sizeToFit()
        nameLabel.frame.origin.y = nameLabel.frame.origin.y + userCellThickSeparator - userCellThinSeparator
        rightView.frame.origin.y = nameLabel.frame.midY - rightView.frame.height / 2
        
        // Configure the thick separator at the top
        // take out the height of the thin separator because the cell above has a thin separator at the bottom
        let separator = UIView(frame: CGRectMake(0, 0, self.frame.width, userCellThickSeparator - userCellThinSeparator))
        separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(separator)
        
        // determine the cell height based upon UI elements
        self.cellHeight = userCellInset + nameLabel.frame.height + userCellInset + separator.frame.height
    }
}