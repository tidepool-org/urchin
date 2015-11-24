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

class LoadingView: UIView {
    
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let label: UILabel = UILabel()
    
    init(text: String) {
        super.init(frame: CGRectZero)
                
        self.layer.cornerRadius = loadingCornerRadius
        self.backgroundColor = loadingViewBackground
        
        indicator.sizeToFit()
        indicator.startAnimating()
        indicator.color = loadingIndicatorColor
        
        label.text = text
        label.font = mediumRegularFont
        label.textColor = loadingTextColor
        label.sizeToFit()
        
        let width = 2 * labelInset + label.frame.width
        let height = 3 * labelInset + indicator.frame.height + label.frame.height
        self.frame.size = CGSize(width: width, height: height)
        
        indicator.frame.origin = CGPoint(x: self.frame.width / 2 - indicator.frame.width / 2, y: labelInset)
        self.addSubview(indicator)
        
        label.frame.origin = CGPoint(x: self.frame.width / 2 - label.frame.width / 2, y: self.frame.height - (labelInset + label.frame.height))
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}