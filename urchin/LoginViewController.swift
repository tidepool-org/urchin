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
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("log in view controller")
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        let image = UIImage(named: "urchinlogo") as UIImage!
        logoView.image = image
        let imageWidth = CGFloat(128)
        let imageHeight = CGFloat(128)
        let imageX = self.view.frame.width / 2 - CGFloat(imageWidth / 2)
        let imageY = CGFloat(64)
        logoView.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        
        self.view.addSubview(logoView)
        
        titleLabel.text = "urchin"
        titleLabel.font = UIFont.boldSystemFontOfSize(28)
        titleLabel.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRectMake(self.view.frame.width / 2 - titleLabel.frame.width / 2, imageY + logoView.frame.height + labelSpacing, titleLabel.frame.width, titleLabel.frame.height)
        
        self.view.addSubview(titleLabel)
        
        let emailFieldWidth = self.view.frame.width - 2 * labelInset
        let emailFieldHeight = CGFloat(48)
        let emailFieldX = self.view.frame.width / 2 - emailFieldWidth / 2
        let emailFieldY = imageY + logoView.frame.height + labelSpacing + titleLabel.frame.height + 4 * labelSpacing
        emailField.frame = CGRectMake(emailFieldX, emailFieldY, emailFieldWidth, emailFieldHeight)
        emailField.borderStyle = UITextBorderStyle.Line
        emailField.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        emailField.layer.borderWidth = 1
        emailField.attributedPlaceholder = NSAttributedString(string:"email",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 188/255, green: 190/255, blue: 192/255, alpha: 1), NSFontAttributeName: UIFont.boldSystemFontOfSize(18)])
        let padding = UIView(frame: CGRectMake(0, 0, 12, emailField.frame.height))
        emailField.leftView = padding
        emailField.leftViewMode = UITextFieldViewMode.Always
        emailField.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(emailField)
        
        let passwordFieldWidth = self.view.frame.width - 2 * labelInset
        let passwordFieldHeight = CGFloat(48)
        let passwordFieldX = self.view.frame.width / 2 - passwordFieldWidth / 2
        let passwordFieldY = imageY + logoView.frame.height + labelSpacing + titleLabel.frame.height + 4 * labelSpacing + emailField.frame.height + labelSpacing
        passwordField.frame = CGRectMake(passwordFieldX, passwordFieldY, passwordFieldWidth, passwordFieldHeight)
        passwordField.borderStyle = UITextBorderStyle.Line
        passwordField.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        passwordField.layer.borderWidth = 1
        passwordField.attributedPlaceholder = NSAttributedString(string:"password",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 188/255, green: 190/255, blue: 192/255, alpha: 1), NSFontAttributeName: UIFont.boldSystemFontOfSize(18)])
        let paddingAgain = UIView(frame: CGRectMake(0, 0, 12, passwordField.frame.height))
        passwordField.leftView = paddingAgain
        passwordField.leftViewMode = UITextFieldViewMode.Always
        passwordField.backgroundColor = UIColor.whiteColor()
        passwordField.secureTextEntry = true
        
        self.view.addSubview(passwordField)
        
        let rememberX = labelInset
        let rememberY = imageY + logoView.frame.height + labelSpacing + titleLabel.frame.height + 4 * labelSpacing + emailField.frame.height + labelSpacing + passwordField.frame.height + 4 * labelSpacing
        rememberMeSwitch.frame = CGRectMake(rememberX, rememberY, 0, 0)
        
        self.view.addSubview(rememberMeSwitch)
        
        rememberMeLabel.text = "Remember me"
        rememberMeLabel.font = UIFont.boldSystemFontOfSize(17)
        rememberMeLabel.textColor = UIColor(red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
        rememberMeLabel.sizeToFit()
        rememberMeLabel.frame = CGRectMake(rememberX + rememberMeSwitch.frame.width + 2 * labelSpacing, rememberMeSwitch.frame.midY - rememberMeLabel.frame.height / 2, rememberMeLabel.frame.width, rememberMeLabel.frame.height)
        
        self.view.addSubview(rememberMeLabel)
        
        let logInWidth = CGFloat(100)
        let logInHeight = CGFloat(50)
        let logInX = self.view.frame.width - (labelInset + logInWidth)
        let logInY = rememberMeSwitch.frame.minY
        logInButton.frame = CGRectMake(logInX, logInY, logInWidth, logInHeight)
        logInButton.backgroundColor = UIColor(red: 23/255, green: 150/255, blue: 170/255, alpha: 1)
        logInButton.setAttributedTitle(NSAttributedString(string:"Log in",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]), forState: UIControlState.Normal)
        logInButton.addTarget(self, action: "logInPressed:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(logInButton)
        
        let tidepoolLogo = UIImage(named: "tidepoollogo") as UIImage!
        tidepoolLogoView.image = tidepoolLogo
        let logoWidth = CGFloat(128)
        let logoHeight = CGFloat(32.042267051)
        let logoX = self.view.frame.width / 2 - CGFloat(logoWidth / 2)
        let logoY = self.view.frame.height - (CGFloat(16) + logoHeight)
        tidepoolLogoView.frame = CGRect(x: logoX, y: logoY, width: logoWidth, height: logoHeight)
        
        self.view.addSubview(tidepoolLogoView)
        
        logoDisplayShift = imageY + logoView.frame.height + labelSpacing + titleLabel.frame.height
        
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
        
        self.moveUpLogIn()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        println("keyboardDidShow")
    }
    
    func moveUpLogIn() {
        var shift = -logoDisplayShift
        if (isLogoDisplayed) {
            self.animateLogIn(shift) {
                self.isLogoDisplayed = false
            }
        }
    }
    
    func moveDownLogIn() {
        var shift = logoDisplayShift
        if (!isLogoDisplayed) {
            self.animateLogIn(shift) {
                self.isLogoDisplayed = true
            }
        }
    }
    
    func animateLogIn(verticalShift: CGFloat, completion:() -> Void) {
        if (!isAnimating) {
            isAnimating = true
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: nil, animations: { () -> Void in
                self.logoView.frame.origin.y = self.logoView.frame.origin.y + verticalShift
                self.titleLabel.frame.origin.y = self.titleLabel.frame.origin.y + verticalShift
                self.emailField.frame.origin.y = self.emailField.frame.origin.y + verticalShift
                self.passwordField.frame.origin.y = self.passwordField.frame.origin.y + verticalShift
                self.rememberMeSwitch.frame.origin.y = self.rememberMeSwitch.frame.origin.y + verticalShift
                self.rememberMeLabel.frame.origin.y = self.rememberMeLabel.frame.origin.y + verticalShift
                self.logInButton.frame.origin.y = self.logInButton.frame.origin.y + verticalShift
                
                }, completion: { (completed: Bool) -> Void in
                    self.isAnimating = false
                    if (completed) {
                        completion()
                    }
            })
        }
    }
    
}