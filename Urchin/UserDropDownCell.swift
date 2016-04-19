/*
* Copyright (c) 2015, Tidepool Project
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the associated License, which is identical to the BSD 2-Clause
* License as published by the Open Source Initiative at opensource.org.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the License for more details.
*
* You should have received a copy of the License along with this program; if
* not, you can obtain one from Tidepool Project at tidepool.org.
*/

import Foundation
import UIKit
import CocoaLumberjack

protocol UserDropDownCellDelegate {
    func didToggleHealthKit(healthKitSwitch: UISwitch)
}

class UserDropDownCell: UITableViewCell {
    
    // UI elements
    let nameLabel: UILabel = UILabel()
    let connectToHealthSwitch: UISwitch = UISwitch()
    let rightView: UIImageView = UIImageView()
    let separator: UIView = UIView()

    // Group for the cell
    var group: User!

    var delegate: UserDropDownCellDelegate?
    
    func configure(key: String, arrow: Bool = true, group: User? = nil) {
        separator.removeFromSuperview()
        connectToHealthSwitch.removeFromSuperview()
        self.selectionStyle = .Default
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.25
        
        self.group = group
        
        // Set background color to dark green
        self.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        
        // Configure nameLabel
        nameLabel.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        nameLabel.frame.origin.x = userCellInset
        
        // Configure right image to a lovely right arrow
        rightView.image = rightArrow
        rightView.hidden = !arrow
        
        if (key == "all") {
            nameLabel.text = allTeamsTitle
            nameLabel.font = mediumBoldFont
            nameLabel.sizeToFit()
            nameLabel.frame.origin.y = userCellInset
            
            // configure thin separator at the bottom
            separator.frame = CGRect(x: 2*userCellInset, y: self.frame.height - userCellThinSeparator, width: self.frame.width - 2*userCellInset, height: userCellThinSeparator)
            separator.backgroundColor = whiteQuarterAlpha
            self.addSubview(separator)
        } else if (key == "healthkit") {
            self.selectionStyle = .None

            nameLabel.text = healthKitTitle
            nameLabel.font = mediumBoldFont
            nameLabel.sizeToFit()
            nameLabel.frame.origin.y = userCellThickSeparator + userCellInset

            connectToHealthSwitch.frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.width + 8
            connectToHealthSwitch.frame.origin.y = userCellThickSeparator + 12
            connectToHealthSwitch.on = HealthKitConfiguration.sharedInstance.healthKitInterfaceEnabledForCurrentUser()
            DDLogInfo("Switch is: \(connectToHealthSwitch.on.boolValue)")
            connectToHealthSwitch.addTarget(self, action: #selector(connectToHealthSwitchValueChanged), forControlEvents: UIControlEvents.ValueChanged)
            self.addSubview(connectToHealthSwitch)
            
            // Configure the separator at the top
            separator.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: userCellThinSeparator)
            separator.backgroundColor = whiteQuarterAlpha
            self.addSubview(separator)
        } else if (key == "healthkit-status") {
            let lastUploadSampleTime = NSDateFormatter.localizedStringFromDate(HealthKitDataUploader.sharedInstance.lastUploadSampleTimeBloodGlucoseSamples, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
            if HealthKitDataUploader.sharedInstance.shouldUploadMostRecentFirst {
                nameLabel.text = healthKitUploadStatusMostRecentSamples
            } else {
                switch HealthKitDataUploader.sharedInstance.totalUploadCountBloodGlucoseSamplesWithoutDuplicates {
                case 0:
                    nameLabel.text = String(format: healthKitUploadStatusNoSamplesFound, lastUploadSampleTime)
                case 1:
                    nameLabel.text = String(format: healthKitUploadStatusSamplesUploadedWithCountSingular, HealthKitDataUploader.sharedInstance.totalUploadCountBloodGlucoseSamplesWithoutDuplicates, lastUploadSampleTime)
                default:
                    nameLabel.text = String(format: healthKitUploadStatusSamplesUploadedWithCountPlural, HealthKitDataUploader.sharedInstance.totalUploadCountBloodGlucoseSamplesWithoutDuplicates, lastUploadSampleTime)
                }
            }
            
            nameLabel.font = smallRegularFont
            nameLabel.sizeToFit()
            nameLabel.frame.origin = CGPoint(x: 3 * userCellInset, y: userCellThinSeparator + userCellHealthKitSampleInset)
            
            // Configure the separator
            separator.frame = CGRect(x: 2 * userCellInset, y: 0, width: self.frame.width - 2 * userCellInset, height: userCellThinSeparator)
            separator.backgroundColor = whiteQuarterAlpha
            self.addSubview(separator)
        } else if (key == "logout") {
            nameLabel.text = logoutTitle
            nameLabel.font = mediumBoldFont
            nameLabel.sizeToFit()
            nameLabel.frame.origin.y = userCellThickSeparator + userCellInset
            
            // Configure the thin separator at the top
            separator.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: userCellThinSeparator)
            separator.backgroundColor = whiteQuarterAlpha
            self.addSubview(separator)
        } else if (key == "group") {
            
            // position the nameLabel
            self.nameLabel.frame.origin = CGPoint(x: 3*userCellInset, y: userCellInset)
            
            // configure the thin separator at the bottom of the cell
            separator.frame = CGRect(x: 2*userCellInset, y: self.frame.height - userCellThinSeparator, width: self.frame.width - 2*userCellInset, height: userCellThinSeparator)
            separator.backgroundColor = whiteQuarterAlpha
            self.addSubview(separator)
        } else if (key == "grouplast") {
            
            // position the nameLabel
            self.nameLabel.frame.origin = CGPoint(x: 3*userCellInset, y: userCellInset)            
        } else if (key == "version") {
            // Configure the name label to contain the version
            nameLabel.text = UIApplication.versionBuildServer()
            nameLabel.font = smallRegularFont
            nameLabel.sizeToFit()
            nameLabel.frame.origin.x = self.frame.width / 2 - nameLabel.frame.width / 2
            nameLabel.frame.origin.y = userCellThickSeparator + ((self.frame.height - userCellThickSeparator) / 2 - nameLabel.frame.height / 2)
            
            // Configure the thick separator at the top
            separator.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: userCellThickSeparator)
            separator.backgroundColor = whiteQuarterAlpha
            self.addSubview(separator)
            
            rightView.hidden = true
        }
        
        let imageWidth = rightArrow.size.width
        let imageHeight = rightArrow.size.height
        let imageX = self.frame.width - (userCellInset + imageWidth)
        let imageY = nameLabel.frame.midY - imageHeight / 2
        rightView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight)
        
        self.addSubview(rightView)
        self.addSubview(nameLabel)
    }
    
    func configure(group: User, last: Bool, arrow: Bool, bold: Bool) {
        self.group = group
        
        // configure the name label with the group name
        nameLabel.text = group.fullName
        if (bold) {
            nameLabel.font = mediumBoldFont
        } else {
            nameLabel.font = mediumRegularFont
        }
        nameLabel.sizeToFit()
        nameLabel.frame.size.width = min(nameLabel.frame.width, contentView.frame.width - 6 * userCellInset)
        
        if last {
            configure("grouplast", group: group)
        } else {
            configure("group", group: group)
        }
        
        // hide the right arrow if necessary
        if (!arrow) {
            self.rightView.hidden = true
            
            separator.frame.size.width = self.frame.width - 4 * noteCellInset
            
            nameLabel.frame.origin.x = self.frame.width / 2 - nameLabel.frame.width / 2
        }
    }
    
    func connectToHealthSwitchValueChanged(sender: AnyObject) {
        if let connectToHealthSwitch = sender as? UISwitch {
            delegate?.didToggleHealthKit(connectToHealthSwitch)
        }
    }
}