//
//  apiConnectorTests.swift
//  urchin
//
//  Created by Ethan Look on 7/24/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import XCTest

class apiConnectorTests: XCTestCase {

    let apiConnector = APIConnector()
    let baseURL = "https://devel-api.tidepool.io"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        apiConnector.baseURL = baseURL
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
                XCTAssertEqual(httpResponse.statusCode, 200, "Successful login")
                expectation.fulfill()
            }
        }
        
        apiConnector.request("POST", urlExtension: "/auth/login", headerDict: headerDict, body: nil, preRequest: preRequest, completion: completion)
        
        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
    
    

}
