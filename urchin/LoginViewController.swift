//
//  LoginViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class LogInViewController : UIViewController, UIActionSheetDelegate {
    
    // Secret, secret! I got a secret! (Change the server)
    var corners: [CGRect] = []
    var cornersBool: [Bool] = []
    
    // UI Elements
    let logoView: UIImageView = UIImageView()
    let titleLabel: UILabel = UILabel()
    let emailField: UITextField = UITextField()
    let passwordField: UITextField = UITextField()
    let rememberMeView: UIView = UIView()
    let rememberMeCheckbox: UIImageView = UIImageView()
    var rememberMe: Bool = false
    let rememberMeLabel: UILabel = UILabel()
    let signUpView: UIView = UIView()
    let signUpImage: UIImageView = UIImageView()
    let signUpLabel: UILabel = UILabel()
    let logInButton: UIButton = UIButton()
    let tidepoolLogoView: UIImageView = UIImageView()
    let version: UILabel = UILabel()
    
    // Helper values
    var isLogoDisplayed: Bool = true
    var isAnimating: Bool = false
    var halfHeight: CGFloat = 0
    
    // Keyboard frame, used for positioning
    var keyboardFrame: CGRect = CGRectZero
    
    // API connection for login actions
    // passed on to NotesVC
    let apiConnector = APIConnector()
    
    // False when direct login attempt has been made
    var directLogin = true
    
    // True once login has been prepared, false until then
    var loginPrepared = false
    
    // Instantiate the fade animation for transitioning VCs
    let transition = FadeAnimator()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set status bar to dark (for light background color)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color (light grey)
        self.view.backgroundColor = lightGreyColor
        
        // configure and add Tidepool logo to view
        tidepoolLogoView.image = tidepoolLogo
        let logoX = self.view.frame.width / 2 - CGFloat(tidepoolLogoWidth / 2)
        let logoY = self.view.frame.height - (2*labelInset + tidepoolLogoHeight)
        tidepoolLogoView.frame = CGRect(x: logoX, y: logoY, width: tidepoolLogoWidth, height: tidepoolLogoHeight)
        
        self.view.addSubview(tidepoolLogoView)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        // add observer for directLogin
        notificationCenter.addObserver(self, selector: "directLoginAttempt", name: "directLogin", object: nil)
        // add observer for prepareLogin
        notificationCenter.addObserver(self, selector: "prepareLogin", name: "prepareLogin", object: nil)

        if (self.isConnectedToNetwork()) {
            apiConnector.loadServer()
            apiConnector.login()
        } else {
            NSLog("Not connected to network")
            let errorLabel: UILabel = UILabel()
            errorLabel.text = "Please try again when you are connected to a wireless network."
            errorLabel.font = mediumBoldFont
            errorLabel.textColor = blackishColor
            errorLabel.textAlignment = .Center
            errorLabel.numberOfLines = 0
            errorLabel.frame.size = CGSize(width: self.view.frame.width - 2 * loginInset, height: CGFloat.max)
            errorLabel.sizeToFit()
            errorLabel.frame.origin.x = self.view.frame.width / 2 - errorLabel.frame.width / 2
            errorLabel.frame.origin.y = self.view.frame.height / 2 - errorLabel.frame.height / 2
            self.view.addSubview(errorLabel)
        }
        
        let width: CGFloat = 100
        let height: CGFloat = width
        corners.append(CGRect(x: 0, y: 0, width: width, height: height))
        corners.append(CGRect(x: self.view.frame.width - width, y: 0, width: width, height: height))
        corners.append(CGRect(x: 0, y: self.view.frame.height - height, width: width, height: height))
        corners.append(CGRect(x: self.view.frame.width - width, y: self.view.frame.height - height, width: width, height: height))
        for (var i = 0; i < corners.count; i++) {
            cornersBool.append(false)
        }
    }
    
    func checkCorners() {
        for cornerBool in cornersBool {
            if (!cornerBool) {
                return
            }
        }
        
        showServerActionSheet()
    }
    
    func showServerActionSheet() {
        for (var i = 0; i < corners.count; i++) {
            cornersBool[i] = false
        }
        
        let actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.title = "Server"
        
        for server in servers {
            actionSheet.addButtonWithTitle(server.0)
        }
        
        actionSheet.showInView(self.view)
    }
    
    func directLoginAttempt() {
        directLogin = false
        
        if (!apiConnector.x_tidepool_session_token.isEmpty && apiConnector.user != nil) {
            
            apiConnector.trackMetric("Logged In")
            
            let notesScene = UINavigationController(rootViewController: NotesViewController(apiConnector: apiConnector))
            notesScene.transitioningDelegate = self
            self.presentViewController(notesScene, animated: true, completion: nil)
        } else {
            NSLog("Session token is empty or user was not created")
            prepareLogin()
        }
    }
    
    func prepareLogin() {
        
        if (!loginPrepared) {
            loginPrepared = true
            
            NSLog("Preparing log in")
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            
            // add NSNotificationCenter observers for keyboard events
            notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
            
            // add observer for makeTransition to NotesVC
            notificationCenter.addObserver(self, selector: "makeTransition", name: "makeTransitionToNotes", object: nil)
            
            // configure version number for below Tidepool logo, add version number to view
            version.text = UIApplication.versionBuildServer()
            version.font = smallRegularFont
            version.textColor = blackishColor
            version.sizeToFit()
            version.frame.origin.x = self.view.frame.width / 2 - version.frame.width / 2
            version.frame.origin.y = tidepoolLogoView.frame.maxY + labelSpacing
            
            self.view.addSubview(version)
            
            // configure the sign up image
            signUpImage.image = signUpButtonImage
            signUpImage.frame.size = signUpButtonImage.size
            signUpImage.frame.origin = CGPoint(x: loginInset, y: loginInset)
            
            // configure sign up label
            signUpLabel.text = signUpText
            signUpLabel.font = mediumBoldFont
            signUpLabel.textColor = darkestGreyColor
            signUpLabel.sizeToFit()
            let signUpLabelX = loginInset + signUpImage.frame.width + signUpSpacing
            let signUpLabelY = signUpImage.frame.midY - signUpLabel.frame.height / 2
            signUpLabel.frame.origin = CGPoint(x: signUpLabelX, y: signUpLabelY)
            
            // Create a whole view to add the sign up label and image to
            //      --> user can click anywhere in view to trigger sign up process
            let signUpW = signUpImage.frame.width + signUpSpacing + signUpLabel.frame.width + 2 * loginInset
            let signUpH = labelInset + signUpImage.frame.height + labelInset
            signUpView.frame.size = CGSize(width: signUpW, height: signUpH)
            signUpView.frame.origin = CGPoint(x: self.view.frame.width - signUpW, y: 0)
            signUpView.backgroundColor = UIColor.clearColor()
            // tapGesture in view triggers sign up process
            let tapGesture = UITapGestureRecognizer(target: self, action: "signUpPressed:")
            signUpView.addGestureRecognizer(tapGesture)
            // add labels to view
            signUpView.addSubview(signUpImage)
            signUpView.addSubview(signUpLabel)
            
//            self.view.addSubview(signUpView)
            
            // configure logo with notes icon
            logoView.image = notesIcon
            let imageSize: CGFloat = logoView.image!.size.height
            let imageX = self.view.frame.width / 2 - imageSize / 2
            logoView.frame = CGRect(x: imageX, y: 0, width: imageSize, height: imageSize)
            
            // configure title to "Blip notes" (urchin is still a great name)
            titleLabel.text = appTitle
            titleLabel.font = largeBoldFont
            titleLabel.textColor = blackishColor
            titleLabel.sizeToFit()
            let titleX = self.view.frame.width / 2 - titleLabel.frame.width / 2
            titleLabel.frame.origin.x = titleX
            
            // configure email entry field
            let emailFieldWidth = self.view.frame.width - 2 * loginInset
            // email field height smaller for small view sizes
            var emailFieldHeight = textFieldHeight
            if (self.view.frame.height < 500) {
                emailFieldHeight = textFieldHeightSmall
            }
            let emailFieldX = self.view.frame.width / 2 - emailFieldWidth / 2
            emailField.frame = CGRectMake(emailFieldX, 0, emailFieldWidth, emailFieldHeight)
            emailField.borderStyle = UITextBorderStyle.Line
            emailField.layer.borderColor = greyColor.CGColor
            emailField.layer.borderWidth = textFieldBorderWidth
            emailField.attributedPlaceholder = NSAttributedString(string: emailFieldPlaceholder,
                attributes:[NSForegroundColorAttributeName: darkGreyColor, NSFontAttributeName: largeRegularFont])
            emailField.font = largeRegularFont
            emailField.textColor = blackishColor
            let padding = UIView(frame: CGRectMake(0, 0, textFieldInset, emailField.frame.height))
            emailField.leftView = padding
            emailField.leftViewMode = UITextFieldViewMode.Always
            emailField.backgroundColor = textFieldBackgroundColor
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
            let passwordFieldWidth = self.view.frame.width - 2 * loginInset
            // password field height based upon email field height
            let passwordFieldHeight = emailFieldHeight
            let passwordFieldX = self.view.frame.width / 2 - passwordFieldWidth / 2
            passwordField.frame = CGRectMake(passwordFieldX, 0, passwordFieldWidth, passwordFieldHeight)
            passwordField.borderStyle = UITextBorderStyle.Line
            passwordField.layer.borderColor = greyColor.CGColor
            passwordField.layer.borderWidth = 2
            passwordField.attributedPlaceholder = NSAttributedString(string: passFieldPlaceholder,
                attributes:[NSForegroundColorAttributeName: darkGreyColor, NSFontAttributeName: largeRegularFont])
            passwordField.font = largeRegularFont
            passwordField.textColor = blackishColor
            let paddingAgain = UIView(frame: CGRectMake(0, 0, textFieldInset, passwordField.frame.height))
            passwordField.leftView = paddingAgain
            passwordField.leftViewMode = UITextFieldViewMode.Always
            passwordField.backgroundColor = textFieldBackgroundColor
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
            rememberMeCheckbox.image = uncheckedImage
            rememberMeCheckbox.frame = CGRectMake(loginInset, 0, uncheckedImage.size.width, uncheckedImage.size.height)
            
            // configure remember me label
            rememberMeLabel.text = rememberMeText
            rememberMeLabel.font = mediumRegularFont
            rememberMeLabel.textColor = darkestGreyColor
            rememberMeLabel.sizeToFit()
            rememberMeLabel.frame.origin.x = loginInset + rememberMeCheckbox.frame.width + rememberMeSpacing
            
            // Create a whole view to add the remember me label and checkbox to
            //      --> user can click anywhere in view to trigger a checkbox press
            let rememberMeW = rememberMeLabel.frame.maxX + loginInset
            let rememberMeH = labelInset + rememberMeCheckbox.frame.height + labelInset
            rememberMeView.frame.size = CGSize(width: rememberMeW, height: rememberMeH)
            rememberMeView.frame.origin.y = rememberMeCheckbox.frame.minY - labelInset
            rememberMeView.backgroundColor = UIColor.clearColor()
            // tapGesture in view triggers animation
            let tap = UITapGestureRecognizer(target: self, action: "checkboxPressed:")
            rememberMeView.addGestureRecognizer(tap)
            // add labels to view
            rememberMeView.addSubview(rememberMeCheckbox)
            rememberMeView.addSubview(rememberMeLabel)
            
            // configure log in button
            let logInX = self.view.frame.width - (loginInset + loginButtonWidth)
            logInButton.frame = CGRectMake(logInX, 0, loginButtonWidth, loginButtonHeight)
            logInButton.backgroundColor = tealColor
            logInButton.alpha = 0.5
            logInButton.setAttributedTitle(NSAttributedString(string: loginButtonText,
                attributes:[NSForegroundColorAttributeName: loginButtonTextColor, NSFontAttributeName: mediumRegularFont]), forState: UIControlState.Normal)
            logInButton.addTarget(self, action: "logInPressed", forControlEvents: .TouchUpInside)
            
            // determine halfHeight of all UI elements
            halfHeight = (titleLabel.frame.height + titleToLogo + logoView.frame.height + logoToEmail + emailField.frame.height + emailToPass + passwordField.frame.height + passToLogin + logInButton.frame.height) / 2
            
            // configure y-position of UI elements relative to center of view
            let centerY = self.view.frame.height / 2
            uiElementLocationFromCenterY(centerY)
            
            // add UI elements to view
            self.view.addSubview(titleLabel)
            self.view.addSubview(logoView)
            self.view.addSubview(emailField)
            self.view.addSubview(passwordField)
            self.view.addSubview(rememberMeView)
            self.view.addSubview(logInButton)
        }
    }
    
    // called by logInButton
    func logInPressed() {

        // Guards against invalid credentials and animation occuring
        if (checkCredentials() && !isAnimating) {
            view.endEditing(true)
            
            apiConnector.login(self, username: emailField.text, password: passwordField.text)
        }
    }
    
    // pass through to notes scene
    // *** DOES NOT HAVE GUARDS ***
    // do not call from anywhere besides within logInPressed guards
    func makeTransition() {
        
        if (!apiConnector.x_tidepool_session_token.isEmpty && apiConnector.user != nil) {
            
            apiConnector.trackMetric("Logged In")
            
            emailField.text = ""
            passwordField.text = ""
            self.textFieldDidChange(emailField)
            if (rememberMe) {
                self.checkboxPressed(self)
            }
            
            let notesScene = UINavigationController(rootViewController: NotesViewController(apiConnector: apiConnector))
            
            notesScene.transitioningDelegate = self
            
            self.presentViewController(notesScene, animated: true, completion: nil)
        } else {
            NSLog("Session token is empty or user was not created")
        }
    }
    
    // toggle checkbox, set rememberMe values
    func checkboxPressed(sender: AnyObject) {
        if (rememberMe) {
            // currently rememberMe --> change to don't rememberMe
            
            rememberMe = false
            rememberMeCheckbox.image = uncheckedImage
        } else {
            // currently don't rememberMe --> change to rememberMe
            
            rememberMe = true
            rememberMeCheckbox.image = checkedImage
        }
    }
    
    // Trigger sign up process
    // For now, open up signup in browser
    func signUpPressed(sender: UIView!) {
        UIApplication.sharedApplication().openURL(signUpURL)
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
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            
            let touchLocation = touch.locationInView(self.view)
            
            var i = 0
            for corner in corners {
                let viewFrame = self.view.convertRect(corner, fromView: self.view)
                
                if CGRectContainsPoint(viewFrame, touchLocation) {
                    cornersBool[i] = true
                    self.checkCorners()
                    return
                }
                
                i++
            }
        }
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
            UIView.animateKeyframesWithDuration(loginAnimationTime, delay: 0.0, options: nil, animations: { () -> Void in
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
        rememberMeCheckbox.frame.origin.y = labelInset
        rememberMeLabel.frame.origin.y = rememberMeCheckbox.frame.midY - rememberMeLabel.frame.height / 2
        rememberMeView.frame.origin.y = logInButton.frame.midY - (rememberMeCheckbox.frame.height / 2 + labelInset)
        passwordField.frame.origin.y = logInButton.frame.origin.y - (passToLogin + passwordField.frame.height)
        emailField.frame.origin.y = passwordField.frame.origin.y - (emailToPass + emailField.frame.height)
        configureLogoFrame()
        logoView.frame.origin.y = emailField.frame.origin.y - (logoToEmail + logoView.frame.height)
        if (logoView.frame.height >= 50) {
            titleLabel.frame.origin.y = logoView.frame.origin.y - (titleToLogo + titleLabel.frame.height)
        } else {
            titleLabel.frame.origin.y = emailField.frame.origin.y - (titleToLogo + titleLabel.frame.height)
        }
    }
    
    // Size logo appropriately based upon space in view
    func configureLogoFrame() {
        let topToEmailField = emailField.frame.minY
        let space: CGFloat = topToTitle + titleToLogo + logoToEmail
        var proposedLogoSize: CGFloat = topToEmailField - (space + titleLabel.frame.height)
        proposedLogoSize = min(proposedLogoSize, logoView.image!.size.height)
        if (proposedLogoSize < minNotesIconSize) {
            proposedLogoSize = 0
        }
        let imageX = self.view.frame.width / 2 - CGFloat(proposedLogoSize / 2)
        logoView.frame = CGRect(x: imageX, y: 0, width: proposedLogoSize, height: proposedLogoSize)
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
}