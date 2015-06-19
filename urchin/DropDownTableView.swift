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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        println("overriding init")
        
        self.registerClass(UserDropDownCell.self, forCellReuseIdentifier: NSStringFromClass(UserDropDownCell))

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUsers() {
        let sarapatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Designer guru.")
        let sara = User(firstName: "Sara", lastName: "Krugman", patient: sarapatient)
        let katiepatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Annoying little sister. Everyone's inspiration.")
        let katie = User(firstName: "Katie", lastName: "Look", patient: katiepatient)
        let shellypatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Shelly is a rockstar.")
        let shelly = User(firstName: "Shelly", lastName: "Surabouti", patient: shellypatient)
        
        accounts.append(sara)
        accounts.append(katie)
        accounts.append(shelly)
        
        println("yes")
        
        self.reloadData()
    }
    
    func setDropDownFrame(frame: CGRect) {
        self.frame = frame
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(accounts.count)
        return accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.dequeueReusableCellWithIdentifier(NSStringFromClass(UserDropDownCell), forIndexPath: indexPath) as! UserDropDownCell
        
        cell.configureWithUser(accounts[indexPath.row])
        println(cell.nameLabel.text)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = UserDropDownCell(style: .Default, reuseIdentifier: nil)
        cell.configureWithUser(accounts[indexPath.row])
        return cell.cellHeight
    }
    
}