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
    private let password = "alexey"
    
    private let timeout = 5.0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let applicationId = "cd02126a02e44643ba38c923cf699bb7"
        let clientId = "900ca6a05f604eb8a88aac6941efcaa4"
        let accessKey = "32e4b1c15e7d470dbbacab57fa6e8406"
        let fileKey = "98bd371cdca944bcbebd45eb13fa17b6"
        let messageKey = "171f8ac1fa6f4ed8b3ec623739b2ad04"

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
            
            user.logout() {
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
