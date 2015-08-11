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
            
            if (indexPath.row % 2 == 1) {
                
                // Configure Spacing Cell
                
                let cell = UITableViewCell()
                
                cell.backgroundColor = darkestGreyLowAlpha
                
                let test = UIView(frame: CGRect(x: 0, y: 0.5, width: self.view.frame.width, height: 5))
                test.backgroundColor = darkestGreyLowAlpha
                cell.addSubview(test)
//                cell.layer.borderColor = UIColor.blackColor().CGColor
//                cell.layer.borderWidth = 0.25
                
                return cell
                
            } else {
                // Configure NoteCell
                
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NoteCell), forIndexPath: indexPath) as! NoteCell
                
                let note = filteredNotes[indexPath.row / 2]
                
                // If the note is between different users, need a "to so-and-so" appendage
                var groupName: String = ""
                if (note.groupid != note.userid) {
                    for group in groups {
                        if (group.userid == note.groupid) {
                            groupName = group.fullName!
                            break
                        }
                    }
                }
                
                cell.configureWithNote(note, user: user, groupName: groupName)
                
                cell.backgroundColor = lightGreyColor
                
                cell.userInteractionEnabled = true
                
                // editButton tag to be indexPath.row so can be used in editPressed notification handling
                cell.editButton.tag = indexPath.row / 2
                cell.editButton.addTarget(self, action: "editPressed:", forControlEvents: .TouchUpInside)
                
                return cell
            }

        } else {
            // Configure UserDropDownCell
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
            
            if (indexPath.section == 0 && indexPath.row == 0) {
                // All Users / #nofilter cell
                
                cell.configure("all")
                
            } else if (indexPath.section == 1 && indexPath.row == 0) {
                // Logout cell
                
                cell.configure("logout")
                
            } else if (indexPath.section == 2 && indexPath.row == 0) {
                
                // Version cell
                cell.configure("version")
                
                cell.selectionStyle = .None
                cell.userInteractionEnabled = false
                
            } else {
                // Individual group / filter cell
                
                cell.configure(groups[indexPath.row - 1], arrow: true, bold: false)
                
            }
            
            return cell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (tableView.isEqual(dropDownMenu)) {
            // DropDownMenu
            // Filters, Logout, and Version = 3
            return 3
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
            return 2 * filteredNotes.count - 1
        } else if (tableView.isEqual(dropDownMenu)){
            // DropDownMenu
            if (section == 0) {
                // Number of groups + 1 for 'All' / #nofilter
                return groups.count + 1
            } else if (section == 1) {
                // Only 1 for 'Logout'
                return 1
            } else if (section == 2) {
                // Version number
                return 1
            } else {
                return 0
            }
        } else {
            // Why not?
            return 0
        }
    }
    
    
}