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

extension EditNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text != defaultMessage) {
            // take the cursor position
            let range = textView.selectedTextRange
            
            // use hashtagBolder extension to bold the hashtags
            let hashtagBolder = HashtagBolder()
            let attributedText = hashtagBolder.boldHashtags(textView.text)
            
            // set textView (messageBox) text to new attributed text
            textView.attributedText = attributedText
            
            // put the cursor back in the same position
            textView.selectedTextRange = range
        }
        if ((note.messagetext != textView.text || note.timestamp != datePicker.date) && textView.text != defaultMessage && !textView.text.isEmpty) {
            postButton.alpha = 1.0
        } else {
            postButton.alpha = 0.5
        }
    }
    
    // textViewDidBeginEditing, clear the messageBox if default message
    func textViewDidBeginEditing(textView: UITextView) {
        self.apiConnector.trackMetric("Clicked On Message Box")
        
        if (textView.text == defaultMessage) {
            textView.text = nil
        }
    }
    
    // textViewDidEndEditing, if empty set back to default message
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultMessage
            textView.textColor = messageTextColor
        }
    }
}