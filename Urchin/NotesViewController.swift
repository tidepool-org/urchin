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
    
    let user: User
    var notesTable: UITableView!
    
    init(user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        self.title = user.name
        
        self.notesTable = UITableView(frame: self.view.frame)
        
        notesTable.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        notesTable.rowHeight = noteCellHeight
        notesTable.separatorInset.left = noteCellInset
        notesTable.registerClass(NoteCell.self, forCellReuseIdentifier: NSStringFromClass(NoteCell))
        notesTable.dataSource = self
        notesTable.delegate = self
        
        self.loadNotes()
        
        self.view.addSubview(notesTable)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadNotes() {
        let newnote = Note(text: "This is a new note. I am making the note longer to see if wrapping occurs or not.")
        notes.append(newnote)
        
        let anothernote = Note(text: "This is a another note. I am making the note longer to see if how this looks with multiple notes of different heights. If it goes well, I will be thrilled.")
        notes.append(anothernote)
        
        notesTable.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NoteCell), forIndexPath: indexPath) as! NoteCell
        
        cell.configureWithNote(notes[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = NoteCell(style: .Default, reuseIdentifier: nil)
        cell.configureWithNote(notes[indexPath.row])
        return cell.cellHeight
    }
    
}