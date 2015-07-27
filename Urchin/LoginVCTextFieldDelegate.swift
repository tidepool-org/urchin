//
//  LoginVCTextFieldDelegate.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

extension LogInViewController: UITextFieldDelegate {
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
    
    // Return actions for textFields
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.isEqual(emailField)) {
            // pass on to passwordField from email field
            passwordField.becomeFirstResponder()
        } else {
            // hide keyboard and animate down from return in passwordField
            if (!isAnimating) {
                view.endEditing(true)
            }
        }
        
        return true
    }
}