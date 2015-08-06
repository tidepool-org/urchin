//
//  NotesViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class NotesViewController: UIViewController {
    
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
    let newNoteButton: UIButton = UIButton()
    
    // Drop Down Menu -- for selecting filter, #nofilter, or logging out
    var dropDownMenu: UITableView!
    // Animation helpers
    var isDropDownDisplayed: Bool = false
    var isDropDownAnimating: Bool = false
    var dropDownHeight: CGFloat = 0
    var overlayHeight: CGFloat = 0
    
    // Possible VCs to push to (sometimes nil)
    var addNoteViewController: AddNoteViewController?
    var editNoteViewController: EditNoteViewController?
    // Keep track of when add or edit VCs are showing
    var addOrEditShowing = false
    
    var groupsReadyForTransition = false
    var viewReadyForTransition = false
    var justLoggedIn = true
    
    init(apiConnector: APIConnector) {
        // Initialize with API connection and user (from loginVC)
        self.apiConnector = apiConnector
        self.user = apiConnector.user!
        
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
        self.view.backgroundColor = lightGreyColor
        
        // If device is running < iOS 8.0, make navigationBar NOT translucent
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0 {
            self.navigationController?.navigationBar.translucent = false
        }
        
        // navigationBar title begins with "All Notes" to match #nofilter to start
        configureTitleView(allNotesTitle)
        
        // Initialize the notesTable to fill whole view, besides addNoteButton
        // Configure the notesTable
        let navBarH = self.navigationController!.navigationBar.frame.size.height
        let statusBarH = UIApplication.sharedApplication().statusBarFrame.size.height
        let notesTableH = self.view.frame.height - (navBarH + statusBarH + addNoteButtonHeight)
        self.notesTable = UITableView(frame: CGRectMake(0, 0, self.view.frame.width, notesTableH))
        notesTable.backgroundColor = lightGreyColor
        notesTable.separatorStyle = UITableViewCellSeparatorStyle.None
        notesTable.registerClass(NoteCell.self, forCellReuseIdentifier: NSStringFromClass(NoteCell))
        notesTable.dataSource = self
        notesTable.delegate = self
        
        self.view.addSubview(notesTable)
        
        // Configure the newNoteButton at bottom of view
        let buttonWidth = self.view.frame.width
        let buttonY = self.view.frame.height - (addNoteButtonHeight + CGFloat(64))
        newNoteButton.frame = CGRect(x: 0, y: buttonY, width: buttonWidth, height: addNoteButtonHeight)
        newNoteButton.backgroundColor = tealColor
        newNoteButton.addTarget(self, action: "newNote:", forControlEvents: .TouchUpInside)
        
        // Configure graphics and title for newNoteButton
        let addNoteImageView = UIImageView(image: noteImage)
        addNoteImageView.frame = CGRectMake(0, 0, noteImage.size.width / 2, noteImage.size.height / 2)
        
        let addNoteLabel = UILabel(frame: CGRectZero)
        addNoteLabel.text = addNoteText
        addNoteLabel.font = mediumBoldFont
        addNoteLabel.textColor = whiteColor
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
        var rightDropDownMenuButton: UIBarButtonItem = UIBarButtonItem(image: downArrow, style: .Plain, target: self, action: "dropDownMenuPressed")
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
        
        viewReadyForTransition = true
        initialAddNote()
    }
    
    func anotherGroup(notification: NSNotification) {
        groupsWMetadata++
        if (groups.count != 0 && groupsWMetadata == groups.count + 1) {
            groupsReadyForTransition = true
            initialAddNote()
            
            configureDropDownMenu()
            self.loadNotes()
        }
    }
    
    func initialAddNote() {
        if (justLoggedIn && viewReadyForTransition && groupsReadyForTransition) {
            justLoggedIn = false
            
            self.newNote(self)
        }
    }
    
    // Configure title of navigationBar to given string
    func configureTitleView(text: String) {
        // UILabel used
        let titleView = UILabel()
        titleView.text = text
        titleView.font = mediumRegularFont
        titleView.textColor = navBarTitleColor
        titleView.sizeToFit()
        titleView.frame.size.height = self.navigationController!.navigationBar.frame.size.height
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
            dateShift.month = fetchPeriodInMonths
            let calendar = NSCalendar.currentCalendar()
            let startDate = calendar.dateByAddingComponents(dateShift, toDate: lastDateFetchTo, options: nil)!
            
            for group in groups {
                apiConnector.getNotesForUserInDateRange(self, userid: group.userid, start: startDate, end: lastDateFetchTo)
            }
            
            self.lastDateFetchTo = startDate
        }
    }
    
    // Called on newNoteButton press
    func newNote(sender: AnyObject) {
        if (!addOrEditShowing) {
            addOrEditShowing = true
            
            if (sender is UIButton) {
                self.apiConnector.trackMetric("Clicked Add Note")
            }
            
            // determine default option for note's group
            let groupForVC: User
            if (filter == nil) {
                // if #nofilter, let note's group be first group
                groupForVC = groups[0]
            } else {
                groupForVC = filter
            }
            
            // Initialize new AddNoteViewController
            addNoteViewController = AddNoteViewController(apiConnector: apiConnector, user: user, group: groupForVC, groups: groups)
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
        addNoteViewController = AddNoteViewController(apiConnector: apiConnector, user: user, group: groupForVC, groups: groups)
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
            
            self.apiConnector.trackMetric("Clicked Edit Note")
            
            let thenote = filteredNotes[sender.tag]
            
            var groupFullName: String = ""
            for group in groups {
                if (group.userid == thenote.groupid) {
                    groupFullName = group.fullName!
                    break
                }
            }
            
            // Instantiate new EditNoteVC and present editNoteScene
            editNoteViewController = EditNoteViewController(apiConnector: apiConnector, note: thenote, groupFullName: groupFullName)
            let editNoteScene = UINavigationController(rootViewController: editNoteViewController!)
            self.presentViewController(editNoteScene, animated: true, completion: nil)
        }
    }
    
    func configureDropDownMenu() {
        // Configure and add the overlay, has same height as view
        overlayHeight = self.view.frame.height
        opaqueOverlay = UIView(frame: CGRectMake(0, -overlayHeight, self.view.frame.width, overlayHeight))
        opaqueOverlay.backgroundColor = blackishLowAlpha
        // tapGesture closes the dropDownMenu (and overlay)
        let tapGesture = UITapGestureRecognizer(target: self, action: "dropDownMenuPressed")
        tapGesture.numberOfTapsRequired = 1
        opaqueOverlay.addGestureRecognizer(tapGesture)
        self.view.addSubview(opaqueOverlay)
        
        // Configure dropDownMenu, same width as view
        let numGroups = min(groups.count, maxGroupsShownInDropdown)
        if (numGroups == groups.count) {
            self.dropDownHeight = CGFloat(numGroups+3)*userCellHeight + CGFloat(numGroups)*userCellThinSeparator + 2*userCellThickSeparator
        } else {
            self.dropDownHeight = (CGFloat(numGroups)+3.5)*userCellHeight + CGFloat(numGroups)*userCellThinSeparator + 2*userCellThickSeparator
        }
        let dropDownWidth = self.view.frame.width
        self.dropDownMenu = UITableView(frame: CGRect(x: 0, y: -dropDownHeight, width: dropDownWidth, height: dropDownHeight))
        dropDownMenu.backgroundColor = darkGreenColor
        dropDownMenu.rowHeight = userCellHeight
        dropDownMenu.separatorInset.left = userCellInset
        dropDownMenu.registerClass(UserDropDownCell.self, forCellReuseIdentifier: NSStringFromClass(UserDropDownCell))
        dropDownMenu.dataSource = self
        dropDownMenu.delegate = self
        dropDownMenu.separatorStyle = UITableViewCellSeparatorStyle.None
        dropDownMenu.scrollsToTop = false
        
        // Drop down menu is only scrollable if the content fits
        dropDownMenu.scrollEnabled = groups.count > maxGroupsShownInDropdown
        
        self.view.addSubview(dropDownMenu)
    }
    
    // Toggle dropDownMenu
    func dropDownMenuPressed() {
        if (isDropDownDisplayed) {
            // Configure navigationBar title to match filter
            if (filter == nil) {
                self.configureTitleView(allNotesTitle)
            } else {
                self.configureTitleView(filter.fullName!)
            }
            // Hide the dropDownMenu
            self.hideDropDownMenu()
        } else {
            // Configure navigationBar to display "Blip Notes"
            self.configureTitleView(appTitle)
            // Show the dropDownMenu
            self.showDropDownMenu()
        }
    }
    
    // Hide the dropDownMenu
    func hideDropDownMenu() {
        // Determine final destination of dropDownMenu and opaqueOverlay/obstruction
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = -dropDownHeight
        var overlayFrame: CGRect = self.opaqueOverlay.frame
        overlayFrame.origin.y = -overlayHeight
        // Perform animation
        self.animateDropDownToFrame(frame, overlayFrame: overlayFrame) {
            self.isDropDownDisplayed = false
        }
    }
    
    // Show the dropDownMenu
    func showDropDownMenu() {
        // Determine final destination of dropDownMenu and opaqueOverlay/obstruction
        var frame: CGRect = self.dropDownMenu.frame
        frame.origin.y = 0.0
        var overlayFrame: CGRect = self.opaqueOverlay.frame
        overlayFrame.origin.y = 0.0
        // Perform animation
        self.animateDropDownToFrame(frame, overlayFrame: overlayFrame) {
            self.isDropDownDisplayed = true
        }
    }
    
    // dropDownMenu animations
    func animateDropDownToFrame(frame: CGRect, overlayFrame: CGRect, completion:() -> Void) {
        if (!isDropDownAnimating) {
            isDropDownAnimating = true
            UIView.animateKeyframesWithDuration(dropDownAnimationTime, delay: 0.0, options: nil, animations: { () -> Void in
                self.dropDownMenu.frame = frame
                self.opaqueOverlay.frame = overlayFrame
                }, completion: { (completed: Bool) -> Void in
                    self.isDropDownAnimating = false
                    if (completed) {
                        completion()
                    }
            })
        }
    }
    
    // Lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
}