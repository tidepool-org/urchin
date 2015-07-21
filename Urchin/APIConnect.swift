//
//  APIConnect.swift
//  urchin
//
//  Created by Ethan Look on 7/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class APIConnector {
    
    var x_tidepool_session_token: String = ""
    var user: User?
    
    func login(loginVC: LogInViewController, username: String, password: String) {
        
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        
        if (loginVC.rememberMe) {
            self.saveLogin(base64LoginString)
        } else {
            self.saveLogin("")
        }
        
        // create the request
        let url = NSURL(string: "https://api.tidepool.io/auth/login")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let loading = LoadingView(text: "Logging in...")
        let loadingX = loginVC.view.frame.width / 2 - loading.frame.width / 2
        let loadingY = loginVC.view.frame.height / 2 - loading.frame.height / 2
        loading.frame.origin = CGPoint(x: loadingX, y: loadingY)
        loginVC.view.addSubview(loading)
        loginVC.view.bringSubviewToFront(loading)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                println("login \(httpResponse.statusCode)")
                
                if (httpResponse.statusCode == 200) {
                    var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
                    
                    if let sessionToken = httpResponse.allHeaderFields["x-tidepool-session-token"] as? String {
                        self.x_tidepool_session_token = sessionToken
                        self.user = User(userid: jsonResult.valueForKey("userid") as! String, apiConnector: self)
                        loginVC.makeTransition(self)
                    }
                }
            } else {
                println(error)
                println(response)
            }
            loading.removeFromSuperview()
        }
    }
    
    func login(loginVC: LogInViewController) {
        
        // Store the appDelegate
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Store the managedContext
        let managedContext = appDelegate.managedObjectContext!
        
        // Open a new fetch request
        let fetchRequest = NSFetchRequest(entityName:"Login")
        
        var error: NSError?
        
        // Execute the fetch
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            if (results.count != 0) {
                let expiration = results[0].valueForKey("expiration") as! NSDate
                let dateFormatter = NSDateFormatter()
                if (expiration.timeIntervalSinceNow < 0) {

                    // Login has expired!
                    
                    // Set the value to the new saved login
                    results[0].setValue("", forKey: "login")
                    
                    // Save the expiration date (6 mo.s in advance)
                    let dateShift = NSDateComponents()
                    dateShift.month = 6
                    let calendar = NSCalendar.currentCalendar()
                    let date = calendar.dateByAddingComponents(dateShift, toDate: NSDate(), options: nil)!
                    results[0].setValue(date, forKey: "expiration")
                    
                    // Attempt to save the login
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                }
                let login = results[0].valueForKey("login") as! String
                
                if (login != "") {
                    // Login information exists
                    
                    // create the request
                    let url = NSURL(string: "https://api.tidepool.io/auth/login")
                    let request = NSMutableURLRequest(URL: url!)
                    request.HTTPMethod = "POST"
                    request.setValue("Basic \(login)", forHTTPHeaderField: "Authorization")
                    
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                        
                        if let httpResponse = response as? NSHTTPURLResponse {
                            println(httpResponse.statusCode)
                        }
                        
                        var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
                        
                        if let httpResponse = response as? NSHTTPURLResponse {
                            if let sessionToken = httpResponse.allHeaderFields["x-tidepool-session-token"] as? String {
                                self.x_tidepool_session_token = sessionToken
                                self.user = User(userid: jsonResult.valueForKey("userid") as! String, apiConnector: self)
                                loginVC.makeTransition(self)
                            }
                        }
                    }
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }

    
    func saveLogin(login: String) {
        // Store the appDelegate
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Store the managedContext
        let managedContext = appDelegate.managedObjectContext!
        
        // Open a new fetch request
        let fetchRequest = NSFetchRequest(entityName:"Login")
        
        var error: NSError?
        
        // Execute the fetch
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            if (results.count == 0) {
                // Create a new login for remembering
                
                // Initialize the new entity
                let entity =  NSEntityDescription.entityForName("Login",
                    inManagedObjectContext:
                    managedContext)
                
                // Let it be a hashtag in the managedContext
                let loginObj = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                // Save the encrypted login information
                loginObj.setValue(login, forKey: "login")
                
                // Save the expiration date (6 mo.s in advance)
                let dateShift = NSDateComponents()
                dateShift.month = 6
                let calendar = NSCalendar.currentCalendar()
                let date = calendar.dateByAddingComponents(dateShift, toDate: NSDate(), options: nil)!
                loginObj.setValue(date, forKey: "expiration")
                
                // Save the login
                var errorTwo: NSError?
                if !managedContext.save(&errorTwo) {
                    println("Could not save \(errorTwo), \(errorTwo?.userInfo)")
                }
            } else if (results.count == 1) {
                // Set the value to the new saved login
                results[0].setValue(login, forKey: "login")
                
                // Save the expiration date (6 mo.s in advance)
                let dateShift = NSDateComponents()
                dateShift.month = 6
                let calendar = NSCalendar.currentCalendar()
                let date = calendar.dateByAddingComponents(dateShift, toDate: NSDate(), options: nil)!
                results[0].setValue(date, forKey: "expiration")
                
                // Attempt to save the login
                var errorTwo: NSError?
                if !managedContext.save(&errorTwo) {
                    println("Could not save \(errorTwo), \(errorTwo?.userInfo)")
                }
            }
        }  else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func logout(notesVC: NotesViewController) {
        
        self.saveLogin("")
        
        // /auth/logout
        
        // create the request
        let url = NSURL(string: "https://api.tidepool.io/auth/logout")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                println(httpResponse.statusCode)
            }
            
            notesVC.dismissViewControllerAnimated(true, completion: {
                self.user = nil
                self.x_tidepool_session_token = ""
            })
        }
    }
    
    func findProfile(otherUser: User) {
        // '/metadata/' + userId + '/profile'
        
        let url = NSURL(string: "https://api.tidepool.io/metadata/\(otherUser.userid)/profile")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                println(httpResponse.statusCode)
            }
            
            var userDict: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
            
//            println(userDict)
            
            otherUser.processUserDict(userDict)
            
            // Send notification to NotesVC to handle new note that was just created
            let notification = NSNotification(name: "anotherGroup", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    func getAllViewableUsers(notesVC: NotesViewController) {
        // '/access/groups/' + userId
        
        let url = NSURL(string: "https://api.tidepool.io/access/groups/\(user!.userid)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        let loading = LoadingView(text: "Loading teams...")
        let loadingX = notesVC.notesTable.frame.width / 2 - loading.frame.width / 2
        let loadingY = notesVC.notesTable.frame.height / 2 - loading.frame.height / 2
        loading.frame.origin = CGPoint(x: loadingX, y: loadingY)
        notesVC.view.addSubview(loading)
        notesVC.view.bringSubviewToFront(loading)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                println(httpResponse.statusCode)
            }
            
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
            
            for key in jsonResult.keyEnumerator() {
                let group = User(userid: key as! String, apiConnector: self)
                notesVC.groups.insert(group, atIndex: 0)
            }
            
            loading.removeFromSuperview()
        }
    }
    
    func getNotesForUserInDateRange(notesVC: NotesViewController, userid: String, start: NSDate, end: NSDate) {
        // '/message/notes/' + userId + '?starttime=' + start + '&endtime=' + end
        // Only top level notes
        
        // create the request
        let dateFormatter = NSDateFormatter()
        let url = NSURL(string: "https://api.tidepool.io/message/notes/\(userid)?starttime=\(dateFormatter.isoStringFromDate(start))&endtime=\(dateFormatter.isoStringFromDate(end))")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        notesVC.loadingNotes = true
        notesVC.numberFetches++
        
        let loading = LoadingView(text: "Loading notes...")
        let loadingX = notesVC.notesTable.frame.width / 2 - loading.frame.width / 2
        let loadingY = notesVC.notesTable.frame.height / 2 - loading.frame.height / 2
        loading.frame.origin = CGPoint(x: loadingX, y: loadingY)
        notesVC.view.addSubview(loading)
        notesVC.view.bringSubviewToFront(loading)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                println(httpResponse.statusCode)
            }
            
            var notes: [Note] = []
            
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
            
            var messages: NSArray = jsonResult.valueForKey("messages") as! NSArray
            
            let dateFormatter = NSDateFormatter()
            
            for message in messages {
                let id = message.valueForKey("id") as! String
                let otheruserid = message.valueForKey("userid") as! String
                let groupid = message.valueForKey("groupid") as! String
                let timestamp = dateFormatter.dateFromISOString(message.valueForKey("timestamp") as! String)
                var createdtime: NSDate
                if let created = message.valueForKey("createdtime") as? String {
                    createdtime = dateFormatter.dateFromISOString(created)
                } else {
                    createdtime = timestamp
                }
                let messagetext = message.valueForKey("messagetext") as! String
                
                let otheruser = User(userid: otheruserid)
                let userDict = message.valueForKey("user") as! NSDictionary
                otheruser.processUserDict(userDict)

                let note = Note(id: id, userid: otheruserid, groupid: groupid, timestamp: timestamp, createdtime: createdtime, messagetext: messagetext, user: otheruser)
                notes.append(note)
            }
            
            notesVC.notes = notesVC.notes + notes
            notesVC.notes.sort({$0.timestamp.timeIntervalSinceNow > $1.timestamp.timeIntervalSinceNow})
            notesVC.filterNotes()
            notesVC.notesTable.reloadData()
            notesVC.numberFetches--
            if (notesVC.numberFetches == 0) {
                notesVC.loadingNotes = false
            }
            loading.removeFromSuperview()
        }
    }
    
    func doPostWithToken(note: Note) {
        // '/message/send/' + message.groupid
        
        // create the request
        let url = NSURL(string: "https://api.tidepool.io/message/send/\(note.groupid)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonObject = note.dictionaryFromNote()
        
        println(NSJSONSerialization.isValidJSONObject(jsonObject))
        println(NSJSONSerialization.JSONObjectWithData(NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: nil)!, options: nil, error: nil)!)
        
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
//            
//            if let httpResponse = response as? NSHTTPURLResponse {
//                println(httpResponse.statusCode)
//            }
//            
//            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
//        }
    }
}