//
//  DropDownListView.swift
//  urchin
//
//  Created by Ethan Look on 6/19/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class DropDownTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var accounts: [User] = []
    
    var isAnimating: Bool = false
    var isDisplayed: Bool = false
    
    func loadUsers() {
        let sara = User(name: "Sara Krugman")
        let katie = User(name: "Katie Look")
        let shelly = User(name: "Shelly Surabouti")
        
        accounts.append(sara)
        accounts.append(katie)
        accounts.append(shelly)
        
        self.reloadData()
    }
    
    func setDropDownFrame(frame: CGRect) {
        self.frame = frame
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: UITableViewCell = self.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = accounts[indexPath.row].name
        
        return cell
    }
    
}