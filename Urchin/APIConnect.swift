//
//  APIConnect.swift
//  urchin
//
//  Created by Ethan Look on 7/16/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import Foundation

class APIConnector {
    
    var x_tidepool_session_token: String = ""
    var user: User?
    
    func login(username: String, password: String) {
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        
        // create the request
        let url = NSURL(string: "https://api.tidepool.io/auth/login")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        var response: NSURLResponse?
        var error: NSError?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary)!
        if (error == nil) {
            if let httpResponse = response as? NSHTTPURLResponse {
                if let sessionToken = httpResponse.allHeaderFields["x-tidepool-session-token"] as? String {
                    self.x_tidepool_session_token = sessionToken
                    user = User(userid: jsonResult.valueForKey("userid") as! String, apiConnector: self)
                }
            }
        } else {
            return
        }
    }
    
    func logout() {
        // /auth/logout
        
        // create the request
        let url = NSURL(string: "https://api.tidepool.io/auth/logout")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        var response: NSURLResponse?
        var error: NSError?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
        }
        
        self.user = nil
        self.x_tidepool_session_token = ""
    }
    
    func findProfile(userid: String) -> NSDictionary {
        // '/metadata/' + userId + '/profile'
        
        let url = NSURL(string: "https://api.tidepool.io/metadata/\(userid)/profile")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        var response: NSURLResponse?
        var error: NSError?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary)!
        if (error == nil) {
            return jsonResult
        } else {
            return NSDictionary()
        }
    }
    
    func getAllViewableUsers() -> [String] {
        // '/access/groups/' + userId
        
        let url = NSURL(string: "https://api.tidepool.io/access/groups/\(user!.userid)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        var response: NSURLResponse?
        var error: NSError?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary)!
        if (error == nil) {
            
            var groupids: [String] = []
            for key in jsonResult.keyEnumerator() {
                groupids.append(key as! String)
            }
            return groupids
        } else {
            return []
        }
    }
    
    func getAllMessagesForUser(userid: String) -> [Note] {
        // '/message/all/' + userId + '?starttime=' + start + '&endtime=' + end
        
        // create the request
        let url = NSURL(string: "https://api.tidepool.io/message/all/\(userid)?starttime=&endtime=")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("\(x_tidepool_session_token)", forHTTPHeaderField: "x-tidepool-session-token")
        
        var response: NSURLResponse?
        var error: NSError?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary)!
        if (error == nil) {
            
            var notes: [Note] = []
            var messages: NSArray = jsonResult.valueForKey("messages") as! NSArray
            for message in messages {
                println(message)
                
                let id = message.valueForKey("id") as! String
                let otheruserid = message.valueForKey("userid") as! String
                let groupid = message.valueForKey("groupid") as! String
                let timestamp = dateFromISOString(message.valueForKey("timestamp") as! String)
                var createdtime: NSDate
                if let created = message.valueForKey("createdtime") as? String {
                    createdtime = dateFromISOString(created)
                } else {
                    createdtime = timestamp
                }
                let messagetext = message.valueForKey("messagetext") as! String
                let otheruser = User(userid: otheruserid, apiConnector: self)
                
                let note = Note(id: id, userid: otheruserid, groupid: groupid, timestamp: timestamp, createdtime: createdtime, messagetext: messagetext, user: otheruser)
                notes.append(note)
            }
            
            return notes
        } else {
            return []
        }
    }
    
    func dateFromISOString(string: String) -> NSDate {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = dateFormatter.dateFromString(string) {
            return date
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return dateFormatter.dateFromString(string)!
        }
    }
    
}