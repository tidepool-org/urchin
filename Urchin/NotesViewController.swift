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
    
    // All notes
    var notes: [Note] = []
    // Only filtered notes
    var filteredNotes: [Note] = []
    // All groups
    var groups: [User] = []
    // Count how many groups have metadata
    var groupsWMetadata: Int = 0
    
    // Current user
    let user: User!
    // API Connection
    let apiConnector: APIConnector
    // Number of ongoing message fetches
    var numberFetches: Int = 0
    
    // Current filter (nil if #nofilter)
    var filter: User!
    // Table that contains all notes
    var notesTable: UITableView!
    
    // Last date fetched to -- starts at current date
    var lastDateFetchTo: NSDate = NSDate()
    // True if currently loading more notes
    var loadingNotes: Bool = false
    
    // Overlay for when dropDownMenu is visible
    //      so the user does not play with
    //      notesTable while dropDown is visible
    var opaqueOverlay: UIView!
    
    // Massive button to add a new note
    let newNoteButton: UIButton
    
    // Drop Down Menu -- for selecting filter, #nofilter, or logging out
    var dropDownMenu: UITableView!
    // Animation helpers
    var isDropDownDisplayed: Bool = false
    var isDropDownAnimating: Bool = false
    var dropDownHeight: CGFloat = 0
    var overlayHeight: CGFloat
    
    // Possible VCs to push to (sometimes nil)
    var addNoteViewController: AddNoteViewController?
    var editNoteViewController: EditNoteViewController?
    // Keep track of when add or edit VCs are showing
    var addOrEditShowing = false
    
    var justLoggedIn = true
    var readyForTransition = false
    
    init(apiConnector: APIConnector) {
        // Initialize with API connection and user (from loginVC)
        self.apiConnector = apiConnector
        self.user = apiConnector.user!
        
        self.newNoteButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
                
        // Overlay begins with height 0.0 (animates to larger height)
        self.overlayHeight = CGFloat(0)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set status bar color to light for dark navigationBar
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color to light gray
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        
        // If device is running < iOS 8.0, make navigationBar NOT translucent
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0 {
            self.navigationController?.navigationBar.translucent = false
        }
        
        // navigationBar title begins with "All Notes" to match #nofilter to start
        configureTitleView("All Notes")
        
        // Initialize the notesTable to fill whole view, besides addNoteButton
        // Configure the notesTable
        self.notesTable = UITableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (CGFloat(64) + addNoteButtonHeight)))
        notesTable.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        notesTable.separatorStyle = UITableViewCellSeparatorStyle.None
        notesTable.registerClass(NoteCell.self, forCellReuseIdentifier: NSStringFromClass(NoteCell))
        notesTable.dataSource = self
        notesTable.delegate = self
        
        self.view.addSubview(notesTable)
        
        // Configure the newNoteButton at bottom of view
        let buttonWidth = self.view.frame.width
        let buttonX = CGFloat(0)
        let buttonY = self.view.frame.height - (addNoteButtonHeight + CGFloat(64))
        newNoteButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: addNoteButtonHeight)
        newNoteButton.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 171/255, alpha: 1)
        newNoteButton.addTarget(self, action: "newNote:", forControlEvents: .TouchUpInside)
        
        // Configure graphics and title for newNoteButton
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
        
        // Add graphics and title to newNoteButton
        newNoteButton.addSubview(addNoteImageView)
        newNoteButton.addSubview(addNoteLabel)
        
        self.view.addSubview(newNoteButton)
        
        // Fetch the groups for notes and (eventually) dropDownMenu
        // Successful completion of fetch will configure dropDownMenu and then load notes
        self.loadGroups()
        
        // Add rightBarButtonItem to down arrow for showing dropdown
        var rightDropDownMenuButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "down"), style: .Plain, target: self, action: "dropDownMenuPressed")
        self.navigationItem.setRightBarButtonItem(rightDropDownMenuButton, animated: true)
        
        // Configure notification center to observe addNote and saveNote
        //      called from addNoteVC and editNoteVC respectively
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "addNote:", name: "addNote", object: nil)
        notificationCenter.addObserver(self, selector: "saveNote:", name: "saveNote", object: nil)
        // Listen for when addNoteVC or editNoteVC has been closed without saving or posting
        notificationCenter.addObserver(self, selector: "doneAdding:", name: "doneAdding", object: nil)
        notificationCenter.addObserver(self, selector: "doneEditing:", name: "doneEditing", object: nil)
        // Listen for when group metadata has been fetched
        notificationCenter.addObserver(self, selector: "anotherGroup:", name: "anotherGroup", object: nil)
        // Listen for when to open an NewNoteVC
        notificationCenter.addObserver(self, selector: "newNote:", name: "newNote", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (justLoggedIn && readyForTransition) {
            justLoggedIn = false
            
            self.newNote(self)
        }
    }
    
    func anotherGroup(notification: NSNotification) {
        groupsWMetadata++
        if (groups.count != 0 && groupsWMetadata == groups.count + 1) {
            readyForTransition = true
            
            configureDropDownMenu()
            self.loadNotes()
        }
    }
    
    // Configure title of navigationBar to given string
    func configureTitleView(text: String) {
        // UILabel used
        let titleView = UILabel()
        titleView.text = text
        titleView.font = UIFont(name: "OpenSans", size: 17.5)!
        titleView.textColor = UIColor.whiteColor()
        let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        self.navigationItem.titleView = titleView
        
        // tapGesture triggers dropDownMenu to toggle
        let recognizer = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        titleView.userInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    // Fetch notes
    func loadNotes() {
        if (!loadingNotes) {
            // Shift back three months for fetching
            let dateShift = NSDateComponents()
            dateShift.month = -3
            let calendar = NSCalendar.currentCalendar()
            let startDate = calendar.dateByAddingComponents(dateShift, toDate: lastDateFetchTo, options: nil)!
            
            for group in groups {
                apiConnector.getNotesForUserInDateRange(self, userid: group.userid, start: startDate, end: lastDateFetchTo)
            }
            
            self.lastDateFetchTo = startDate
        }
    }
    
    // Called on newNoteButton press or when 
    func newNote(sender: AnyObject) {
        if (!addOrEditShowing) {
            addOrEditShowing = true
            
            // determine default option for note's group
            let groupForVC: User
            if (filter == nil) {
                // if #nofilter, let note's group be first group
                groupForVC = groups[0]
            } else {
                groupForVC = filter
            }
            
            // Initialize new AddNoteViewController
            addNoteViewController = AddNoteViewController(user: user, group: groupForVC, groups: groups)
            addNoteViewController!.note.createdtime = NSDate()
            addNoteViewController!.note.timestamp = NSDate()
            
            // present addNoteScene
            let addNoteScene = UINavigationController(rootViewController: addNoteViewController!)
            self.presentViewController(addNoteScene, animated: true, completion: nil)
        }
    }
    
    // Handle addNote notification
    // *** ONLY CALL FROM ADDNOTEVC ***
    func addNote(sender: AnyObject) {
        addOrEditShowing = false
        
        // pull the note from the addNoteViewController
        let newnote = addNoteViewController!.note
        
        apiConnector.doPostWithNote(self, note: newnote)
        
        // instantiate new AddNoteViewController
        // if #nofilter, let the group for AddNoteVC be first group
        let groupForVC: User
        if (filter == nil) {
            groupForVC = groups[0]
        } else {
            groupForVC = filter
        }
        addNoteViewController = AddNoteViewController(user: user, group: groupForVC, groups: groups)
    }
    
    func doneAdding(notification: NSNotification) {
        self.addOrEditShowing = false
    }
    
    func doneEditing(notification: NSNotification) {
        self.addOrEditShowing = false
    }
    
    // Filter notes based upon current filter
    func filterNotes() {
        notes.sort({$0.timestamp.timeIntervalSinceNow > $1.timestamp.timeIntervalSinceNow})
        
        filteredNotes = []
        if (filter != nil) {
            for note in notes {
                if (note.groupid == filter.userid) {
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
    
    // Handle saveNote notification
    // Only called from EditNoteVC
    // Note is modified in EditNoteVC, only need to reload notesTable
    func saveNote(sender: AnyObject) {
        addOrEditShowing = false
        
        apiConnector.editNote(self, editedNote: editNoteViewController!.editedNote, originalNote: editNoteViewController!.note)
    }
    
    // Fetch and load the groups/teams that user is involved in
    func loadGroups() {
        apiConnector.getAllViewableUsers(self)
    }
    
    // Handle editPressed notification
    //      from editButton in NoteCell
    func editPressed(sender: UIButton!) {
        if (!addOrEditShowing) {
            addOrEditShowing = true
            
            let thenote = filteredNotes[sender.tag]
            
            var groupFullName: String = ""
            for group in groups {
                if (group.userid == thenote.groupid) {
                    groupFullName = group.fullName!
                    break
                }
            }
            
            // Instantiate new EditNoteVC and present editNoteScene
            editNoteViewController = EditNoteViewController(note: thenote, groupFullName: groupFullName)
            let editNoteScene = UINavigationController(rootViewController: editNoteViewController!)
            self.presentViewController(editNoteScene, animated: true, completion: nil)
        }
    }
    
    func configureDropDownMenu() {
        // Configure and add the overlay, has same height as view
        overlayHeight = self.view.frame.height
        opaqueOverlay = UIView(frame: CGRectMake(0, -overlayHeight, self.view.frame.width, overlayHeight))
        opaqueOverlay.backgroundColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 0.75)
        // tapGesture closes the dropDownMenu (and overlay)
        let tapGesture = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        tapGesture.numberOfTapsRequired = 1
        opaqueOverlay.addGestureRecognizer(tapGesture)
        self.view.addSubview(opaqueOverlay)
        
        // Configure dropDownMenu, same width as view
        let numGroups = min(groups.count, 3)
        if (numGroups == groups.count) {
            self.dropDownHeight = CGFloat(numGroups+2)*userCellHeight + CGFloat(numGroups)*userCellThinSeparator + 2*userCellThickSeparator
        } else {
            self.dropDownHeight = (CGFloat(numGroups)+2.5)*userCellHeight + CGFloat(numGroups)*userCellThinSeparator + 2*userCellThickSeparator
        }
        let dropDownWidth = self.view.frame.width
        self.dropDownMenu = UITableView(frame: CGRect(x: CGFloat(0), y: -dropDownHeight, width: dropDownWidth, height: dropDownHeight))
        dropDownMenu.backgroundColor = UIColor(red: 0/255, green: 54/255, blue: 62/255, alpha: 1)
        dropDownMenu.rowHeight = userCellHeight
        dropDownMenu.separatorInset.left = userCellInset
        dropDownMenu.registerClass(UserDropDownCell.self, forCellReuseIdentifier: NSStringFromClass(UserDropDownCell))
        dropDownMenu.dataSource = self
        dropDownMenu.delegate = self
        dropDownMenu.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Drop down menu is only scrollable if the content fits
        dropDownMenu.scrollEnabled = groups.count > 3
        
        self.view.addSubview(dropDownMenu)
    }
    
    // Toggle dropDownMenu
    func dropDownMenuPressed() {
        if (isDropDownDisplayed) {
            // Configure navigationBar title to match filter
            if (filter == nil) {
                self.configureTitleView("All Notes")
            } else {
                self.configureTitleView(filter.fullName!)
            }
            // Hide the dropDownMenu
            self.hideDropDownMenu()
        } else {
            // Configure navigationBar to display "Blip Notes"
            self.configureTitleView("Blip notes")
            // Show the dropDownMenu
            self.showDropDownMenu()
        }
    }
    
    // Hide the dropDownMenu
    func hideDropDownMenu() {
        // Determine final destination of dropDownMenu and opaqueOverlay/obstruction
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = -dropDownHeight
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = -overlayHeight
        // Perform animation
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            self.isDropDownDisplayed = false
        }
    }
    
    // Show the dropDownMenu
    func showDropDownMenu() {
        // Determine final destination of dropDownMenu and opaqueOverlay/obstruction
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = 0.0
        var obstructionFrame: CGRect = self.opaqueOverlay.frame
        obstructionFrame.origin.y = 0.0
        // Perform animation
        self.animateDropDownToFrame(frame, obstructionFrame: obstructionFrame) {
            self.isDropDownDisplayed = true
        }
    }
    
    // dropDownMenu animations
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
    
    // cellForRowAtIndexPath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView.isEqual(notesTable)) {
            
            // Configure NoteCell
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NoteCell), forIndexPath: indexPath) as! NoteCell
            
            cell.configureWithNote(filteredNotes[indexPath.row], user: user)
            
            // Background color based upon odd or even row
            if (indexPath.row % 2 == 0) {
                // even cell
                cell.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
            } else {
                // odd cell
                cell.backgroundColor = UIColor(red: 152/255, green: 152/255, blue: 151/255, alpha: 0.23)
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
    
    // heightForRowAtIndexPath
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView.isEqual(notesTable)) {
            // NotesTable
            
            // Create labels that 'determine' height of cell
            
            // Configure the date label size first using extended dateFormatter
            // used for sizing usernameLabel
            let timedateLabel = UILabel()
            let dateFormatter = NSDateFormatter()
            timedateLabel.attributedText = dateFormatter.attributedStringFromDate(filteredNotes[indexPath.row].timestamp)
            timedateLabel.sizeToFit()
            
            // Configure the username label, with the full name
            let usernameLabel = UILabel()
            let usernameWidth = self.view.frame.width - (2 * noteCellInset + timedateLabel.frame.width + 2 * labelSpacing)
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
            // if the user who created the note is the same as the current user, allow space for edit button
            if (filteredNotes[indexPath.row].user!.userid == user.userid) {
                cellHeight = noteCellInset + usernameLabel.frame.height + 2 * labelSpacing + messageLabel.frame.height + 2 * labelSpacing + 12.5 + noteCellInset
            } else {
                cellHeight = noteCellInset + usernameLabel.frame.height + 2 * labelSpacing + messageLabel.frame.height + noteCellInset
            }
            
            return cellHeight
        } else {
            // DropDownMenu
            
            if (indexPath.section == 0 && indexPath.row == 0) {
                // All / #nofilter
                
                let nameLabel = UILabel()
                nameLabel.text = "All"
                nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)
                nameLabel.sizeToFit()
                
                return userCellThickSeparator + userCellInset + nameLabel.frame.height + userCellInset + userCellThinSeparator
            } else if (indexPath.section == 1 && indexPath.row == 0) {
                // Logout
                
                let nameLabel = UILabel()
                nameLabel.text = "Logout"
                nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)
                nameLabel.sizeToFit()
                
                return userCellInset + nameLabel.frame.height + userCellInset + (userCellThickSeparator - userCellThinSeparator)
            } else {
                // Some group / team / filter
                
                let nameLabel = UILabel()
                nameLabel.frame.size = CGSize(width: self.view.frame.width - 2 * labelInset, height: 20.0)
                nameLabel.text = groups[indexPath.row - 1].fullName
                if (filter === groups[indexPath.row - 1]) {
                    nameLabel.font = UIFont(name: "OpenSans-Bold", size: 17.5)!
                } else {
                    nameLabel.font = UIFont(name: "OpenSans", size: 17.5)!
                }
                nameLabel.sizeToFit()
                                
                return userCellInset + nameLabel.frame.height + userCellInset + userCellThinSeparator
            }
        }
    }
    
    // didSelectRowAtIndexPath
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Immediately deselect the row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (tableView.isEqual(dropDownMenu)) {
            // dropDownMenu
            
            if (indexPath.section == 0) {
                // A group or all seleceted
                if (indexPath.row == 0) {
                    // 'All' / #nofilter selected
                    self.configureTitleView("All Notes")
                    self.filter = nil
                } else {
                    // Individual group / filter selected
                    let cell = dropDownMenu.cellForRowAtIndexPath(indexPath) as! UserDropDownCell
                    self.filter = cell.group
                    self.configureTitleView(filter.fullName!)
                }
                // filter the notes based upon new filter
                filterNotes()
                // Scroll notes to top
                self.notesTable.setContentOffset(CGPointMake(0, 0 - self.notesTable.contentInset.top), animated: true)
                // toggle the dropDownMenu (hides the dropDownMenu)
                self.dropDownMenuPressed()
            } else {
                // Logout selected
                // Unwind VC
                apiConnector.logout(self)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.isEqual(notesTable)) {
            let height = scrollView.frame.height
            let contentYOffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYOffset
            
            if (distanceFromBottom < height && !loadingNotes) {
                loadNotes()
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
    
    // Lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}