//
//  NotesVCTableViewDataSource.swift
//  urchin
//
//  Created by Ethan Look on 7/27/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

extension NotesViewController: UITableViewDataSource {
    // cellForRowAtIndexPath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView.isEqual(notesTable)) {
            
            // Configure NoteCell
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NoteCell), forIndexPath: indexPath) as! NoteCell
            
            cell.configureWithNote(filteredNotes[indexPath.row], user: user)
            
            // Background color based upon odd or even row
            if (indexPath.row % 2 == 0) {
                // even cell
                cell.backgroundColor = lightGreyColor
            } else {
                // odd cell
                cell.backgroundColor = darkestGreyLowAlpha
            }
            
            cell.userInteractionEnabled = true
            
            // editButton tag to be indexPath.row so can be used in editPressed notification handling
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: "editPressed:", forControlEvents: .TouchUpInside)
            
            return cell
        } else {
            // Configure UserDropDownCell
            
            if (indexPath.section == 0 && indexPath.row == 0) {
                // All Users / #nofilter cell
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
                
                cell.configure("all")
                
                return cell
            } else if (indexPath.section == 1 && indexPath.row == 0) {
                // Logout cell
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
                
                cell.configure("logout")
                
                return cell
            } else {
                // Individual group / filter cell
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
                
                cell.configure(groups[indexPath.row - 1], arrow: true, bold: false)
                
                return cell
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (tableView.isEqual(dropDownMenu)) {
            // DropDownMenu
            // Filters and Logout = 2
            return 2
        } else {
            // Just a list of notes
            // Possibly change if conversations are shown in feed?
            return 1
        }
    }
    
    // numberOfRowsInSection
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.isEqual(notesTable)) {
            // NotesTable --> as many cells as filteredNotes
            return filteredNotes.count
        } else if (tableView.isEqual(dropDownMenu)){
            // DropDownMenu
            if (section == 0) {
                // Number of groups + 1 for 'All' / #nofilter
                return groups.count + 1
            } else {
                // Only 1 for 'Logout'
                return 1
            }
        } else {
            // Why not?
            return 0
        }
    }
    
    
}