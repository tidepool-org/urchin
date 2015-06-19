//
//  NotesViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var notes: [Note] = []
    var groups: [User] = []
    
    let user: User
    var notesTable: UITableView!
    
    let newNoteButton: UIButton
    
    let refreshControl: UIRefreshControl!
    
    var dropDownMenu: UITableView!
    var isDropDownDisplayed: Bool = false
    var isDropDownAnimating: Bool = false
    
    init(user: User) {
        self.user = user
        
        self.newNoteButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        self.refreshControl = UIRefreshControl()
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        self.title = user.fullName
        
        self.notesTable = UITableView(frame: self.view.frame)
        
        notesTable.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        notesTable.rowHeight = noteCellHeight
        notesTable.separatorInset.left = noteCellInset
        notesTable.registerClass(NoteCell.self, forCellReuseIdentifier: NSStringFromClass(NoteCell))
        notesTable.dataSource = self
        notesTable.delegate = self
        
        self.loadNotes()
        
        self.view.addSubview(notesTable)
        
        let dropDownHeight = CGFloat(250)
        let dropDownWidth = self.view.frame.width
        self.dropDownMenu = UITableView(frame: CGRect(x: CGFloat(0), y: CGFloat(66) - dropDownHeight, width: dropDownWidth, height: dropDownHeight))
        
        dropDownMenu.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        dropDownMenu.rowHeight = userCellHeight
        dropDownMenu.separatorInset.left = userCellInset
        dropDownMenu.registerClass(UserDropDownCell.self, forCellReuseIdentifier: NSStringFromClass(UserDropDownCell))
        dropDownMenu.dataSource = self
        dropDownMenu.delegate = self
        
        self.loadGroups()
        
        self.view.addSubview(dropDownMenu)
        
        let image = UIImage(named: "newnote") as UIImage!
        newNoteButton.setBackgroundImage(image, forState: .Normal)
        let buttonWidth = CGFloat(128)
        let buttonHeight = CGFloat(128)
        let buttonX = self.view.frame.width / 2 - CGFloat(buttonWidth / 2)
        let buttonY = self.view.frame.height - CGFloat(buttonHeight + 24)
        newNoteButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        newNoteButton.addTarget(self, action: "newNote:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(newNoteButton)
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshNotesTable:", forControlEvents: UIControlEvents.ValueChanged)
        self.notesTable.addSubview(refreshControl)
        
        var rightDropDownMenuButton: UIBarButtonItem = UIBarButtonItem(title: "Drop Down", style: .Plain, target: self, action: "dropDownMenuPressed:")
        self.navigationItem.setRightBarButtonItem(rightDropDownMenuButton, animated: true)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadNotes() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let howardbirthday = dateFormatter.dateFromString("1966-05-21")
        let howarddiagnosis = dateFormatter.dateFromString("2011-01-01")
        
        let howardpatient = Patient(birthday: howardbirthday!, diagnosisDate: howarddiagnosis!, aboutMe: "Fakabetic.")
        let howard = User(firstName: "Howard", lastName: "Look", patient: howardpatient)
        let newnote = Note(id: "someid", userid: "howardlook", groupid: "katielook", timestamp: NSDate(), createdtime: NSDate(), messagetext: "This is a new note. I am making the note longer to see if wrapping occurs or not.", user: howard)
        notes.append(newnote)
        
        let anothernote = Note(id: "someid", userid: "howardlook", groupid: "katielook", timestamp: NSDate(), createdtime: NSDate(), messagetext: "This is a another note. I am making the note longer to see if how this looks with multiple notes of different heights. If it goes well, I will be thrilled.", user: howard)
        notes.append(anothernote)
        
        let more = Note(id: "someid", userid: "howardlook", groupid: "katielook", timestamp: NSDate(), createdtime: NSDate(), messagetext: "The 2005 United States Grand Prix was the ninth race and only American race of the 2005 Formula One season. Held at the Indianapolis Motor Speedway, it was won by Ferrari's Michael Schumacher (pictured).", user: howard)
        notes.append(more)
        
        let another = Note(id: "someid", userid: "howardlook", groupid: "katielook", timestamp: NSDate(), createdtime: NSDate(), messagetext: "In basketball, the Golden State Warriors defeat the Cleveland Cavaliers to win the NBA Finals.", user: howard)
        notes.append(another)
        
        let lastone = Note(id: "someid", userid: "howardlook", groupid: "katielook", timestamp: NSDate(), createdtime: NSDate(), messagetext: "On this day, the royal wedding between Victoria, Crown Princess of Sweden, and Daniel Westling (both pictured) took place in Stockholm Cathedral.", user: howard)
        notes.append(lastone)
        
        notesTable.reloadData()
    }
    
    func newNote(sender: UIButton!) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let howardbirthday = dateFormatter.dateFromString("1966-05-21")
        let howarddiagnosis = dateFormatter.dateFromString("2011-01-01")
        
        let howardpatient = Patient(birthday: howardbirthday!, diagnosisDate: howarddiagnosis!, aboutMe: "Fakabetic.")
        let howard = User(firstName: "Howard", lastName: "Look", patient: howardpatient)
        let newnote = Note(id: "someid", userid: "howardlook", groupid: "katielook", timestamp: NSDate(), createdtime: NSDate(), messagetext: "Adding a brand spanking new note!", user: howard)
        notes.insert(newnote, atIndex: 0)
        
        notesTable.reloadData()
    }
    
    func loadGroups() {
        let sarapatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Designer guru.")
        let sara = User(firstName: "Sara", lastName: "Krugman", patient: sarapatient)
        let katiepatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Annoying little sister. Everyone's inspiration.")
        let katie = User(firstName: "Katie", lastName: "Look", patient: katiepatient)
        let shellypatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Shelly is a rockstar.")
        let shelly = User(firstName: "Shelly", lastName: "Surabouti", patient: shellypatient)
        
        groups.append(sara)
        groups.append(katie)
        groups.append(shelly)
        
        dropDownMenu.reloadData()
    }
    
    func refreshNotesTable(sender: AnyObject) {
        notesTable.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func dropDownMenuPressed(sender: AnyObject) {
        if (isDropDownDisplayed) {
            self.hideDropDownMenu()
        } else {
            self.showDropDownMenu()
        }
    }
    
    func hideDropDownMenu() {var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = CGFloat(66) - CGFloat(250)
        self.animateDropDownToFrame(frame) {
            self.isDropDownDisplayed = false
        }
    }
    
    func showDropDownMenu() {var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = CGFloat(66)
        self.animateDropDownToFrame(frame) {
            self.isDropDownDisplayed = true
        }
    }
    
    func animateDropDownToFrame(frame: CGRect, completion:() -> Void) {
        if (!isDropDownAnimating) {
            isDropDownAnimating = true
            UIView.animateKeyframesWithDuration(0.5, delay: 0.0, options: nil, animations: { () -> Void in
                self.dropDownMenu.frame = frame
                }, completion: { (completed: Bool) -> Void in
                    self.isDropDownAnimating = false
                    if (completed) {
                        completion()
                    }
            })
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView.isEqual(notesTable)) {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NoteCell), forIndexPath: indexPath) as! NoteCell
            
            cell.configureWithNote(notes[indexPath.row])
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
            
            cell.configureWithGroup(groups[indexPath.row])
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.isEqual(notesTable)) {
            return notes.count
        } else {
            return groups.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView.isEqual(notesTable)) {
            let cell = NoteCell(style: .Default, reuseIdentifier: nil)
            cell.configureWithNote(notes[indexPath.row])
            return cell.cellHeight
        } else {
            let cell = UserDropDownCell(style: .Default, reuseIdentifier: nil)
            cell.configureWithGroup(groups[indexPath.row])
            return cell.cellHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView.isEqual(notesTable)) {
            let cell = NoteCell(style: .Default, reuseIdentifier: nil)
            cell.configureWithNote(notes[indexPath.row])
            let expectedHeight = noteCellInset + cell.usernameLabel.frame.height + cell.timedateLabel.frame.height + 2*labelSpacing + cell.messageLabel.frame.height
            println(cell.cellHeight)
            println(expectedHeight)
        } else {
            let cell = UserDropDownCell(style: .Default, reuseIdentifier: nil)
            cell.configureWithGroup(groups[indexPath.row])
            println(cell.nameLabel.text)
        }
    }
    
}