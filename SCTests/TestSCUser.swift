//
//  TestSCUser.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest
@testable import SC

class TestSCUser: XCTestCase {
    
    private let username = "juggle"
    private let email = "ara@juggle.ru"
    private let password = "select"
    
    private let timeout = 3.0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
