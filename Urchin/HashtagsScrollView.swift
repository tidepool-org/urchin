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

class HashtagsScrollView: UIScrollView, UIScrollViewDelegate {
    
    let hashtagsView: HashtagsView = HashtagsView()
    
    // Helper for animations
    var hashtagsCollapsed: Bool = false
    
    let apiConnector: APIConnector
    
    init(apiConnector: APIConnector) {
        self.apiConnector = apiConnector
        
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHashtagsScrollView() {
        self.delegate = self
        
        hashtagsView.backgroundColor = UIColor.clearColor()
        // see HashtagsView.swift for detailed configuration
        hashtagsView.configureHashtagsView()
        hashtagsView.frame.size = CGSize(width: self.frame.width, height: self.hashtagsView.totalVerticalHashtagsHeight + 2 * labelInset)
        
        self.backgroundColor = UIColor.clearColor()
        self.contentSize = hashtagsView.frame.size
        
        self.addSubview(hashtagsView)
    }
    
    func pagedHashtagsView() {
        self.frame.size.height = expandedHashtagsViewH
        self.hashtagsView.frame.size = CGSize(width: self.frame.width, height: self.hashtagsView.totalVerticalHashtagsHeight + 2 * labelInset)
        self.contentSize = self.hashtagsView.frame.size
        self.hashtagsView.verticalHashtagArrangement()
    }
    
    func sizeZeroHashtagsView() {
        self.frame.size.height = 0.0
        self.hashtagsView.frame.size.height = 0.0
        self.contentSize = self.hashtagsView.frame.size
    }
    
    func linearHashtagsView() {
        self.frame.size.height = condensedHashtagsViewH
        self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.totalLinearHashtagsWidth + 2 * labelInset, height: condensedHashtagsViewH)
        self.contentSize = self.hashtagsView.frame.size
        self.hashtagsView.linearHashtagArrangement()
    }
    
    var contentPosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        for hashtagButton in hashtagsView.hashtagButtons {
            hashtagButton.sendActionsForControlEvents(.TouchCancel)
            hashtagsView.hashtagNormal(hashtagButton)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollOffset = scrollView.contentOffset
        
        if (scrollOffset.x - contentPosition.x > 0) {
            self.apiConnector.trackMetric("Scrolled Right On Hashtags")
        }
        if (scrollOffset.y - contentPosition.y > 0) {
            self.apiConnector.trackMetric("Scrolled Down On Hashtags")
        }
        
        contentPosition = scrollOffset
    }
}