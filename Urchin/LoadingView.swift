//
//  LoadingView.swift
//  urchin
//
//  Created by Ethan Look on 7/17/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//
//  Use the following code to add a loading view:
//
//  let loading = LoadingView(text: "Your text here...")
//  let loadingX = self.view.frame.width / 2 - loading.frame.width / 2
//  let loadingY = self.view.frame.height / 2 - loading.frame.height / 2
//  loading.frame.origin = CGPoint(x: loadingX, y: loadingY)
//  self.view.addSubview(loading)
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let label: UILabel = UILabel()
    
    init(text: String) {
        super.init(frame: CGRectZero)
        
        println("i am awesome")
        
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
        
        indicator.sizeToFit()
        indicator.startAnimating()
        indicator.color = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        
        label.text = text
        label.font = UIFont(name: "OpenSans", size: 17.5)!
        label.textColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        label.sizeToFit()
        
        let width = 2 * labelInset + label.frame.width
        let height = 3 * labelInset + indicator.frame.height + label.frame.height
        self.frame.size = CGSize(width: width, height: height)
        
        indicator.frame.origin = CGPoint(x: self.frame.width / 2 - indicator.frame.width / 2, y: labelInset)
        self.addSubview(indicator)
        
        label.frame.origin = CGPoint(x: self.frame.width / 2 - label.frame.width / 2, y: self.frame.height - (labelInset + label.frame.height))
        self.addSubview(label)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}