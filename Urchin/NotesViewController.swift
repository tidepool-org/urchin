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
    var filteredNotes: [Note] = []
    var groups: [Group] = []
    
    let user: User!
    var filter: Group!
    var notesTable: UITableView!
    
    var opaqueOverlay: UIView!
    
    let newNoteButton: UIButton
    
    let refreshControl: UIRefreshControl!
    
    var dropDownMenu: UITableView!
    var isDropDownDisplayed: Bool = false
    var isDropDownAnimating: Bool = false
    var dropDownHeight: CGFloat
    var overlayHeight: CGFloat
    
    var addNoteViewController: AddNoteViewController?
    var editNoteViewController: EditNoteViewController?
    
    init(user: User) {
        self.user = user
        
        self.newNoteButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        self.refreshControl = UIRefreshControl()
        
        self.dropDownHeight = (3+2)*userCellHeight + (3)*userCellThinSeparator + 2*userCellThickSeparator
        
        self.overlayHeight = CGFloat(0)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        configureTitleView("All Notes")
        
        self.notesTable = UITableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (CGFloat(64) + addNoteButtonHeight)))
        
        notesTable.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        notesTable.separatorStyle = UITableViewCellSeparatorStyle.None
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
        let tapGesture = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        tapGesture.numberOfTapsRequired = 1
        opaqueOverlay.addGestureRecognizer(tapGesture)
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
        notificationCenter.addObserver(self, selector: "saveNote:", name: "saveNote", object: nil)
    }
    
    func configureTitleView(text: String) {
        let titleView = UILabel()
        titleView.text = text
        titleView.font = UIFont(name: "OpenSans", size: 17.5)!
        titleView.textColor = UIColor.whiteColor()
        let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        titleView.userInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
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
        
        let more = Note(id: "someid", userid: "howardlook", groupid: "sarakrugman", timestamp: NSDate(), createdtime: NSDate(), messagetext: "The 2005 United States Grand Prix was the ninth race and only American race of the 2005 Formula One season. Held at the Indianapolis Motor Speedway, it was won by Ferrari's Michael Schumacher (pictured).", user: howard)
        notes.append(more)
        
        let another = Note(id: "someid", userid: "howardlook", groupid: "katielook", timestamp: NSDate(), createdtime: NSDate(), messagetext: "In basketball, the Golden State Warriors defeat the Cleveland Cavaliers to win the NBA Finals.", user: howard)
        notes.append(another)
        
        let lastone = Note(id: "someid", userid: "howardlook", groupid: "shellysurabouti", timestamp: NSDate(), createdtime: NSDate(), messagetext: "On this day, the royal wedding between Victoria, Crown Princess of Sweden, and Daniel Westling (both pictured) took place in Stockholm Cathedral.", user: howard)
        notes.append(lastone)
        
        filteredNotes = []
        if (filter != nil) {
            for note in notes {
                if (note.groupid == filter.groupid) {
                    filteredNotes.append(note)
                }
            }
        } else {
            for note in notes {
                filteredNotes.append(note)
            }
        }
        notesTable.reloadData()
    }
    
    func newNote(sender: UIButton!) {
        let groupForVC: Group
        if (filter == nil) {
            groupForVC = groups[0]
        } else {
            groupForVC = filter
        }
        
        addNoteViewController = AddNoteViewController(user: user, group: groupForVC, groups: groups)
        addNoteViewController!.note.createdtime = NSDate()
        addNoteViewController!.note.timestamp = NSDate()
        
        let addNoteScene = UINavigationController(rootViewController: addNoteViewController!)
        self.presentViewController(addNoteScene, animated: true, completion: nil)
    }
    
    func addNote(sender: AnyObject) {
        let newnote = addNoteViewController!.note
        notes.insert(newnote, atIndex: 0)
        filteredNotes = []
        if (filter != nil) {
            for note in notes {
                if (note.groupid == filter.groupid) {
                    filteredNotes.append(note)
                }
            }
        } else {
            for note in notes {
                filteredNotes.append(note)
            }
        }
        notesTable.reloadData()
        let groupForVC: Group
        if (filter == nil) {
            groupForVC = groups[0]
        } else {
            groupForVC = filter
        }
        addNoteViewController = AddNoteViewController(user: user, group: groupForVC, groups: groups)
    }
    
    func saveNote(sender: AnyObject) {
        notesTable.reloadData()
    }
    
    func loadGroups() {
        let sara = Group(name: "Sara Krugman", groupid: "sarakrugman")
        let katie = Group(name: "Katie Look", groupid: "katielook")
        let shelly = Group(name: "Shelly Surabouti", groupid: "shellysurabouti")
        
        groups.append(sara)
        groups.append(katie)
        groups.append(shelly)
        
        dropDownMenu.reloadData()
    }
    
    func refreshNotesTable(sender: AnyObject) {
        notesTable.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func editPressed(sender: UIButton!) {
        
        editNoteViewController = EditNoteViewController(note: filteredNotes[sender.tag])
        let editNoteScene = UINavigationController(rootViewController: editNoteViewController!)
        self.presentViewController(editNoteScene, animated: true, completion: nil)
    }
    
    func dropDownMenuPressed() {
        if (isDropDownDisplayed) {
            if (filter == nil) {
                self.configureTitleView("All Notes")
            } else {
                self.configureTitleView(filter.name)
            }
            self.hideDropDownMenu()
        } else {
            self.configureTitleView("Blip notes")
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
            
            cell.configureWithNote(filteredNotes[indexPath.row], user: user)
            
            if (indexPath.row % 2 == 0) {
                // even cell
                cell.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
            } else {
                // odd cell
                cell.backgroundColor = UIColor(red: 152/255, green: 152/255, blue: 151/255, alpha: 0.23)
            }
            
            cell.userInteractionEnabled = true
            
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: "editPressed:", forControlEvents: .TouchUpInside)
            
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
                
                cell.configureWithGroup(groups[indexPath.row - 1], arrow: true, bold: false)
                
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.isEqual(notesTable)) {
            return filteredNotes.count
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
            
            let usernameLabel = UILabel(frame: CGRectZero)
            let usernameWidth = (self.view.frame.width - 2*noteCellInset) / 2
            usernameLabel.frame.size = CGSize(width: usernameWidth, height: CGFloat.max)
            usernameLabel.text = filteredNotes[indexPath.row].user!.fullName
            usernameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
            usernameLabel.textColor = UIColor.blackColor()
            usernameLabel.adjustsFontSizeToFitWidth = false
            usernameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            usernameLabel.numberOfLines = 0
            usernameLabel.sizeToFit()
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 2*noteCellInset, height: CGFloat.max))
            let hashtagBolder = HashtagBolder()
            let attributedText = hashtagBolder.boldHashtags(filteredNotes[indexPath.row].messagetext)
            messageLabel.attributedText = attributedText
            messageLabel.adjustsFontSizeToFitWidth = false
            messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            messageLabel.numberOfLines = 0
            messageLabel.sizeToFit()
            
            let cellHeight: CGFloat
            if (filteredNotes[indexPath.row].user === user) {
                cellHeight = noteCellInset + usernameLabel.frame.height + 2 * labelSpacing + messageLabel.frame.height + 2 * labelSpacing + 12.5 + noteCellInset
            } else {
                cellHeight = noteCellInset + usernameLabel.frame.height + 2 * labelSpacing + messageLabel.frame.height + noteCellInset
            }
            
            return cellHeight
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
                cell.configureWithGroup(groups[indexPath.row - 1], arrow: true, bold: false)
                return cell.cellHeight
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (tableView.isEqual(dropDownMenu)) {
            if (indexPath.section == 0) {
                // A group or all seleceted
                if (indexPath.row == 0) {
                    self.configureTitleView("All Notes")
                    self.filter = nil
                } else {
                    let cell = dropDownMenu.cellForRowAtIndexPath(indexPath) as! UserDropDownCell
                    self.filter = cell.group
                    self.configureTitleView(filter.name)
                }
                filteredNotes = []
                if (filter != nil) {
                    for note in notes {
                        if (note.groupid == filter.groupid) {
                            filteredNotes.append(note)
                        }
                    }
                } else {
                    for note in notes {
                        filteredNotes.append(note)
                    }
                }
                self.notesTable.reloadData()
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