//
//  NotesTableViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/17/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class NotesTableViewController: UITableViewController {
    
    var notes: [Note] = []
    
    let user: User
    
    init(user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        tableView.rowHeight = noteCellHeight
        tableView.separatorInset.left = noteCellInset
        tableView.registerClass(NoteCell.self, forCellReuseIdentifier: NSStringFromClass(NoteCell))
        
        self.title = user.name
        
        
        self.loadNotes()
    }
    
    func loadNotes() {
        let newnote = Note(text: "This is a new note. I am making the note longer to see if wrapping occurs or not.")
        notes.append(newnote)
        
        let anothernote = Note(text: "This is a another note. I am making the note longer to see if how this looks with multiple notes of different heights. If it goes well, I will be thrilled.")
        notes.append(anothernote)
        
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NoteCell), forIndexPath: indexPath) as! NoteCell
        
        cell.configureWithNote(notes[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = NoteCell(style: .Default, reuseIdentifier: nil)
        cell.configureWithNote(notes[indexPath.row])
        
        return cell.cellHeight
    }
    
}