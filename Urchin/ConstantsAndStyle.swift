//
//  ConstantsAndStyle.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

// ------------ USED EVERYWHERE ------------
let labelSpacing: CGFloat = 6
let labelInset: CGFloat = 16

let darkestGreyColor: UIColor = UIColor(red: 152/255, green: 152/255, blue: 151/255, alpha: 1)
let darkestGreyLowAlpha: UIColor = UIColor(red: 152/255, green: 152/255, blue: 151/255, alpha: 0.23)
let darkGreyColor: UIColor = UIColor(red: 188/255, green: 190/255, blue: 192/255, alpha: 1)
let greyColor: UIColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
let lightGreyColor: UIColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
let blackishColor: UIColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
let blackishLowAlpha: UIColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 0.75)
let darkGreenColor: UIColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
let textFieldBackgroundColor: UIColor = UIColor.whiteColor()
let tealColor: UIColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
let whiteColor: UIColor = UIColor.whiteColor()
let loginButtonTextColor: UIColor = whiteColor
let addNoteTextColor: UIColor = whiteColor
let navBarTint: UIColor = whiteColor
let navBarTitleColor: UIColor = whiteColor
let postButtonTextColor: UIColor = whiteColor
let noteTextColor: UIColor = UIColor.blackColor()
let whiteQuarterAlpha: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)

let smallRegularFont: UIFont = UIFont(name: "OpenSans", size: 12.5)!
let mediumRegularFont: UIFont = UIFont(name: "OpenSans", size: 17.5)!
let largeRegularFont: UIFont = UIFont(name: "OpenSans", size: 25)!

let smallBoldFont: UIFont = UIFont(name: "OpenSans-Bold", size: 12.5)!
let mediumBoldFont: UIFont = UIFont(name: "OpenSans-Bold", size: 17.5)!
let largeBoldFont: UIFont = UIFont(name: "OpenSans-Bold", size: 25)!

let appTitle: String = "Blip notes"
let allTeamsTitle: String = "All"
let logoutTitle: String = "Logout"

let maxGroupsShownInDropdown: Int = 3

let dropDownAnimationTime: NSTimeInterval = 0.5

let editButtonHeight: CGFloat = 12.5
let dropDownGroupLabelHeight: CGFloat = 20.0

let downArrow: UIImage = UIImage(named: "down")!
let rightArrow: UIImage = UIImage(named: "right")!
let closeX: UIImage = UIImage(named: "closex")!

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ------------ LoginVC ------------
let notesIcon: UIImage = UIImage(named: "notesicon") as UIImage!

let tidepoolLogo: UIImage = UIImage(named: "tidepoollogo") as UIImage!
let tidepoolLogoWidth: CGFloat = CGFloat(156)
let tidepoolLogoHeight: CGFloat = tidepoolLogoWidth * CGFloat(43.0/394.0)

let uncheckedImage: UIImage = UIImage(named: "unchecked") as UIImage!
let checkedImage: UIImage = UIImage(named: "checked") as UIImage!

let emailFieldPlaceholder: String = "email"
let passFieldPlaceholder: String = "password"
let rememberMeText: String = "Remember me"
let loginButtonText: String = "Log in"

let textFieldHeight: CGFloat = 71
let textFieldHeightSmall: CGFloat = 48
let textFieldBorderWidth: CGFloat = 2
let textFieldInset: CGFloat = 12

let loginInset: CGFloat = 25

let rememberMeSpacing: CGFloat = 8

let loginButtonWidth: CGFloat = 100
let loginButtonHeight: CGFloat = 50

let topToTitle: CGFloat = 32.5
let titleToLogo: CGFloat = 14.5
let logoToEmail: CGFloat = 26.5
let emailToPass: CGFloat = 10.21
let passToLogin: CGFloat = 12.5
let minNotesIconSize: CGFloat = 50

let loginAnimationTime: NSTimeInterval = 0.3

// ------------ NotesVC ------------
let noteImage: UIImage = UIImage(named: "note") as UIImage!

let addNoteButtonHeight: CGFloat = 105

let allNotesTitle: String = "All Notes"
let addNoteText: String = "Add note"
let noteForTitle: String = "Note for..."

let fetchPeriodInMonths: Int = -3

// ------------ AddNoteVC and EditNoteVC ------------
let messageTextColor: UIColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)

let cameraImage: UIImage = UIImage(named: "camera")!
let locationImage: UIImage = UIImage(named: "location")!

let expandedHashtagsViewH: CGFloat = 2 * labelInset + 3 * hashtagHeight + 3 * labelSpacing
let condensedHashtagsViewH: CGFloat = 2 * labelInset + hashtagHeight

let defaultMessage: String = "What's going on?"
let changeDateText: String = "change"
let doneDateText: String = "done"

let addAlertTitle: String = "Discard Note?"
let addAlertMessage: String = "If you close this note, your note will be lost."
let addAlertCancel: String = "Cancel"
let addAlertOkay: String = "Okay"
let postButtonText: String = "Post"
let postButtonSave: String = "Save"

let editAlertTitle: String = "Save Changes?"
let editAlertMessage: String = "You have made changes to this note. Would you like to save these changes?"
let editAlertDiscard: String = "Discard"
let editAlertSave: String = "Save"

let postButtonW: CGFloat = 112
let postButtonH: CGFloat = 41

let datePickerFadeTime: NSTimeInterval = 0.2
let animationTime: NSTimeInterval = 0.3

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ------------ API Connector ------------
let invalidLogin: String = "Invalid Login"
let invalidLoginMessage: String = "Wrong username or password."

let unknownError: String = "Unknown Error Occurred"
let unknownErrorMessage: String = "An unknown error occurred while logging in. We are working hard to resolve this issue."

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ------------ UserDropDownCell -----------
let userCellHeight: CGFloat = 56.0
let userCellInset: CGFloat = 16
let userCellThickSeparator: CGFloat = 4
let userCellThinSeparator: CGFloat = 1

// ------------ NoteCell ------------
let noteCellHeight: CGFloat = 128
let noteCellInset: CGFloat = 16

let editButtonTitle: String = "edit"

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ------------ Hashtags View ------------
let hashtagColor: UIColor = UIColor.whiteColor()
let hashtagBorderColor: UIColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)

let hashtagBorderWidth: CGFloat = 1

let hashtagHeight: CGFloat = 36

// ------------ Loading View ------------
let loadingViewBackground: UIColor = blackishColor
let loadingIndicatorColor: UIColor = tealColor
let loadingTextColor: UIColor = tealColor

let loadingCornerRadius: CGFloat = 10

let loadingLogIn: String = "Logging in..."
let loadingTeams: String = "Loading teams..."
let loadingNotes: String = "Loading notes..."

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ------------ Date Formatter ------------
let uniformDateFormat: String = "EEEE M.d.yy h:mma"
let iso8601dateOne: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
let iso8601dateTwo: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
let regularDateFormat: String = "yyyy-MM-dd"

// ------------ UIDevice ------------
let deviceList =   ["x86_64":         "Simulator",
    "iPod1,1":      "iPod Touch",       // (Original)
    "iPod2,1":      "iPod Touch 2",     // (Second Generation)
    "iPod3,1":      "iPod Touch 3",     // (Third Generation)
    "iPod4,1":      "iPod Touch 4",     // (Fourth Generation)
    "iPhone1,1":    "iPhone 1",         // (Original)
    "iPhone1,2":    "iPhone 3G",        // (3G)
    "iPhone2,1":    "iPhone 3GS",       // (3GS)
    "iPad1,1":      "iPad 1",           // (Original)
    "iPad2,1":      "iPad 2",           //
    "iPad3,1":      "iPad 3",           // (3rd Generation)
    "iPhone3,1":    "iPhone 4",         //
    "iPhone4,1":    "iPhone 4S",        //
    "iPhone5,1":    "iPhone 5",         // (model A1428, AT&T/Canada)
    "iPhone5,2":    "iPhone 5",         // (model A1429, everything else)
    "iPad3,4":      "iPad 4",           // (4th Generation)
    "iPad2,5":      "iPad Mini 1",      // (Original)
    "iPhone5,3":    "iPhone 5c",        // (model A1456, A1532 | GSM)
    "iPhone5,4":    "iPhone 5c",        // (model A1507, A1516, A1526 (China), A1529 | Global)
    "iPhone6,1":    "iPhone 5s",        // (model A1433, A1533 | GSM)
    "iPhone6,2":    "iPhone 5s",        // (model A1457, A1518, A1528 (China), A1530 | Global)
    "iPad4,1":      "iPad Air 1",       // 5th Generation iPad (iPad Air) - Wifi
    "iPad4,2":      "iPad Air 2",       // 5th Generation iPad (iPad Air) - Cellular
    "iPad4,4":      "iPad Mini 2",      // (2nd Generation iPad Mini - Wifi)
    "iPad4,5":      "iPad Mini 2",      // (2nd Generation iPad Mini - Cellular)
    "iPhone7,1":    "iPhone 6 Plus",    // All iPhone 6 Plus's
    "iPhone7,2":    "iPhone 6"          // All iPhone 6's
]