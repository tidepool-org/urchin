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
import CocoaLumberjack

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // All notes
    var notes: [Note] = []
    // Only filtered notes
    var filteredNotes: [Note] = []
    // All groups
    var groups: [User] = []
    // Count how many groups have metadata
    var groupsWMetadata: Int = 0
    
    // For some smart fetching
    var numberOfNotes: Int = 0
    var consecutiveFetches: Int = 0
    
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
    
    // Last date fetched to & beginning -- starts at current date
    var lastDateFetchTo: NSDate = NSDate()
    var beginning: NSDate = NSDate()
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
    
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    init(apiConnector: APIConnector) {
        // Initialize with API connection and user (from loginVC)
        self.apiConnector = apiConnector
        self.user = apiConnector.user!
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
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

        // Thicken navBar border
        let border = CALayer()
        border.borderColor = whiteQuarterAlpha.CGColor
        border.borderWidth = 1
        let navBarLayer = self.navigationController!.navigationBar.layer
        border.frame = CGRect(x: 0, y: navBarLayer.bounds.height, width: navBarLayer.bounds.width, height: 1)
        navBarLayer.addSublayer(border)
        
        // Title view starts as App title
        let titleView = UILabel()
        titleView.text = appTitle
        titleView.font = mediumRegularFont
        titleView.textColor = navBarTitleColor
        titleView.sizeToFit()
        titleView.frame.size.height = self.navigationController!.navigationBar.frame.size.height
        self.navigationItem.titleView = titleView
        
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
        
        // Fetch the groups for notes and (eventually) dropDownMenu
        // Successful completion of fetch will configure dropDownMenu and then load notes
        self.loadGroups()
        
        // Configure notification center to observe addNote and saveNote
        //      called from addNoteVC and editNoteVC respectively
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "addNote:", name: "addNote", object: nil)
        notificationCenter.addObserver(self, selector: "saveNote:", name: "saveNote", object: nil)
        // Listen for when addNoteVC or editNoteVC has been closed without saving or posting
        notificationCenter.addObserver(self, selector: "doneAdding:", name: "doneAdding", object: nil)
        notificationCenter.addObserver(self, selector: "doneEditing:", name: "doneEditing", object: nil)
        notificationCenter.addObserver(self, selector: "deleteNote:", name: "deleteNote", object: nil)

        // Listen for when group metadata has been fetched
        notificationCenter.addObserver(self, selector: "groupsReady:", name: "groupsReady", object: nil)
        // Listen for when done fetching notes
        notificationCenter.addObserver(self, selector: "doneFetching", name: "doneFetching", object: nil)
        // Listen for when to open an NewNoteVC
        notificationCenter.addObserver(self, selector: "newNote:", name: "newNote", object: nil)
        // Listen for when to refresh session token
        notificationCenter.addObserver(self, selector: "refreshSessionToken:", name: "refreshSessionToken", object: nil)
        // Listen for when force a logout
        notificationCenter.addObserver(self, selector: "forcedLogout:", name: "forcedLogout", object: nil)

        // Handle HealthKitDataSync notifications
        notificationCenter.addObserver(self, selector: "handleObservedHealthKitDataSyncNotification:", name: HealthKitDataSync.Notifications.ObservedBloodGlucoseSamples, object: nil)
        notificationCenter.addObserver(self, selector: "handleObservedHealthKitDataSyncNotification:", name: HealthKitDataSync.Notifications.ObservedWorkoutSamples, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewReadyForTransition = true
        initialAddNote()
    }
    
    func groupsReady(notification: NSNotification) {

        if (groups.count != 0) {
            
            sortGroups()
            
            self.view.addSubview(newNoteButton)
            
            configureDropDownMenu()
            
            // Add rightBarButtonItem to down arrow for showing dropdown
            let rightDropDownMenuButton: UIBarButtonItem = UIBarButtonItem(image: downArrow, style: .Plain, target: self, action: "dropDownMenuPressed")
            self.navigationItem.setRightBarButtonItem(rightDropDownMenuButton, animated: true)
            
            if (groups.count == 1) {
                configureTitleView(appTitle)
            } else {
                // navigationBar title is "All Notes" to match #nofilter to start
                configureTitleView(allNotesTitle)
            }
            
            groupsReadyForTransition = true
            initialAddNote()
            
            loadNotes()
            
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSFontAttributeName: smallRegularFont, NSForegroundColorAttributeName: blackishColor])
            self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
            self.notesTable.addSubview(refreshControl)
        } else {
            DDLogInfo("No data storage accounts")
            let errorLabel: UILabel = UILabel()
            errorLabel.text = "Looks like you don't have access to any data yet. Please ask people to invite you to see their data in Blip so you can post notes for them."
            errorLabel.font = mediumSemiboldFont
            errorLabel.textColor = blackishColor
            errorLabel.textAlignment = .Center
            errorLabel.numberOfLines = 0
            errorLabel.frame.size = CGSize(width: self.view.frame.width - 2 * labelInset, height: CGFloat.max)
            errorLabel.sizeToFit()
            errorLabel.frame.origin.x = self.view.frame.width / 2 - errorLabel.frame.width / 2
            errorLabel.frame.origin.y = self.view.frame.height / 2 - errorLabel.frame.height / 2
            self.view.addSubview(errorLabel)
            
            let logoutLabel = UILabel()
            logoutLabel.text = "logout"
            logoutLabel.font = mediumRegularFont
            logoutLabel.textAlignment = .Center
            logoutLabel.textColor = blackishColor
            logoutLabel.sizeToFit()
            logoutLabel.frame.size.width += 2 * hitBoxAmount
            logoutLabel.frame.size.height += 2 * hitBoxAmount
            logoutLabel.frame.origin.y = errorLabel.frame.maxY + labelSpacing
            logoutLabel.frame.origin.x = self.view.frame.width / 2 - logoutLabel.frame.width / 2
            let recognizer = UITapGestureRecognizer(target: self, action: "logout")
            logoutLabel.userInteractionEnabled = true
            logoutLabel.addGestureRecognizer(recognizer)
            self.view.addSubview(logoutLabel)
            
            self.newNoteButton.removeFromSuperview()
            self.navigationItem.setRightBarButtonItem(nil, animated: true)
        }
        
    }
    
    func sortGroups() {
        
        groups.sortInPlace {
            return $0.fullName < $1.fullName
        }
        
        for (var i = 0; i < groups.count; i++) {
            if (groups[i].userid == user.userid) {
                
                let myDSA = groups[i]
                groups.removeAtIndex(i)
                groups.insert(myDSA, atIndex: 0)
                
                break
            }
        }
        
    }
    
    func logout() {
        // Logout selected
        // Unwind VC
        apiConnector.trackMetric("Logged Out")
        apiConnector.logout(self)
    }
    
    func forcedLogout(notification: NSNotification) {
        
        // For when session token has expired
        
        let notification = NSNotification(name: "prepareLogin", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        if (addOrEditShowing) {
            self.dismissViewControllerAnimated(true, completion: {
                self.dismissViewControllerAnimated(true, completion: {
                    self.apiConnector.user = nil
                    self.apiConnector.x_tidepool_session_token = ""
                })
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: {
                self.apiConnector.user = nil
                self.apiConnector.x_tidepool_session_token = ""
            })
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
        DDLogVerbose("trace")
        
        if (!loadingNotes) {
            // Shift back three months for fetching
            let dateShift = NSDateComponents()
            dateShift.month = fetchPeriodInMonths
            let calendar = NSCalendar.currentCalendar()
            let startDate = calendar.dateByAddingComponents(dateShift, toDate: lastDateFetchTo, options: [])!
            
            for group in groups {
                apiConnector.getNotesForUserInDateRange(self, userid: group.userid, start: startDate, end: lastDateFetchTo)
            }
            
            self.lastDateFetchTo = startDate
        }
    }
    
    func refresh() {
        DDLogVerbose("trace)")
        
        if (!loadingNotes) {
            
            notes = []
            filteredNotes = []
            
            numberOfNotes = 0
            
            lastDateFetchTo = NSDate()
            
            loadNotes()
        }
        
    }
    
    func doneFetching() {
        
        let lastAmount = numberOfNotes
        numberOfNotes = notes.count
        
        if ((lastAmount + 10) > numberOfNotes && consecutiveFetches < 4) {
            consecutiveFetches++
            loadNotes()
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
        notes.sortInPlace({$0.timestamp.timeIntervalSinceNow > $1.timestamp.timeIntervalSinceNow})
        
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
        
        apiConnector.editNote(self, editedNote: editNoteViewController!.editedNote, originalNote:
        editNoteViewController!.note)
    }
    
    func deleteNote(sender: AnyObject) {
        addOrEditShowing = false

        apiConnector.deleteNote(self, noteToDelete: editNoteViewController!.note)
        
    }
    
    // Fetch and load the groups/teams that user is involved in
    func loadGroups() {
        apiConnector.getAllViewableUsers(self)
    }
    
    func refreshSessionToken(notification: NSNotification) {
        apiConnector.refreshToken()
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
    
    func handleObservedHealthKitDataSyncNotification(notification: NSNotification) {
        if (dropDownMenu != nil) {
            dropDownMenu.reloadData()
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
        var additionalCells = groups.count == 1 ? 1 : 3
        if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
            additionalCells++
            if (HealthKitDataSync.sharedInstance.lastDbSyncCount > 0) {
                additionalCells++
            }
        }
        let proposedDropDownH = CGFloat(groups.count+additionalCells)*userCellHeight + CGFloat(groups.count)*userCellThinSeparator + 2*userCellThickSeparator
        self.dropDownHeight = min(proposedDropDownH, self.view.frame.height)
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
        
        // Shadowing
        dropDownMenu.layer.masksToBounds = true
        dropDownMenu.layer.shadowColor = blackishColor.CGColor
        dropDownMenu.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        dropDownMenu.layer.shadowOpacity = 0.75
        dropDownMenu.layer.shadowRadius = shadowHeight
        
        // Drop down menu is only scrollable if the content fits
        dropDownMenu.scrollEnabled = proposedDropDownH > self.dropDownMenu.frame.height
        
        self.view.addSubview(dropDownMenu)
    }
    
    // Toggle dropDownMenu
    func dropDownMenuPressed() {
        if (isDropDownDisplayed) {
            // Configure navigationBar title to match filter
            if (groups.count > 1) {
                if (filter == nil) {
                    self.configureTitleView(allNotesTitle)
                } else {
                    self.configureTitleView(filter.fullName!)
                }
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
            self.dropDownMenu.layer.masksToBounds = true
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
            self.dropDownMenu.layer.masksToBounds = false
        }
    }
    
    // dropDownMenu animations
    func animateDropDownToFrame(frame: CGRect, overlayFrame: CGRect, completion:() -> Void) {
        if (!isDropDownAnimating) {
            isDropDownAnimating = true
            UIView.animateKeyframesWithDuration(dropDownAnimationTime, delay: 0.0, options: [], animations: { () -> Void in
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
    
    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView.isEqual(notesTable)) {
            
            // Configure NoteCell
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NoteCell), forIndexPath: indexPath) as! NoteCell
            
            let note = filteredNotes[indexPath.row]
            
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
            
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = lightGreyColor
            } else {
                cell.backgroundColor = darkestGreyLowAlpha
            }
            
            cell.userInteractionEnabled = true
            cell.selectionStyle = .None
            
            // editButton tag to be indexPath.row so can be used in editPressed notification handling
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: "editPressed:", forControlEvents: .TouchUpInside)
            
            return cell
            
        } else {
            // Configure UserDropDownCell
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
            
            
            cell.userInteractionEnabled = true
            
            let customSelection = UIView()
            customSelection.backgroundColor = tealColor
            cell.selectedBackgroundView = customSelection
            
            if (groups.count == 1) {
                
                if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 0) {
                    cell.configure("healthkit", arrow: false)
                } else if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 1) {
                    cell.configure("healthkit-sync", arrow: false)
                    cell.userInteractionEnabled = false
                } else if (indexPath.section == sectionIndex(TableSection.Logout) && indexPath.row == 0) {
                    cell.configure("logout", arrow: false)
                } else if (indexPath.section == sectionIndex(TableSection.Version) && indexPath.row == 0) {
                    cell.configure("version")
                    cell.userInteractionEnabled = false
                }
            } else {
                if (indexPath.section == sectionIndex(TableSection.Users) && indexPath.row == 0) {
                    cell.configure("all")
                } else if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 0) {
                    cell.configure("healthkit", arrow: false)
                } else if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 1) {
                    cell.configure("healthkit-sync", arrow: false)
                    cell.userInteractionEnabled = false
                } else if (indexPath.section == sectionIndex(TableSection.Logout) && indexPath.row == 0) {
                    cell.configure("logout", arrow: false)
                } else if (indexPath.section == sectionIndex(TableSection.Version) && indexPath.row == 0) {
                    cell.configure("version")
                    cell.userInteractionEnabled = false
                } else {
                    // Individual group / filter cell
                    cell.configure(groups[indexPath.row - 1], last: indexPath.row == groups.count, arrow: true, bold: false)
                }
            }
            
            return cell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfSections = 1
        
        if (tableView.isEqual(dropDownMenu)) {
            if (groups.count == 1) {
                // Logout, Version
                numberOfSections = 2
            } else {
                // Filters, Logout, Version
                numberOfSections = 3
            }
            
            if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
                numberOfSections++
            }
        }
        
        return numberOfSections
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        if (tableView.isEqual(notesTable)) {
            numberOfRows = filteredNotes.count
        } else if (tableView.isEqual(dropDownMenu)){
            if (groups.count == 1) {
                if section == sectionIndex(TableSection.HealthKit) {
                    numberOfRows = HealthKitDataSync.sharedInstance.lastDbSyncCount > 0 ? 2 : 1
                }
            } else {
                if (section == sectionIndex(TableSection.Users)) {
                    // Number of groups + 1 for 'All' / #nofilter
                    numberOfRows = groups.count + 1
                } else if (section == sectionIndex(TableSection.HealthKit)) {
                    numberOfRows = HealthKitDataSync.sharedInstance.lastDbSyncCount > 0 ? 2 : 1
                } else if (section == sectionIndex(TableSection.Logout)) {
                    numberOfRows = 1
                } else if (section == sectionIndex(TableSection.Version)) {
                    numberOfRows = 1
                }
            }
        }
        
        return numberOfRows
    }

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView.isEqual(notesTable)) {
            
            // NotesTable
            
            let note = filteredNotes[indexPath.row]
            
            // Create labels that 'determine' height of cell
            
            // Configure the username label, with the full name
            let usernameLabel = UILabel()
            
            var usernameWidth = self.view.frame.width - (2 * noteCellInset)
            if (note.user!.userid == user.userid) {
                // Compensate for width of edit button
                usernameWidth -= editButtonWidth
            }
            usernameLabel.frame.size = CGSize(width: usernameWidth, height: CGFloat.max)
            var attrUsernameLabel = NSMutableAttributedString(string: note.user!.fullName!, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: mediumSemiboldFont])
            if (note.groupid != note.userid) {
                for group in groups {
                    if (group.userid == note.groupid) {
                        attrUsernameLabel = NSMutableAttributedString(string: "\(note.user!.fullName!) to \(group.fullName!)", attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: mediumSemiboldFont])
                        break
                    }
                }
            }
            usernameLabel.attributedText = attrUsernameLabel
            usernameLabel.adjustsFontSizeToFitWidth = false
            usernameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            usernameLabel.numberOfLines = 0
            usernameLabel.sizeToFit()
            
            // Configure the date label size using extended dateFormatter
            let timedateLabel = UILabel()
            let dateFormatter = NSDateFormatter()
            timedateLabel.attributedText = dateFormatter.attributedStringFromDate(note.timestamp)
            timedateLabel.sizeToFit()
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 2*noteCellInset, height: CGFloat.max))
            let hashtagBolder = HashtagBolder()
            let attributedText = hashtagBolder.boldHashtags(note.messagetext)
            messageLabel.attributedText = attributedText
            messageLabel.adjustsFontSizeToFitWidth = false
            messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            messageLabel.numberOfLines = 0
            messageLabel.sizeToFit()
            
            // Calculate the total note cell height
            let cellHeight: CGFloat = noteCellInset + usernameLabel.frame.height + labelSpacing / 2 + timedateLabel.frame.height + 2 * labelSpacing + messageLabel.frame.height + noteCellInset
            
            return cellHeight
            
            
        } else {
            // DropDownMenu
            
            if (groups.count == 1) {
                
                if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 0) {
                    let nameLabel = UILabel()
                    nameLabel.text = healthKitTitle
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + (userCellThickSeparator - userCellThinSeparator)
                } else if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 1) {
                    let nameLabel = UILabel()
                    nameLabel.text = healthKitTitle
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + (userCellThickSeparator - userCellThinSeparator)
                } else if (indexPath.section == sectionIndex(TableSection.Logout) && indexPath.row == 0) {
                    let nameLabel = UILabel()
                    nameLabel.text = logoutTitle
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + (userCellThickSeparator - userCellThinSeparator)
                } else if (indexPath.section == sectionIndex(TableSection.Version) && indexPath.row == 0) {
                    let nameLabel = UILabel()
                    nameLabel.text = UIApplication.versionBuildServer()
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + userCellThickSeparator
                } else {
                    return 0
                }
                
            } else {
                if (indexPath.section == sectionIndex(TableSection.Users) && indexPath.row == 0) {
                    let nameLabel = UILabel()
                    nameLabel.text = allTeamsTitle
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellThickSeparator + userCellInset + nameLabel.frame.height + userCellInset + userCellThinSeparator
                } else if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 0) {
                    let nameLabel = UILabel()
                    nameLabel.text = healthKitTitle
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + (userCellThickSeparator - userCellThinSeparator)
                } else if (indexPath.section == sectionIndex(TableSection.HealthKit) && indexPath.row == 1) {
                    let nameLabel = UILabel()
                    nameLabel.text = healthKitTitle
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + (userCellThickSeparator - userCellThinSeparator)
                } else if (indexPath.section == sectionIndex(TableSection.Logout) && indexPath.row == 0) {
                    let nameLabel = UILabel()
                    nameLabel.text = logoutTitle
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + (userCellThickSeparator - userCellThinSeparator)
                } else if (indexPath.section == sectionIndex(TableSection.Version) && indexPath.row == 0) {
                    let nameLabel = UILabel()
                    nameLabel.text = UIApplication.versionBuildServer()
                    nameLabel.font = mediumBoldFont
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + userCellThickSeparator
                    
                } else {
                    // Some group / team / filter
                    
                    let nameLabel = UILabel()
                    nameLabel.frame.size = CGSize(width: self.view.frame.width - 2 * labelInset, height: dropDownGroupLabelHeight)
                    nameLabel.text = groups[indexPath.row - 1].fullName
                    if (filter === groups[indexPath.row - 1]) {
                        nameLabel.font = mediumBoldFont
                    } else {
                        nameLabel.font = mediumRegularFont
                    }
                    nameLabel.sizeToFit()
                    
                    return userCellInset + nameLabel.frame.height + userCellInset + userCellThinSeparator
                }
            }
        }
    }
    
    // didSelectRowAtIndexPath
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Immediately deselect the row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (tableView.isEqual(dropDownMenu)) {
            // dropDownMenu
            
            if (groups.count == 1) {
                
                if (indexPath.section == sectionIndex(TableSection.HealthKit)) {
                    authorizeAndEnableHealthDataSync()
                } else if (indexPath.section == sectionIndex(TableSection.Logout)) {
                    self.logout()
                }
            } else {
                if (indexPath.section == sectionIndex(TableSection.Users)) {
                    // A group or all seleceted
                    if (indexPath.row == 0) {
                        if (filter != nil) {
                            self.apiConnector.trackMetric("Clicked All in Feed")
                        }
                        
                        // 'All' / #nofilter selected
                        self.configureTitleView(allNotesTitle)
                        self.filter = nil
                    } else {
                        
                        // Individual group / filter selected
                        if (filter !== groups[indexPath.row - 1]) {
                            self.apiConnector.trackMetric("Changed Person in Feed")
                        }
                        self.filter = groups[indexPath.row - 1]
                        self.configureTitleView(filter.fullName!)
                    }
                    // filter the notes based upon new filter
                    filterNotes()
                    // Scroll notes to top
                    self.notesTable.setContentOffset(CGPointMake(0, -self.notesTable.contentInset.top), animated: true)
                    // toggle the dropDownMenu (hides the dropDownMenu)
                    self.dropDownMenuPressed()
                } else if (indexPath.section == sectionIndex(TableSection.HealthKit)) {
                    authorizeAndEnableHealthDataSync()
                } else if (indexPath.section == sectionIndex(TableSection.Logout)) {
                    self.logout()
                }
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.isEqual(notesTable)) {
            
            // Determine whether the notesTable is scrolled all the way down
            let height = scrollView.frame.height
            let contentYOffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYOffset
            
            // If so, load notes
            if (distanceFromBottom == height && !loadingNotes) {
                self.apiConnector.trackMetric("Scrolled Down For More Notes")
                
                consecutiveFetches = 0
                loadNotes()
            }
        }
    }
    
    // MARK: - Private util methods
    
    private enum TableSection {
        case Users, HealthKit, Logout, Version
    }
    
    private func sectionIndex(section: TableSection) -> Int {
        var sectionIndex = -1
        
        if (groups.count == 1) {
            if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
                switch section {
                case .HealthKit:
                    sectionIndex = 0
                case .Logout:
                    sectionIndex = 1
                case .Version:
                    sectionIndex = 2
                default:
                    sectionIndex = -1
                }
            } else {
                switch section {
                case .Logout:
                    sectionIndex = 0
                case .Version:
                    sectionIndex = 1
                default:
                    sectionIndex = -1
                }
            }
        } else {
            if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
                switch section {
                case .Users:
                    sectionIndex = 0
                case .HealthKit:
                    sectionIndex = 1
                case .Logout:
                    sectionIndex = 2
                case .Version:
                    sectionIndex = 3
                }
            } else {
                switch section {
                case .Users:
                    sectionIndex = 0
                case .Logout:
                    sectionIndex = 1
                case .Version:
                    sectionIndex = 2
                default:
                    sectionIndex = -1
                }
            }
        }
            
        return sectionIndex;
    }
    
    private func authorizeAndEnableHealthDataSync() {
        if (HealthKitManager.sharedInstance.isHealthDataAvailable) {
            HealthKitDataSync.sharedInstance.authorizeAndStartSyncing(
                shouldSyncBloodGlucoseSamples: true,
                shouldSyncWorkoutSamples: true)
        }
    }
}