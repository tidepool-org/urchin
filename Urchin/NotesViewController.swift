//
//  NotesViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

let addNoteButtonHeight = CGFloat(105)

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var notes: [Note] = []
    var groups: [User] = []
    
    var user: User!
    var notesTable: UITableView!
    
    var opaqueOverlay: UIView!
    
    let newNoteButton: UIButton
    
    let refreshControl: UIRefreshControl!
    
    var dropDownMenu: UITableView!
    var isDropDownDisplayed: Bool = false
    var isDropDownAnimating: Bool = false
    var dropDownHeight: CGFloat
    var overlayHeight: CGFloat
    
    var addNoteViewController: AddNoteViewController
    
    init(user: User) {
        self.user = user
        
        self.newNoteButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        self.refreshControl = UIRefreshControl()
        
        self.dropDownHeight = (3+2)*userCellHeight + (3-1)*userCellThinSeparator + 2*userCellThickSeparator
        
        self.overlayHeight = CGFloat(0)
        
         addNoteViewController = AddNoteViewController(currentUser: user)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        self.title = user.fullName
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 25)!]
        
        self.notesTable = UITableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (CGFloat(64) + addNoteButtonHeight)))
        
        notesTable.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        notesTable.rowHeight = noteCellHeight
        notesTable.separatorInset.left = noteCellInset
        notesTable.registerClass(NoteCell.self, forCellReuseIdentifier: NSStringFromClass(NoteCell))
        notesTable.dataSource = self
        notesTable.delegate = self
        
        self.loadNotes()
        
        self.view.addSubview(notesTable)
        
        let buttonWidth = self.view.frame.width
        let buttonX = CGFloat(0)
        let buttonY = self.view.frame.height - (addNoteButtonHeight + CGFloat(64))
        newNoteButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: addNoteButtonHeight)
        newNoteButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        newNoteButton.addTarget(self, action: "newNote:", forControlEvents: .TouchUpInside)
        
        let addNoteImage = UIImage(named: "note") as UIImage!
        let addNoteImageView = UIImageView(image: addNoteImage)
        addNoteImageView.frame = CGRectMake(0, 0, addNoteImage.size.width / 2, addNoteImage.size.height / 2)
        
        let addNoteLabel = UILabel(frame: CGRectZero)
        addNoteLabel.text = "Add note"
        addNoteLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
        addNoteLabel.textColor = UIColor.whiteColor()
        addNoteLabel.sizeToFit()
        
        let addNoteX = newNoteButton.frame.width / 2
        let addNoteY = newNoteButton.frame.height / 2
        let halfHeight = (addNoteImageView.frame.height + labelSpacing + addNoteLabel.frame.height) / 2
        addNoteImageView.frame.origin = CGPoint(x: addNoteX  - addNoteImageView.frame.width / 2, y: addNoteY - halfHeight)
        addNoteLabel.frame.origin = CGPoint(x: addNoteX - addNoteLabel.frame.width / 2, y: addNoteY + halfHeight - addNoteLabel.frame.height)
        
        newNoteButton.addSubview(addNoteImageView)
        newNoteButton.addSubview(addNoteLabel)
        
        self.view.addSubview(newNoteButton)
        
        overlayHeight = self.view.frame.height
        opaqueOverlay = UIView(frame: CGRectMake(0, -overlayHeight, self.view.frame.width, overlayHeight))
        opaqueOverlay.backgroundColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 0.75)
        self.view.addSubview(opaqueOverlay)
        
        let dropDownWidth = self.view.frame.width
        self.dropDownMenu = UITableView(frame: CGRect(x: CGFloat(0), y: -dropDownHeight, width: dropDownWidth, height: dropDownHeight))
        
        dropDownMenu.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        dropDownMenu.rowHeight = userCellHeight
        dropDownMenu.separatorInset.left = userCellInset
        dropDownMenu.registerClass(UserDropDownCell.self, forCellReuseIdentifier: NSStringFromClass(UserDropDownCell))
        dropDownMenu.dataSource = self
        dropDownMenu.delegate = self
        dropDownMenu.separatorStyle = UITableViewCellSeparatorStyle.None
        if (dropDownMenu.contentSize.height <= dropDownMenu.frame.size.height) {
            dropDownMenu.scrollEnabled = false;
        }
        else {
            dropDownMenu.scrollEnabled = true;
        }
        
        self.loadGroups()
        
        self.view.addSubview(dropDownMenu)
        
        self.refreshControl.addTarget(self, action: "refreshNotesTable:", forControlEvents: UIControlEvents.ValueChanged)
        self.notesTable.addSubview(refreshControl)
        
        var rightDropDownMenuButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "down"), style: .Plain, target: self, action: "dropDownMenuPressed")
        self.navigationItem.setRightBarButtonItem(rightDropDownMenuButton, animated: true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "addNote:", name: "addNote", object: nil)
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
        
        addNoteViewController.user = user
        addNoteViewController.note.createdtime = NSDate()
        addNoteViewController.note.timestamp = NSDate()
        let addNoteScene = UINavigationController(rootViewController: addNoteViewController)
        self.presentViewController(addNoteScene, animated: true, completion: nil)
    }
    
    func addNote(sender: AnyObject) {
        let newnote = addNoteViewController.note
        notes.insert(newnote, atIndex: 0)
        notesTable.reloadData()
        addNoteViewController = AddNoteViewController(currentUser: user)
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
    
    func dropDownMenuPressed() {
        if (isDropDownDisplayed) {
            self.title = self.user.fullName
            self.hideDropDownMenu()
        } else {
            self.title = "Notes"
            self.showDropDownMenu()
        }
    }
    
    func hideDropDownMenu() {
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = -dropDownHeight
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = -overlayHeight
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            self.isDropDownDisplayed = false
        }
    }
    
    func showDropDownMenu() {
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = 0.0
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = 0.0
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            self.isDropDownDisplayed = true
        }
    }
    
    func animateDropDownToFrame(frame: CGRect, obstructionFrame: CGRect, completion:() -> Void) {
        if (!isDropDownAnimating) {
            isDropDownAnimating = true
            UIView.animateKeyframesWithDuration(0.5, delay: 0.0, options: nil, animations: { () -> Void in
                self.dropDownMenu.frame = frame
                self.opaqueOverlay.frame = obstructionFrame
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
            
            if (indexPath.row % 2 == 0) {
                // even cell
                cell.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
            } else {
                // odd cell
                cell.backgroundColor = UIColor(red: 152/255, green: 152/255, blue: 151/255, alpha: 0.23)
            }
            
            return cell
        } else {
            if (indexPath.section == 0 && indexPath.row == 0) {
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
                
                cell.configureAllUsers()
                
                return cell
            } else if (indexPath.section == 1 && indexPath.row == 0) {
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
                
                cell.configureLogout()
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
                
                cell.configureWithGroup(groups[indexPath.row - 1])
                
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.isEqual(notesTable)) {
            return notes.count
        } else if (tableView.isEqual(dropDownMenu)){
            if (section == 0) {
                return groups.count + 1
            } else {
                return 1
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView.isEqual(notesTable)) {
            let cell = NoteCell(style: .Default, reuseIdentifier: nil)
            cell.configureWithNote(notes[indexPath.row])
            return cell.cellHeight
        } else {
            if (indexPath.section == 0 && indexPath.row == 0) {
                let cell = UserDropDownCell(style: .Default, reuseIdentifier: nil)
                cell.configureAllUsers()
                return cell.cellHeight
            } else if (indexPath.section == 1 && indexPath.row == 0) {
                let cell = UserDropDownCell(style: .Default, reuseIdentifier: nil)
                cell.configureLogout()
                return cell.cellHeight
            } else {
                let cell = UserDropDownCell(style: .Default, reuseIdentifier: nil)
                cell.configureWithGroup(groups[indexPath.row - 1])
                return cell.cellHeight
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (tableView.isEqual(notesTable)) {
            let cell = NoteCell(style: .Default, reuseIdentifier: nil)
            cell.configureWithNote(notes[indexPath.row])
        } else {
            if (indexPath.section == 0) {
                // A group or all seleceted
                if (indexPath.row != 0) {
                    let cell = dropDownMenu.cellForRowAtIndexPath(indexPath) as! UserDropDownCell
                    self.user = cell.user
                }
                self.dropDownMenuPressed()
            } else {
                // Logout selected
                // Unwind VC
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (tableView.isEqual(dropDownMenu)) {
            return 2
        } else {
            return 1
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}