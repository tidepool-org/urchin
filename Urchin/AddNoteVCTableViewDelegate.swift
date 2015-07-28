//
//  AddNoteVCTableViewDelegate.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

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
        self.group = groups[indexPath.row]
        self.note.groupid = self.group.userid
        // Toggle the dropDownMenu (closed)
        self.dropDownMenuPressed()
    }
    
}