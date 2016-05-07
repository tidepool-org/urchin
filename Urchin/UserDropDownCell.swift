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
    let healthConnectionSwitch: UISwitch = UISwitch()
    let healthStatusLine1: UILabel = UILabel()
    let healthStatusLine2: UILabel = UILabel()
    let healthStatusLine3: UILabel = UILabel()
    let rightView: UIImageView = UIImageView()
    let separator: UIView = UIView()

    // Group for the cell
    var group: User!

    var delegate: UserDropDownCellDelegate?
    
    func configure(key: String, arrow: Bool = true, group: User? = nil) {
        healthConnectionSwitch.tintColor = whiteColor
        healthConnectionSwitch.thumbTintColor = whiteColor
        healthConnectionSwitch.onTintColor = purpleColor
        healthConnectionSwitch.removeFromSuperview()
        healthStatusLine1.removeFromSuperview()
        healthStatusLine2.removeFromSuperview()
        healthStatusLine3.removeFromSuperview()
        
        separator.removeFromSuperview()
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
            separator.backgroundColor = white20PercentAlpha
            self.addSubview(separator)
        } else if (key == "healthkit") {
            self.selectionStyle = .None

            // Configure nameLabel (label for healthConnectionSwitch)
            nameLabel.text = healthKitTitle
            nameLabel.font = mediumBoldFont
            nameLabel.sizeToFit()
            nameLabel.frame.origin.y = userCellThickSeparator + userCellInset
            
            // Configure the separator at the top
            separator.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: userCellThinSeparator)
            separator.backgroundColor = white20PercentAlpha
            self.addSubview(separator)

            // Configure healthConnectionSwitch
            healthConnectionSwitch.frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.width + 8
            healthConnectionSwitch.frame.origin.y = userCellThickSeparator + 12
            healthConnectionSwitch.on = HealthKitConfiguration.sharedInstance.healthKitInterfaceEnabledForCurrentUser()
            DDLogInfo("Switch is: \(healthConnectionSwitch.on.boolValue)")
            healthConnectionSwitch.addTarget(self, action: #selector(healthConnectionSwitchValueChanged), forControlEvents: UIControlEvents.ValueChanged)
            self.addSubview(healthConnectionSwitch)

            // Configure status lines
            if HealthKitConfiguration.sharedInstance.healthKitInterfaceEnabledForCurrentUser() {
                switch HealthKitDataUploader.sharedInstance.uploadPhaseBloodGlucoseSamples {
                case .MostRecentSamples:
                    self.configureHealthStatusLines(phase: HealthKitDataUploader.sharedInstance.uploadPhaseBloodGlucoseSamples)
                case .HistoricalSamples:
                    if HealthKitDataUploader.sharedInstance.totalDaysHistoricalBloodGlucoseSamples > 0 {
                        self.configureHealthStatusLines(phase: HealthKitDataUploader.sharedInstance.uploadPhaseBloodGlucoseSamples)
                    } else {
                        self.configureHealthStatusLines(phase: .MostRecentSamples)
                    }
                case .CurrentSamples:
                    self.configureHealthStatusLines(phase: HealthKitDataUploader.sharedInstance.uploadPhaseBloodGlucoseSamples)
                }
            }
        } else if (key == "logout") {
            nameLabel.text = logoutTitle
            nameLabel.font = mediumBoldFont
            nameLabel.sizeToFit()
            nameLabel.frame.origin.y = userCellThickSeparator + userCellInset
            
            // Configure the thin separator at the top
            separator.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: userCellThinSeparator)
            separator.backgroundColor = white20PercentAlpha
            self.addSubview(separator)
        } else if (key == "group") {
            
            // position the nameLabel
            self.nameLabel.frame.origin = CGPoint(x: 3*userCellInset, y: userCellInset)
            
            // configure the thin separator at the bottom of the cell
            separator.frame = CGRect(x: 2*userCellInset, y: self.frame.height - userCellThinSeparator, width: self.frame.width - 2*userCellInset, height: userCellThinSeparator)
            separator.backgroundColor = white20PercentAlpha
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
            separator.backgroundColor = white20PercentAlpha
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
    
    func configureHealthStatusLines(phase phase: HealthKitDataUploader.Phases) {
        switch phase {
        case .MostRecentSamples:
            healthStatusLine1.text = healthKitUploadStatusMostRecentSamples
            healthStatusLine1.font = smallRegularFont
            healthStatusLine1.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
            healthStatusLine1.sizeToFit()
            healthStatusLine1.frame.origin = CGPoint(x: userCellInset, y: nameLabel.frame.origin.y + nameLabel.frame.height + 16)
            self.addSubview(healthStatusLine1)
            
            healthStatusLine2.text = healthKitUploadStatusUploadPausesWhenPhoneIsLocked
            healthStatusLine2.font = smallRegularFont
            healthStatusLine2.textColor = white65PercentAlpha
            healthStatusLine2.sizeToFit()
            healthStatusLine2.frame.origin = CGPoint(x: userCellInset, y: healthStatusLine1.frame.origin.y + healthStatusLine1.frame.height + 4)
            self.addSubview(healthStatusLine2)
        case .HistoricalSamples:
            healthStatusLine1.text = healthKitUploadStatusUploadingCompleteHistory
            healthStatusLine1.font = smallRegularFont
            healthStatusLine1.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
            healthStatusLine1.sizeToFit()
            healthStatusLine1.frame.origin = CGPoint(x: userCellInset, y: nameLabel.frame.origin.y + nameLabel.frame.height + 16)
            self.addSubview(healthStatusLine1)
            
            var healthKitUploadStatusDaysUploadedText = ""
            if HealthKitDataUploader.sharedInstance.totalDaysHistoricalBloodGlucoseSamples > 0 {
                healthKitUploadStatusDaysUploadedText = String(format: healthKitUploadStatusDaysUploaded, HealthKitDataUploader.sharedInstance.currentDayHistoricalBloodGlucoseSamples, HealthKitDataUploader.sharedInstance.totalDaysHistoricalBloodGlucoseSamples)
            }
            healthStatusLine2.text = healthKitUploadStatusDaysUploadedText
            healthStatusLine2.font = smallRegularFont
            healthStatusLine2.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
            healthStatusLine2.sizeToFit()
            healthStatusLine2.frame.origin = CGPoint(x: userCellInset, y: healthStatusLine1.frame.origin.y + healthStatusLine1.frame.height + 4)
            self.addSubview(healthStatusLine2)
            
            healthStatusLine3.text = healthKitUploadStatusUploadPausesWhenPhoneIsLocked
            healthStatusLine3.font = smallRegularFont
            healthStatusLine3.textColor = white65PercentAlpha
            healthStatusLine3.sizeToFit()
            healthStatusLine3.frame.origin = CGPoint(x: userCellInset, y: healthStatusLine2.frame.origin.y + healthStatusLine2.frame.height + 4)
            self.addSubview(healthStatusLine3)
        case .CurrentSamples:
            if HealthKitDataUploader.sharedInstance.totalUploadCountBloodGlucoseSamples > 0 {
                let lastUploadTimeAgoInWords = HealthKitDataUploader.sharedInstance.lastUploadTimeBloodGlucoseSamples.timeAgoInWords(NSDate())
                healthStatusLine1.text = String(format: healthKitUploadStatusLastUploadTime, lastUploadTimeAgoInWords)
            } else {
                healthStatusLine1.text = healthKitUploadStatusNoDataAvailableToUpload
            }
            healthStatusLine1.font = smallRegularFont
            healthStatusLine1.textColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
            healthStatusLine1.sizeToFit()
            healthStatusLine1.frame.origin = CGPoint(x: userCellInset, y: nameLabel.frame.origin.y + nameLabel.frame.height + 16)
            self.addSubview(healthStatusLine1)
            
            healthStatusLine2.text = healthKitUploadStatusDexcomDataDelayed3Hours
            healthStatusLine2.font = smallRegularFont
            healthStatusLine2.textColor = white65PercentAlpha
            healthStatusLine2.sizeToFit()
            healthStatusLine2.frame.origin = CGPoint(x: userCellInset, y: healthStatusLine1.frame.origin.y + healthStatusLine1.frame.height + 4)
            self.addSubview(healthStatusLine2)
        }
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
    
    func healthConnectionSwitchValueChanged(sender: AnyObject) {
        if let healthConnectionSwitch = sender as? UISwitch {
            delegate?.didToggleHealthKit(healthConnectionSwitch)
        }
    }
}