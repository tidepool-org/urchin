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

class LogInViewController : UIViewController, UITextFieldDelegate {
    
    // UI Elements
    let logoView: UIImageView
    let titleLabel: UILabel
    let emailField: UITextField
    let passwordField: UITextField
    let rememberMeCheckbox: UIButton
    var rememberMe: Bool
    let rememberMeLabel: UILabel
    let logInButton: UIButton
    let tidepoolLogoView: UIImageView
    
    // Helper values
    var isLogoDisplayed: Bool
    var isAnimating: Bool
    var halfHeight: CGFloat
    
    // Keyboard frame, used for positioning
    var keyboardFrame: CGRect
    
    required init(coder aDecoder: NSCoder) {
        
        // UI Elements
        logoView = UIImageView(frame: CGRectZero)
        titleLabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, CGFloat.max))
        emailField = UITextField(frame: CGRectZero)
        passwordField = UITextField(frame: CGRectZero)
        rememberMeCheckbox = UIButton(frame: CGRectZero)
        rememberMe = false
        rememberMeLabel = UILabel(frame: CGRectZero)
        logInButton = UIButton(frame: CGRectZero)
        tidepoolLogoView = UIImageView(frame: CGRectZero)
        
        // Helper values, used for animations of UI Elements
        isLogoDisplayed = true
        isAnimating = false
        halfHeight = 0
        
        // Initialize with no keyboard, frame Zero
        keyboardFrame = CGRectZero
        
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set status bar to dark (for light background color)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color (light grey)
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        // configure logo with notes icon
        let image = UIImage(named: "notesicon") as UIImage!
        logoView.image = image
        let imageSize = logoView.image!.size.height
        let imageX = self.view.frame.width / 2 - CGFloat(imageSize / 2)
        logoView.frame = CGRect(x: imageX, y: 0, width: imageSize, height: imageSize)
        
        // configure title to "Blip notes" (urchin is still a great name)
        titleLabel.text = "Blip notes"
        titleLabel.font = UIFont(name: "OpenSans", size: 25)!
        titleLabel.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        titleLabel.sizeToFit()
        let titleX = self.view.frame.width / 2 - titleLabel.frame.width / 2
        titleLabel.frame = CGRectMake(titleX, 0, titleLabel.frame.width, titleLabel.frame.height)
        
        // configure email entry field
        let emailFieldWidth = self.view.frame.width - 2 * 25.0
        // email field height smaller for iPhone 4S
        var emailFieldHeight = CGFloat(71)
        if (UIDevice.currentDevice().modelName == "iPhone 4S") {
            emailFieldHeight = CGFloat(48)
        }
        let emailFieldX = self.view.frame.width / 2 - emailFieldWidth / 2
        emailField.frame = CGRectMake(emailFieldX, 0, emailFieldWidth, emailFieldHeight)
        emailField.borderStyle = UITextBorderStyle.Line
        emailField.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        emailField.layer.borderWidth = 2
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
        emailField.delegate = self
        emailField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // configure password entry field
        let passwordFieldWidth = self.view.frame.width - 2 * 25.0
        // password field height based upon email field height
        let passwordFieldHeight = emailFieldHeight
        let passwordFieldX = self.view.frame.width / 2 - passwordFieldWidth / 2
        passwordField.frame = CGRectMake(passwordFieldX, 0, passwordFieldWidth, passwordFieldHeight)
        passwordField.borderStyle = UITextBorderStyle.Line
        passwordField.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        passwordField.layer.borderWidth = 2
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
        passwordField.delegate = self
        passwordField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // configure the remember me check box
        let rememberX = CGFloat(25)
        let unchecked = UIImage(named: "unchecked") as UIImage!
        rememberMeCheckbox.setImage(unchecked, forState: .Normal)
        rememberMeCheckbox.addTarget(self, action: "checkboxPressed:", forControlEvents: .TouchUpInside)
        rememberMeCheckbox.frame = CGRectMake(rememberX, 0, unchecked.size.width, unchecked.size.height)
        
        // configure remember me label
        rememberMeLabel.text = "Remember me"
        rememberMeLabel.font = UIFont(name: "OpenSans", size: 17.5)!
        rememberMeLabel.textColor = UIColor(red: 152/255, green: 152/255, blue: 151/255, alpha: 1)
        let tapGesture = UITapGestureRecognizer(target: self, action: "checkboxPressed:")
        tapGesture.numberOfTapsRequired = 1
        rememberMeLabel.addGestureRecognizer(tapGesture)
        rememberMeLabel.userInteractionEnabled = true
        rememberMeLabel.sizeToFit()
        let rememberLabelX = rememberX + rememberMeCheckbox.frame.width + 11.0
        rememberMeLabel.frame = CGRectMake(rememberLabelX, 0, rememberMeLabel.frame.width, rememberMeLabel.frame.height)
        
        // configure log in button
        let logInWidth = CGFloat(100)
        let logInHeight = CGFloat(50)
        let logInX = self.view.frame.width - (25.0 + logInWidth)
        logInButton.frame = CGRectMake(logInX, 0, logInWidth, logInHeight)
        logInButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        logInButton.alpha = 0.5
        logInButton.setAttributedTitle(NSAttributedString(string:"Log in",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 17.5)!]), forState: UIControlState.Normal)
        logInButton.addTarget(self, action: "logInPressed", forControlEvents: .TouchUpInside)
        
        // determine halfHeight of all UI elements
        halfHeight = (titleLabel.frame.height + 14.5 + logoView.frame.height + 26.5 + emailField.frame.height + 10.21 + passwordField.frame.height + 12.5 + logInButton.frame.height) / 2
        
        // configure y-position of UI elements relative to center of view
        let centerY = self.view.frame.height / 2
        uiElementLocationFromCenterY(centerY)
        
        
        // add UI elements to view
        self.view.addSubview(titleLabel)
        self.view.addSubview(logoView)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(rememberMeCheckbox)
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
        
        // configure version number for below Tidepool logo, add version number to view
        let versionNumber = UILabel(frame: CGRectZero)
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber.text = "v.\(version)"
            versionNumber.font = UIFont(name: "OpenSans", size: 12.5)!
            versionNumber.textColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
            versionNumber.sizeToFit()
            versionNumber.frame.origin.x = self.view.frame.width / 2 - versionNumber.frame.width / 2
            versionNumber.frame.origin.y = tidepoolLogoView.frame.maxY + labelSpacing
            
            self.view.addSubview(versionNumber)
        }
        
        // add NSNotificationCenter observers for keyboard events
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // called by passwordField and logInButton
    func logInPressed() {

        // Guards against invalid credentials and animation occuring
        if (checkCredentials() && !isAnimating) {
            view.endEditing(true)
            makeTransition()
        }
    }
    
    // pass through to notes scene
    // *** DOES NOT HAVE GUARDS ***
    // do not call from anywhere besides within logInPressed guards
    func makeTransition() {
        
        emailField.text = ""
        passwordField.text = ""
        
        let sarapatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Designer guru.")
        let notesScene = UINavigationController(rootViewController: NotesViewController(user: User(firstName: "Sara", lastName: "Krugman", patient: sarapatient)))
        self.presentViewController(notesScene, animated: true, completion: nil)
    }
    
    // toggle checkbox, set rememberMe values
    func checkboxPressed(sender: UIView!) {
        if (rememberMe) {
            // currently rememberMe --> change to don't rememberMe
            
            rememberMe = false
            let unchecked = UIImage(named: "unchecked") as UIImage!
            rememberMeCheckbox.setImage(unchecked, forState: .Normal)
        } else {
            // currently don't rememberMe --> change to rememberMe
            
            rememberMe = true
            let unchecked = UIImage(named: "checked") as UIImage!
            rememberMeCheckbox.setImage(unchecked, forState: .Normal)
        }
    }
    
    // handle touch events
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!isAnimating) {
            // if not currently animating, end editing
            view.endEditing(true)
            self.moveDownLogIn()
        }
        super.touchesBegan(touches, withEvent: event)
    }

    // UIKeyboardWillShowNotification
    func keyboardWillShow(notification: NSNotification) {
        // store the frame of the incoming keyboard
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.moveUpLogIn()
    }
    
    // UIKeyboardWillHideNotification
    func keyboardWillHide(notification: NSNotification) {
        // move logIn elements to center position
        self.moveDownLogIn()
    }
    
    // Move the login up for keyboard
    // only will run if login is currently 'down'
    func moveUpLogIn() {
        let centerY = min(self.view.frame.height / 2, keyboardFrame.minY - (2 * labelSpacing + halfHeight))
        if (isLogoDisplayed) {
            self.animateLogIn(centerY) {
                self.isLogoDisplayed = false
            }
        }
    }
    
    // Move the login down when editing has ended
    // only will run if login is currently 'up'
    func moveDownLogIn() {
        let centerY = self.view.frame.height / 2
        if (!isLogoDisplayed) {
            self.animateLogIn(centerY) {
                self.isLogoDisplayed = true
            }
        }
    }
    
    // Animate login UI elements to a centerY location
    // used by moveUp/moveDownLogIn
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
    
    // Vertical UI Element location based upon centerY and halfHeight of all elements
    // Tidepool logo and version number are fixed
    func uiElementLocationFromCenterY(centerY: CGFloat) {
        let bottomY = centerY + halfHeight
        
        logInButton.frame.origin.y = bottomY - logInButton.frame.height
        rememberMeCheckbox.frame.origin.y = logInButton.frame.midY - rememberMeCheckbox.frame.height / 2
        rememberMeLabel.frame.origin.y = logInButton.frame.midY - rememberMeLabel.frame.height / 2
        passwordField.frame.origin.y = logInButton.frame.origin.y - (12.5 + passwordField.frame.height)
        emailField.frame.origin.y = passwordField.frame.origin.y - (10.21 + emailField.frame.height)
        configureLogoFrame()
        logoView.frame.origin.y = emailField.frame.origin.y - (26.5 + logoView.frame.height)
        if (logoView.frame.height >= 50) {
            titleLabel.frame.origin.y = logoView.frame.origin.y - (14.5 + titleLabel.frame.height)
        } else {
            titleLabel.frame.origin.y = emailField.frame.origin.y - (14.5 + titleLabel.frame.height)
        }
    }
    
    // Size logo appropriately based upon space in view
    func configureLogoFrame() {
        let topToEmailField = emailField.frame.minY
        var proposedLogoSize = topToEmailField - (73.5 + titleLabel.frame.height)
        proposedLogoSize = min(proposedLogoSize, logoView.image!.size.height)
        if (proposedLogoSize < 50) {
            proposedLogoSize = 0.0
        }
        let imageX = self.view.frame.width / 2 - CGFloat(proposedLogoSize / 2)
        logoView.frame = CGRect(x: imageX, y: 0, width: proposedLogoSize, height: proposedLogoSize)
    }
    
    // Change the textField border to blue when textField is being edited
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1).CGColor
    }
    
    // Change the textField border to gray when textField is done being edited
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
    }
    
    func textFieldDidChange(textField: UITextField) {
        // Change the opacity of the login button based upon whether or not credentials are valid
        // solid if credentials are good
        // half weight otherwise
        if (checkCredentials()) {
            logInButton.alpha = 1.0
        } else {
            logInButton.alpha = 0.5
        }
    }
    
    // Check login credentials
    func checkCredentials() -> Bool {
        /* Guards against:
            - empty emailField
            - invalid email
            - empty passwordField
        */
        return !emailField.text.isEmpty && isValidEmail(emailField.text) && !passwordField.text.isEmpty
    }
    
    // Return actions for textFields
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.isEqual(emailField)) {
            // pass on to passwordField from email field
            passwordField.becomeFirstResponder()
        } else {
            // attempt login from passwordField
            logInPressed()
        }
        
        return true
    }
    
    // Check validity of email
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
        
    }
    
    // Only vertical orientation supported
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}