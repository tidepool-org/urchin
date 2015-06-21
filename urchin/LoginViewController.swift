//
//  LoginViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class LogInViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("log in view controller")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "makeTransition", userInfo: nil, repeats: false)
    }
    
    func makeTransition() {
        let sarapatient = Patient(birthday: NSDate(), diagnosisDate: NSDate(), aboutMe: "Designer guru.")
        let notesScene = UINavigationController(rootViewController: NotesViewController(user: User(firstName: "Sara", lastName: "Krugman", patient: sarapatient)))
        self.presentViewController(notesScene, animated: true, completion: nil)
    }

}