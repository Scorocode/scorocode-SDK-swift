//
//  TestSCUser.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest

class TestSCUser: XCTestCase {
    
    private let username = "alexey"
    private let email = "alexey@company.com"
    private let password = "TestUser1"
    
    private let timeout = 5.0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let applicationId = "98bc4bacb5edea727cfb8fae25f71b59"
        let clientId = "39169707deb69fc061c5c995aa4cdefe"
        let accessKey = "61ad813bd71bd4f05aea53a3c996d53a"
        let fileKey = "351cb3d71efef69e346ac5657dd16c1c"
        let messageKey = "35d5a173e0391ae83d60a6a756a44051"
        SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        
        let user = SCUser()
        
        XCTAssertEqual(user.collection, "users")
        XCTAssertNil(user.id)
    }
    
    func testLogin() {
        
        let exp = expectation(description: "Login")
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            XCTAssertNotNil(result!["sessionId"])
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testLogout() {
        
        let exp = expectation(description: "Logout")
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            XCTAssertNotNil(result!["sessionId"])
            
            SCUser.logout() {
                success, error in
                
                XCTAssertTrue(success)
                XCTAssertNil(error)
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSignup() {
        
        let exp = expectation(description: "Signup")
        
        let user = SCUser()
        user.signup(username, email: "\(NSUUID().uuidString)@domain.ru", password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            XCTAssertNotNil(result!["_id"])
            
            user.data["username"] = self.username
            user.data["password"] = self.password
            user.data["email"] = "\(NSUUID().uuidString)@domain.ru"
            
            user.signup() {
                success, error, result in
                assertSuccess(success: success, error: error, result: result)
                XCTAssertNotNil(result!["_id"])
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
