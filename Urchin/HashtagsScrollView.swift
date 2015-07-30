//
//  HashtagsScrollView.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class HashtagsScrollView: UIScrollView, UIScrollViewDelegate {
    
    let hashtagsView: HashtagsView = HashtagsView()
    
    // Helper for animations
    var hashtagsCollapsed: Bool = false
    
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let scrollOffset = scrollView.contentOffset.x
        
        if (scrollOffset > 0) {
            println("scrolled")
        }
    }
}