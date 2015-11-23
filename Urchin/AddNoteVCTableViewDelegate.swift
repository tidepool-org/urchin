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

extension AddNoteViewController: UITableViewDelegate {
    
    // heightForRowAtIndexPath
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Some group / team / filter
        
        let nameLabel = UILabel()
        nameLabel.frame.size = CGSize(width: self.view.frame.width - 2 * labelInset, height: 20.0)
        nameLabel.text = groups[indexPath.row].fullName
        if (group === groups[indexPath.row]) {
            nameLabel.font = mediumBoldFont
        } else {
            nameLabel.font = mediumRegularFont
        }
        nameLabel.sizeToFit()
        
        return userCellInset + nameLabel.frame.height + userCellInset + userCellThinSeparator
    }
    
    // didSelectRowAtIndexPath
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Immediately deselect row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Set the current group and note's groupid to the selected group
        if (group !== groups[indexPath.row]) {
            self.apiConnector.trackMetric("Clicked Different Person in Add Note")
            
            self.group = groups[indexPath.row]
            self.note.groupid = self.group.userid
        }
        
        // Toggle the dropDownMenu (closed)
        self.dropDownMenuPressed()
    }
    
}