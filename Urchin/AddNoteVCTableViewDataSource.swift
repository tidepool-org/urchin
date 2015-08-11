//
//  AddNoteVCTableViewDataSource.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

extension AddNoteViewController: UITableViewDataSource {
    
    // cellForRowAtIndexPath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Make the cell! UserDropDownCell
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
        
        // Configure with the given group, no arrow, and only bolded if the current group selected is this group
        cell.configure(groups[indexPath.row], last: indexPath.row == groups.count - 1, arrow: false, bold: group === groups[indexPath.row])
        
        return cell
    }
    
    // numberOfSectionsInTableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Only one :) the groups!
        return 1
    }
    
    // numberOfRowsInSection
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of groups (as simple as that)
        return groups.count
    }
    
}