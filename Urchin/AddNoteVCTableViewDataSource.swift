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

extension AddNoteViewController: UITableViewDataSource {
    
    // cellForRowAtIndexPath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Make the cell! UserDropDownCell
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
        
        let customSelection = UIView()
        customSelection.backgroundColor = tealColor
        cell.selectedBackgroundView = customSelection
        
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