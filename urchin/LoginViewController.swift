//
//  LoginViewController.swift
//  urchin
//
//  Created by Ethan Look on 6/18/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class logInViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("log in view controller")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let notesScene = UINavigationController(rootViewController: NotesTableViewController(user: User(name: "Sara Krugman")))
        self.presentViewController(notesScene, animated: true, completion: nil)
    }

}