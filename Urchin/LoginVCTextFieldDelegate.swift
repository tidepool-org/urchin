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

extension LogInViewController: UITextFieldDelegate {
    // Change the textField border to blue when textField is being edited
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.layer.borderColor = tealColor.CGColor
    }
    
    // Change the textField border to gray when textField is done being edited
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layer.borderColor = greyColor.CGColor
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