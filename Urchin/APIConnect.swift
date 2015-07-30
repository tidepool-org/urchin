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
    
    let baseURL: String = "https://devel-api.tidepool.io"
    let metricsSource: String = "urchin"
    var x_tidepool_session_token: String = ""
    var user: User?
    
    func request(method: String, urlExtension: String, headerDict: [String: String], body: NSData?, preRequest: () -> Void, completion: (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void) {
        
        preRequest()
        
        var urlString = baseURL + urlExtension
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = method
        for (field, value) in headerDict {
            request.setValue(value, forHTTPHeaderField: field)
        }
        request.HTTPBody = body
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            completion(response: response, data: data, error: error)
        }
    }
    
    func trackMetric(metricName: String) {
        
        let urlExtension = "/metrics/thisuser/\(metricsSource) - \(metricName)?source=\(metricsSource)&sourceVersion=\(UIApplication.appVersion())"
        println(urlExtension)
        
        let headerDict: [String: String] = ["x-tidepool-session-token":"\(x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to do
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    NSLog("Tracked metric: \(metricName)")
                } else {
                    NSLog("Invalid status code: \(httpResponse.statusCode) for tracking metric: \(metricName)")
                }
            } else {
                NSLog("Invalid response for tracking metric")
            }
        }
        
        request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
    }
    
    func login(loginVC: LogInViewController, username: String, password: String) {
        
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        
        if (loginVC.rememberMe) {
            self.saveLogin(base64LoginString)
        } else {
            self.saveLogin("")
        }
        
        loginRequest(loginVC, base64LoginString: base64LoginString)
    }
    
    func loginRequest(loginVC: LogInViewController?, base64LoginString: String) {

        let headerDict = ["Authorization":"Basic \(base64LoginString)"]
        
        let loading = LoadingView(text: loadingLogIn)
        
        let preRequest = { () -> Void in
            if (loginVC != nil) {
                let loadingX = loginVC!.view.frame.width / 2 - loading.frame.width / 2
                let loadingY = loginVC!.view.frame.height / 2 - loading.frame.height / 2
                loading.frame.origin = CGPoint(x: loadingX, y: loadingY)
                loginVC!.view.addSubview(loading)
                loginVC!.view.bringSubviewToFront(loading)
            }
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
            
            if let code = jsonResult.valueForKey("code") as? Int {
                if (code == 401) {
                    NSLog("Invalid login request: \(code)")
                    
                    let notification = NSNotification(name: "prepareLogin", object: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                    
                    self.alertWithOkayButton(invalidLogin, message: invalidLoginMessage)
                } else {
                    NSLog("Invalid login request: \(code)")
                    
                    let notification = NSNotification(name: "prepareLogin", object: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                    
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
            } else {
                if let httpResponse = response as? NSHTTPURLResponse {
                    
                    if (httpResponse.statusCode == 200) {
                        NSLog("Successful login: \(httpResponse.statusCode)")
                        
                        var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
                        
                        if let sessionToken = httpResponse.allHeaderFields["x-tidepool-session-token"] as? String {
                            self.x_tidepool_session_token = sessionToken
                            self.user = User(userid: jsonResult.valueForKey("userid") as! String, apiConnector: self)
                            
                            let notification = NSNotification(name: "makeTransitionToNotes", object: nil)
                            NSNotificationCenter.defaultCenter().postNotification(notification)
                            
                            let notificationTwo = NSNotification(name: "directLogin", object: nil)
                            NSNotificationCenter.defaultCenter().postNotification(notificationTwo)
                        } else {
                            NSLog("Invalid login: \(httpResponse.statusCode)")
                            
                            let notification = NSNotification(name: "prepareLogin", object: nil)
                            NSNotificationCenter.defaultCenter().postNotification(notification)
                        }
                    } else {
                        NSLog("Invalid status code: \(httpResponse.statusCode) for logging in")
                        
                        let notification = NSNotification(name: "prepareLogin", object: nil)
                        NSNotificationCenter.defaultCenter().postNotification(notification)
                        
                        self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                    }
                } else {
                    NSLog("Invalid response for logging in")
                    
                    let notification = NSNotification(name: "prepareLogin", object: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                    
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
            }
            // If there is a loginVC, remove the loading view from it
            if (loginVC != nil) {
                loading.removeFromSuperview()
            }
        }
        
        request("POST", urlExtension: "/auth/login", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
    }
    
    func login() {
        
        // Store the appDelegate
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Store the managedContext
        let managedContext = appDelegate.managedObjectContext!
        
        // Open a new fetch request
        let fetchRequest = NSFetchRequest(entityName:"Login")
        
        var error: NSError?
        
        // Execute the fetch from CoreData
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
                let base64LoginString = results[0].valueForKey("login") as! String
                
                if (base64LoginString != "") {
                    // Login information exists
                    
                    self.loginRequest(nil, base64LoginString: base64LoginString)
                } else {
                    // Login information does not exist
                    
                    let notification = NSNotification(name: "prepareLogin", object: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                }
            } else {
                // Login information does not exist
                
                let notification = NSNotification(name: "prepareLogin", object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
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
        
        let headerDict = ["x-tidepool-session-token":"\(x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            self.saveLogin("")
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                println("logout \(httpResponse.statusCode)")
                if (httpResponse.statusCode == 200) {
                    let notification = NSNotification(name: "prepareLogin", object: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                    
                    notesVC.dismissViewControllerAnimated(true, completion: {
                        self.user = nil
                        self.x_tidepool_session_token = ""
                    })
                } else {
                    println("an unknown error occurred")
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
            } else {
                println("an unknown error occurred")
                self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
            }
        }
        
        request("POST", urlExtension: "/auth/logout", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
    }
    
    func findProfile(otherUser: User) {
        
        let urlExtension = "/metadata/" + otherUser.userid + "/profile"
        
        let headerDict = ["x-tidepool-session-token":"\(x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to prepare
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                println("findProfile \(httpResponse.statusCode)")
                if (httpResponse.statusCode == 200) {
                    var userDict: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
                    
                    otherUser.processUserDict(userDict)
                    
                    // Send notification to NotesVC to handle new note that was just created
                    let notification = NSNotification(name: "anotherGroup", object: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                } else {
                    println("an unknown error occurred")
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
            } else {
                println("an unknown error occurred")
                self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
            }
        }
        
        request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
    }
    
    func getAllViewableUsers(notesVC: NotesViewController) {
        
        let urlExtension = "/access/groups/" + user!.userid
        
        let headerDict = ["x-tidepool-session-token":"\(x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // Nothing to do
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                println("getAllViewableUsers \(httpResponse.statusCode)")
                if (httpResponse.statusCode == 200) {
                    var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
                    
                    for key in jsonResult.keyEnumerator() {
                        let group = User(userid: key as! String, apiConnector: self)
                        notesVC.groups.insert(group, atIndex: 0)
                    }
                } else {
                    println("an unknown error occurred")
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
            } else {
                println("an unknown error occurred")
                self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
            }
        }
        
        request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
    }
    
    func getNotesForUserInDateRange(notesVC: NotesViewController, userid: String, start: NSDate, end: NSDate) {
        
        let dateFormatter = NSDateFormatter()
        let urlExtension = "/message/notes/" + userid + "?starttime=" + dateFormatter.isoStringFromDate(start, zone: nil) + "&endtime="  + dateFormatter.isoStringFromDate(end, zone: nil)
        
        let headerDict = ["x-tidepool-session-token":"\(x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            notesVC.loadingNotes = true
            notesVC.numberFetches++
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                println("getNotesForUserInDateRange \(httpResponse.statusCode)")
                
                if (httpResponse.statusCode == 200) {
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
                    notesVC.filterNotes()
                    notesVC.notesTable.reloadData()
                } else if (httpResponse.statusCode == 404) {
                    println("no notes in range \(httpResponse.statusCode), userid: \(userid)")
                } else {
                    println("an unknown error occurred \(httpResponse.statusCode)")
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
                
                notesVC.numberFetches--
                if (notesVC.numberFetches == 0) {
                    notesVC.loadingNotes = false
                }
            } else {
                println("an unknown error occurred")
                self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
            }
        }
        
        request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
    }
    
    func doPostWithNote(notesVC: NotesViewController, note: Note) {
        
        let urlExtension = "/message/send/" + note.groupid
        
        let headerDict = ["x-tidepool-session-token":"\(x_tidepool_session_token)", "Content-Type":"application/json"]
        
        let jsonObject = note.dictionaryFromNote()
        var err: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: &err)
        
        let preRequest = { () -> Void in
            // nothing to do in prerequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                println("doPostWithNote \(httpResponse.statusCode)")
                
                if (httpResponse.statusCode == 201) {
                    var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
                    
                    note.id = jsonResult.valueForKey("id") as! String
                    
                    notesVC.notes.insert(note, atIndex: 0)
                    // filter the notes, sort the notes, reload notes table
                    notesVC.filterNotes()
                    notesVC.notesTable.reloadData()
                    
                } else {
                    println("an unknown error occurred")
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
            } else {
                println("an unknown error occurred")
                self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
            }
        }
        
        request("POST", urlExtension: urlExtension, headerDict: headerDict, body: body, preRequest: preRequest, completion: completion)
    }
    
    func editNote(notesVC: NotesViewController, editedNote: Note, originalNote: Note) {
        
        let urlExtension = "/message/edit/" + originalNote.id
        
        let headerDict = ["x-tidepool-session-token":"\(x_tidepool_session_token)", "Content-Type":"application/json"]
        
        let jsonObject = editedNote.updatesFromNote()
        var err: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: &err)
        
        let preRequest = { () -> Void in
            // nothing to do in the preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                println("editNote \(httpResponse.statusCode)")
                if (httpResponse.statusCode == 200) {
                    
                    originalNote.messagetext = editedNote.messagetext
                    originalNote.timestamp = editedNote.timestamp
                    
                    // filter the notes, sort the notes, reload notes table
                    notesVC.filterNotes()
                    notesVC.notesTable.reloadData()
                } else {
                    println("an unknown error occurred")
                    self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
                }
            } else {
                println("an unknown error occurred")
                self.alertWithOkayButton(unknownError, message: unknownErrorMessage)
            }
        }
        
        request("PUT", urlExtension: urlExtension, headerDict: headerDict, body: body, preRequest: preRequest, completion: completion)
    }
    
    func alertWithOkayButton(title: String, message: String) {
        var unknownErrorAlert: UIAlertView = UIAlertView()
        unknownErrorAlert.title = title
        unknownErrorAlert.message = message
        unknownErrorAlert.addButtonWithTitle("Okay")
        unknownErrorAlert.show()
    }
}