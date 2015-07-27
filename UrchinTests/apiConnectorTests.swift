//
//  apiConnectorTests.swift
//  urchin
//
//  Created by Ethan Look on 7/24/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import XCTest

class apiConnectorTests: XCTestCase {
    
    var apiConnector: APIConnector = APIConnector()
    let note: Note = Note()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        apiConnector = APIConnector()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoginFail() {
        let expectation = expectationWithDescription("Asynchronous request")
        
        let loginString = NSString(format: "%@:%@", "ethan+urchintests@tidepool.org", "invalidpass")
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        
        let headerDict = ["Authorization":"Basic \(base64LoginString)"]
        
        let preRequest = { () -> Void in
            // Nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
            let code = jsonResult.valueForKey("code") as! Int
            
            XCTAssertEqual(code, 401, "Invalid login")
            expectation.fulfill()
        }
        
        apiConnector.request("POST", urlExtension: "/auth/login", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testLoginSuccess() {
        let expectation = expectationWithDescription("Asynchronous request")
        
        let loginString = NSString(format: "%@:%@", "ethan+urchintests@tidepool.org", "urchintests")
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        
        let headerDict = ["Authorization":"Basic \(base64LoginString)"]
        
        let preRequest = { () -> Void in
            // Nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for login")
                
                self.apiConnector.x_tidepool_session_token = httpResponse.allHeaderFields["x-tidepool-session-token"] as! String
                expectation.fulfill()
            } else {
                XCTFail("Login request")
            }
        }
        
        apiConnector.request("POST", urlExtension: "/auth/login", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
    
        func testLogout() {

            testLoginSuccess()
            
            let expectationTwo = expectationWithDescription("Logout request")
            
            let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
    
            let preRequest = { () -> Void in
                // nothing to verify in preRequest
            }
    
            let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if let httpResponse = response as? NSHTTPURLResponse {
                    XCTAssertEqual(httpResponse.statusCode, 200, "Request for logout")
                    expectationTwo.fulfill()
                } else {
                    XCTFail("Logout request")
                }
            }
    
            apiConnector.request("POST", urlExtension: "/auth/logout", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
    
            waitForExpectationsWithTimeout(5.0, handler: nil)
        }

    
    func testFindProfile() {
        
        testLoginSuccess()
        
        let expectationTwo = expectationWithDescription("Profile request")
        
        let urlExtension = "/metadata/" + "218ab599e9" + "/profile"
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for profile")
                expectationTwo.fulfill()
            } else {
                XCTFail("Request for profile")
            }
        }
        
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testGetViewableUsers() {
        testLoginSuccess()
        
        let expectationTwo = expectationWithDescription("Viewable users request")
        
        let urlExtension = "/access/groups/" + "218ab599e9"
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for viewable users")
                expectationTwo.fulfill()
            } else {
                XCTFail("Request for viewable users")
            }
        }
        
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testGetNotesNoNotes() {
        
        testLoginSuccess()
        
        let expectationTwo = expectationWithDescription("Asynchronous request")
        
        let dateFormatter = NSDateFormatter()
        let urlExtension = "/message/notes/" + "218ab599e9" + "?starttime=" + dateFormatter.isoStringFromDate(NSDate(timeIntervalSinceNow: -2208988800), zone: nil) + "&endtime="  + dateFormatter.isoStringFromDate(NSDate(timeIntervalSinceNow: -2207779200), zone: nil)
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]

        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 404, "Request for no notes")
                expectationTwo.fulfill()
            } else {
                XCTFail("No notes request")
            }
        }
        
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testPostNote() {
        
        testLoginSuccess()
        
        let expectationTwo = expectationWithDescription("Asynchronous request")
        
        let urlExtension = "/message/send/" + "218ab599e9"
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)", "Content-Type":"application/json"]
        
        note.userid = "218ab599e9"
        note.groupid = "218ab599e9"
        note.timestamp = NSDate()
        note.messagetext = "New note added from test."
        
        let jsonObject = note.dictionaryFromNote()
        var err: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: &err)
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 201, "Request for posting a note")
                var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary)!
                
                self.note.id = jsonResult.valueForKey("id") as! String
                expectationTwo.fulfill()
            } else {
                XCTFail("Post note request")
            }
        }
        
        apiConnector.request("POST", urlExtension: urlExtension, headerDict: headerDict, body: body, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testEditNote() {
        
        testPostNote()
        
        let expectationThree = expectationWithDescription("Asynchronous request")
        
        let urlExtension = "/message/edit/" + note.id
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)", "Content-Type":"application/json"]
        
        note.timestamp = NSDate(timeIntervalSinceNow: -3600)
        note.messagetext = "Edited note from test."
        
        let jsonObject = note.updatesFromNote()
        var err: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: &err)
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for edit note")
                expectationThree.fulfill()
            } else {
                XCTFail("Edit note request")
            }
        }
        
        apiConnector.request("PUT", urlExtension: urlExtension, headerDict: headerDict, body: body, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testGetNotes() {
        
        testLoginSuccess()
        
        let expectationTwo = expectationWithDescription("Asynchronous request")
        
        let dateFormatter = NSDateFormatter()
        let urlExtension = "/message/notes/" + "218ab599e9" + "?starttime=" + "&endtime="
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for notes")
                expectationTwo.fulfill()
            } else {
                XCTFail("Notes request")
            }
        }
        
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
