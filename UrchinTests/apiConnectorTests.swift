/*
* Copyright (c) 2015, Tidepool Project
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the associated License, which is identical to the BSD 2-Clause
* License as published by the Open Source Initiative at opensource.org.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the License for more details.
*
* You should have received a copy of the License along with this program; if
* not, you can obtain one from Tidepool Project at tidepool.org.
*/

import XCTest

class apiConnectorTests: XCTestCase {
    
    // Initial API connection and note used throughout testing
    var apiConnector: APIConnector = APIConnector()
    let note: Note = Note()
    var userid: String = ""
    
    var email: String = "ethan+urchintests@tidepool.org"
    var pass: String = "urchintests"
    var server: String = "Development"
    
    override func setUp() {
        super.setUp()
        // Setup code. This method is called before the invocation of each test method in the class.
        // Each test method is a new session.
        apiConnector = APIConnector()
        baseURL = servers[server]!
    }
    
    override func tearDown() {
        // Teardown code. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testALoginFail() {
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        // Invalid password for a login request.
        let loginString = NSString(format: "%@:%@", email, "invalidpass")
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions([])
        
        let headerDict = ["Authorization":"Basic \(base64LoginString)"]
        
        let preRequest = { () -> Void in
            // Nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            // Parse the response.
            let jsonResult: NSDictionary = ((try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary)!
            let code = jsonResult.valueForKey("code") as! Int
            
            // Test for invalid login credentials code.
            XCTAssertEqual(code, 401, "Invalid login")
            // Fulfill the expectation so test passes time constraint.
            expectation.fulfill()
        }
        
        // Post the request.
        apiConnector.request("POST", urlExtension: "/auth/login", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testBLoginSuccess() {
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        // Valid password for a login request.
        let loginString = NSString(format: "%@:%@", email, "urchintests")
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions([])
        
        let headerDict = ["Authorization":"Basic \(base64LoginString)"]
        
        let preRequest = { () -> Void in
            // Nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Test for valid login credentials code.
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for login")
                
                // Store the session token for further use.
                self.apiConnector.x_tidepool_session_token = httpResponse.allHeaderFields["x-tidepool-session-token"] as! String
                
                let jsonResult: NSDictionary = ((try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary)!
                
                self.userid = jsonResult.valueForKey("userid") as! String
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Login request")
            }
        }
        
        // Post the request.
        apiConnector.request("POST", urlExtension: "/auth/login", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
    
        func testCLogout() {

            // First, perform login request and verify that login was successful.
            testBLoginSuccess()
            
            // Expectation to be fulfilled once request returns with correct response.
            let expectation = expectationWithDescription("Logout request")
            
            let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
    
            let preRequest = { () -> Void in
                // nothing to verify in preRequest
            }
    
            // To be completed once response has been received. Verify that the proper status code was received.
            let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if let httpResponse = response as? NSHTTPURLResponse {
                    // Test for valid logout code.
                    XCTAssertEqual(httpResponse.statusCode, 200, "Request for logout")
                    // Fulfill the expectation so test passes time constraint.
                    expectation.fulfill()
                } else {
                    XCTFail("Logout request")
                }
            }
    
            // Post the request.
            apiConnector.request("POST", urlExtension: "/auth/logout", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
    
            // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
            waitForExpectationsWithTimeout(5.0, handler: nil)
        }

    
    func testDFindProfile() {
        
        // First, perform login request and verify that login was successful.
        testBLoginSuccess()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Profile request")
        
        let urlExtension = "/metadata/" + userid + "/profile"
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Test for valid profile request code.
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for profile")
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Request for profile")
            }
        }
        
        // Post the request.
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testEGetViewableUsers() {

        // First, perform login request and verify that login was successful.
        testBLoginSuccess()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Viewable users request")
        
        let urlExtension = "/access/groups/" + userid
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Test for valid code.
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for viewable users")
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Request for viewable users")
            }
        }
        
        // Post the request.
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFGetNotesNoNotes() {
        
        // First, perform login request and verify that login was successful.
        testBLoginSuccess()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        // NSDateFormatter extension used to generate ISO-8601 date string for request url extension.
        // Time period in the early 1900s. I don't think I was posting notes to the Tidepool platform then ;)
        let dateFormatter = NSDateFormatter()
        let urlExtension = "/message/notes/" + userid + "?starttime=" + dateFormatter.isoStringFromDate(NSDate(timeIntervalSinceNow: -2208988800), zone: nil) + "&endtime="  + dateFormatter.isoStringFromDate(NSDate(timeIntervalSinceNow: -2207779200), zone: nil)
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]

        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Test for 404 code, meaning no notes were fetched.
                XCTAssertEqual(httpResponse.statusCode, 404, "Request for no notes")
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("No notes request")
            }
        }
        
        // Post the request.
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testGPostNote() {
        
        // First, perform login request and verify that login was successful.
        testBLoginSuccess()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        // Always sending a note to the group associated with ethan+urchintests@tidepool.org.
        let urlExtension = "/message/send/" + userid
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)", "Content-Type":"application/json"]
        
        // Configure the note with userid, groupid, timestamp (right now), and messagetext.
        note.userid = userid
        note.groupid = userid
        note.timestamp = NSDate()
        note.messagetext = "New note added from test."
        
        // Get the json output of the note configured above.
        let jsonObject = note.dictionaryFromNote()
        let body: NSData?
        do {
            body = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
        } catch {
            body = nil
        }
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Test for valid post code.
                XCTAssertEqual(httpResponse.statusCode, 201, "Request for posting a note")
                
                // Parse the response.
                let jsonResult: NSDictionary = ((try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary)!
                
                // Store the note's id that was returned in the response.
                self.note.id = jsonResult.valueForKey("id") as! String
                
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Post note request")
            }
        }
        
        // Post the request.
        apiConnector.request("POST", urlExtension: urlExtension, headerDict: headerDict, body: body, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testHEditNote() {
        
        // First, perform post request and verify that the post was successful.
        // Post request will perform login request and verify that it is also successful.
        testGPostNote()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        let urlExtension = "/message/edit/" + note.id
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)", "Content-Type":"application/json"]
        
        // Edit the note to be an hour earlier, and have a different messagetext.
        note.timestamp = NSDate(timeIntervalSinceNow: -3600)
        note.messagetext = "Edited note from test."
        
        // Get the json output for the edited notes.
        let jsonObject = note.updatesFromNote()
        let body: NSData?
        do {
            body = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
        } catch {
            body = nil
        }
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Verify that editing the note was successful.
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for edit note")
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Edit note request")
            }
        }
        
        // Post the request.
        apiConnector.request("PUT", urlExtension: urlExtension, headerDict: headerDict, body: body, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testIGetNotes() {
        
        // First, perform login request and verify that login was successful.
        testBLoginSuccess()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        // Fetch all notes. There will always already be a note posted because the post test occurs before this test.
        let urlExtension = "/message/notes/" + userid + "?starttime=" + "&endtime="
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Verify that notes were received in the request.
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for notes")
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Notes request")
            }
        }
        
        // Post the request.
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testJDeleteNote() {
        
        // First, perform post request and verify that the post was successful.
        // Post request will perform login request and verify that it is also successful.
        testGPostNote()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        let urlExtension = "/message/remove/" + note.id
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Verify that editing the note was successful.
                XCTAssertEqual(httpResponse.statusCode, 202, "Request for delete note")
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Delete note request")
            }
        }
        
        // Post the request.
        apiConnector.request("DELETE", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
    }
    
    func testKRefreshToken() {
        
        testBLoginSuccess()
        
        // Expectation to be fulfilled once request returns with correct response.
        let expectation = expectationWithDescription("Asynchronous request")
        
        let urlExtension = "/auth/login"
        
        let headerDict = ["x-tidepool-session-token":"\(apiConnector.x_tidepool_session_token)"]
        
        let preRequest = { () -> Void in
            // nothing to verify in preRequest
        }
        
        // To be completed once response has been received. Verify that the proper status code was received.
        let completion = { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                // Verify that editing the note was successful.
                XCTAssertEqual(httpResponse.statusCode, 200, "Request for session token refresh")
                
                // Store the session token for further use.
                self.apiConnector.x_tidepool_session_token = httpResponse.allHeaderFields["x-tidepool-session-token"] as! String
                
                let jsonResult: NSDictionary = ((try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary)!
                
                self.userid = jsonResult.valueForKey("userid") as! String
                
                // Fulfill the expectation so test passes time constraint.
                expectation.fulfill()
            } else {
                XCTFail("Refresh token request")
            }
        }
        
        // Post the request.
        apiConnector.request("GET", urlExtension: urlExtension, headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
    }
    
    func testKOnStaging() {
        
        email = "ethan+urchintests@tidepool.org"
        pass = "urchintests"
        server = "Staging"
        
        testALoginFail()
        testBLoginSuccess()
        testCLogout()
        testDFindProfile()
        testEGetViewableUsers()
        testFGetNotesNoNotes()
        testGPostNote()
        testHEditNote()
        testIGetNotes()
        testJDeleteNote()
        testKRefreshToken()
        
    }
    
    func testLOnProd() {
        
        email = "ethan+urchintests@tidepool.org"
        pass = "urchintests"
        server = "Production"
        
        testALoginFail()
        testBLoginSuccess()
        testCLogout()
        testDFindProfile()
        testEGetViewableUsers()
        testFGetNotesNoNotes()
        testGPostNote()
        testHEditNote()
        testIGetNotes()
        testJDeleteNote()
        testKRefreshToken()
        
    }
}
