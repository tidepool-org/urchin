//
//  HashtagsScrollView.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class HashtagsScrollView: UIScrollView {
    
    let hashtagsView: HashtagsView = HashtagsView()
    
    // Helper for animations
    var hashtagsCollapsed: Bool = false
    
    func configureHashtagsScrollView() {
        hashtagsView.backgroundColor = UIColor.clearColor()
        // see HashtagsView.swift for detailed configuration
        hashtagsView.configureHashtagsView()
        hashtagsView.frame.size = CGSize(width: hashtagsView.totalPagedHashtagsWidth + 2 * labelInset, height: expandedHashtagsViewH)
        
        self.backgroundColor = UIColor.clearColor()
        self.contentSize = hashtagsView.frame.size
        
        self.addSubview(hashtagsView)
    }
    
    func pagedHashtagsView() {
        self.frame.size.height = expandedHashtagsViewH
        self.hashtagsView.frame.size = CGSize(width: self.hashtagsView.totalPagedHashtagsWidth + 2 * labelInset, height: expandedHashtagsViewH)
        self.contentSize = self.hashtagsView.frame.size
        self.hashtagsView.pageHashtagArrangement()
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
}