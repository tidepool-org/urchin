//
//  LoginViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

let labelInset: CGFloat = 16

class LogInViewController : UIViewController {
    
    let logoView: UIImageView
    let titleLabel: UILabel
    let emailField: UITextField
    let passwordField: UITextField
    let rememberMeSwitch: UISwitch
    let rememberMeLabel: UILabel
    let logInButton: UIButton
    let tidepoolLogoView: UIImageView
    
    var isLogoDisplayed: Bool
    var isAnimating: Bool
    var logoDisplayShift: CGFloat
    var halfHeight: CGFloat
    
    var keyboardFrame: CGRect
    
    required init(coder aDecoder: NSCoder) {
        logoView = UIImageView(frame: CGRectZero)
        titleLabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, CGFloat.max))
        emailField = UITextField(frame: CGRectZero)
        passwordField = UITextField(frame: CGRectZero)
        rememberMeSwitch = UISwitch(frame: CGRectZero)
        rememberMeLabel = UILabel(frame: CGRectZero)
        logInButton = UIButton(frame: CGRectZero)
        tidepoolLogoView = UIImageView(frame: CGRectZero)
        
        isLogoDisplayed = true
        isAnimating = false
        logoDisplayShift = 0
        halfHeight = 0
        
        keyboardFrame = CGRectZero
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("log in view controller")
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        // configure logo
        let image = UIImage(named: "urchinlogo") as UIImage!
        logoView.image = image
        let imageWidth = CGFloat(128)
        let imageHeight = CGFloat(128)
        let imageX = self.view.frame.width / 2 - CGFloat(imageWidth / 2)
        logoView.frame = CGRect(x: imageX, y: 0, width: imageWidth, height: imageHeight)
        
        // configure title
        titleLabel.text = "urchin"
        titleLabel.font = UIFont(name: "OpenSans-Bold", size: 25)!
        titleLabel.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        titleLabel.sizeToFit()
        let titleX = self.view.frame.width / 2 - titleLabel.frame.width / 2
        titleLabel.frame = CGRectMake(titleX, 0, titleLabel.frame.width, titleLabel.frame.height)
        
        // configure email entry field
        let emailFieldWidth = self.view.frame.width - 2 * labelInset
        let emailFieldHeight = CGFloat(48)
        let emailFieldX = self.view.frame.width / 2 - emailFieldWidth / 2
        emailField.frame = CGRectMake(emailFieldX, 0, emailFieldWidth, emailFieldHeight)
        emailField.borderStyle = UITextBorderStyle.Line
        emailField.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        emailField.layer.borderWidth = 1
        emailField.attributedPlaceholder = NSAttributedString(string:"email",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 188/255, green: 190/255, blue: 192/255, alpha: 1), NSFontAttributeName: UIFont(name: "OpenSans", size: 25)!])
        emailField.font = UIFont(name: "OpenSans", size: 25)!
        emailField.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        let padding = UIView(frame: CGRectMake(0, 0, 12, emailField.frame.height))
        emailField.leftView = padding
        emailField.leftViewMode = UITextFieldViewMode.Always
        emailField.backgroundColor = UIColor.whiteColor()
        emailField.autocapitalizationType = UITextAutocapitalizationType.None
        emailField.autocorrectionType = UITextAutocorrectionType.No
        emailField.spellCheckingType = UITextSpellCheckingType.No
        emailField.enablesReturnKeyAutomatically = true
        emailField.keyboardAppearance = UIKeyboardAppearance.Dark
        emailField.keyboardType = UIKeyboardType.EmailAddress
        emailField.returnKeyType = UIReturnKeyType.Done
        emailField.secureTextEntry = false
        
        // configure password entry field
        let passwordFieldWidth = self.view.frame.width - 2 * labelInset
        let passwordFieldHeight = CGFloat(48)
        let passwordFieldX = self.view.frame.width / 2 - passwordFieldWidth / 2
        passwordField.frame = CGRectMake(passwordFieldX, 0, passwordFieldWidth, passwordFieldHeight)
        passwordField.borderStyle = UITextBorderStyle.Line
        passwordField.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        passwordField.layer.borderWidth = 1
        passwordField.attributedPlaceholder = NSAttributedString(string:"password",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 188/255, green: 190/255, blue: 192/255, alpha: 1), NSFontAttributeName: UIFont(name: "OpenSans", size: 25)!])
        passwordField.font = UIFont(name: "OpenSans", size: 25)!
        passwordField.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        let paddingAgain = UIView(frame: CGRectMake(0, 0, 12, passwordField.frame.height))
        passwordField.leftView = paddingAgain
        passwordField.leftViewMode = UITextFieldViewMode.Always
        passwordField.backgroundColor = UIColor.whiteColor()
        passwordField.autocapitalizationType = UITextAutocapitalizationType.None
        passwordField.autocorrectionType = UITextAutocorrectionType.No
        passwordField.spellCheckingType = UITextSpellCheckingType.No
        passwordField.enablesReturnKeyAutomatically = true
        passwordField.keyboardAppearance = UIKeyboardAppearance.Dark
        passwordField.keyboardType = UIKeyboardType.Default
        passwordField.returnKeyType = UIReturnKeyType.Done
        passwordField.secureTextEntry = true
        
        // configure the remember me check box
        // NEED TO CHANGE FROM SWITCH TO CHECK BOX
        let rememberX = labelInset
        rememberMeSwitch.frame = CGRectMake(rememberX, 0, 0, 0)
        
        // configure remember me label
        rememberMeLabel.text = "Remember me"
        rememberMeLabel.font = UIFont(name: "OpenSans", size: 17.5)!
        rememberMeLabel.textColor = UIColor(red: 152/255, green: 152/255, blue: 151/255, alpha: 1)
        rememberMeLabel.sizeToFit()
        let rememberLabelX = rememberX + rememberMeSwitch.frame.width + 2 * labelSpacing
        rememberMeLabel.frame = CGRectMake(rememberLabelX, 0, rememberMeLabel.frame.width, rememberMeLabel.frame.height)
        
        // configure log in button
        let logInWidth = CGFloat(100)
        let logInHeight = CGFloat(50)
        let logInX = self.view.frame.width - (labelInset + logInWidth)
        logInButton.frame = CGRectMake(logInX, 0, logInWidth, logInHeight)
        logInButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        logInButton.setAttributedTitle(NSAttributedString(string:"Log in",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
        logInButton.addTarget(self, action: "logInPressed:", forControlEvents: .TouchUpInside)
        
        // determine halfHeight of all UI elements
        halfHeight = (titleLabel.frame.height + labelSpacing + logoView.frame.height + 4*labelSpacing + emailField.frame.height + labelSpacing + passwordField.frame.height + 2*labelSpacing + logInButton.frame.height) / 2
        
        // configure y-position of UI elements relative to center of view
        let centerY = self.view.frame.height / 2
        uiElementLocationFromCenterY(centerY)
        
        
        // add UI elements to view
        self.view.addSubview(titleLabel)
        self.view.addSubview(logoView)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(rememberMeSwitch)
        self.view.addSubview(rememberMeLabel)
        self.view.addSubview(logInButton)
        
        // configure and add Tidepool logo to view
        let tidepoolLogo = UIImage(named: "tidepoollogo") as UIImage!
        tidepoolLogoView.image = tidepoolLogo
        let logoWidth = CGFloat(156)
        let logoHeight = logoWidth * CGFloat(43.0/394.0)
        let logoX = self.view.frame.width / 2 - CGFloat(logoWidth / 2)
        let logoY = self.view.frame.height - (2*labelInset + logoHeight)
        tidepoolLogoView.frame = CGRect(x: logoX, y: logoY, width: logoWidth, height: logoHeight)
        
        self.view.addSubview(tidepoolLogoView)
        
        logoDisplayShift = 0 + logoView.frame.height + labelSpacing + titleLabel.frame.height
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func logInPressed(sender: UIButton!) {
        println("log in pressed!")
        
        makeTransition()
    }
    
    func makeTransition() {
        let sarapatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Designer guru.")
        let notesScene = UINavigationController(rootViewController: NotesViewController(user: User(firstName: "Sara", lastName: "Krugman", patient: sarapatient)))
        self.presentViewController(notesScene, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!isAnimating) {
            view.endEditing(true)
            self.moveDownLogIn()
        }
        super.touchesBegan(touches, withEvent: event)
    }

    func keyboardWillShow(notification: NSNotification) {
        println("keyboardWillShow")
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.moveUpLogIn()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        println("keyboardDidShow")
    }
    
    func moveUpLogIn() {
        let centerY = min(self.view.frame.height / 2, keyboardFrame.minY - (2 * labelSpacing + halfHeight))
        if (isLogoDisplayed) {
            self.animateLogIn(centerY) {
                self.isLogoDisplayed = false
            }
        }
    }
    
    func moveDownLogIn() {
        let centerY = self.view.frame.height / 2
        if (!isLogoDisplayed) {
            self.animateLogIn(centerY) {
                self.isLogoDisplayed = true
            }
        }
    }
    
    func animateLogIn(centerY: CGFloat, completion:() -> Void) {
        if (!isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                self.uiElementLocationFromCenterY(centerY)
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        completion()
                    }
            })
        }
    }
    
    func uiElementLocationFromCenterY(centerY: CGFloat) {
        let topY = centerY - halfHeight
        
        titleLabel.frame.origin.y = topY
        logoView.frame.origin.y = titleLabel.frame.origin.y + titleLabel.frame.height + labelSpacing
        emailField.frame.origin.y = logoView.frame.origin.y + logoView.frame.height + 4*labelSpacing
        passwordField.frame.origin.y = emailField.frame.origin.y + emailField.frame.height + labelSpacing
        logInButton.frame.origin.y = passwordField.frame.origin.y + passwordField.frame.height + 2*labelSpacing
        rememberMeSwitch.frame.origin.y = logInButton.frame.midY - rememberMeSwitch.frame.height / 2
        rememberMeLabel.frame.origin.y = logInButton.frame.midY - rememberMeLabel.frame.height / 2
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}