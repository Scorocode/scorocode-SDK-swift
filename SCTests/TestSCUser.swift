//
//  TestSCUser.swift
//  SC
//
//  Created by Aleksandr Konakov on 20/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
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
        
        let expectation = expectationWithDescription("Login")
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["sessionId"])
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testLogout() {
        
        let expectation = expectationWithDescription("Logout")
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["sessionId"])
            
            SCUser.logout() {
                success, error in
                
                XCTAssertTrue(success)
                XCTAssertNil(error)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testSignup() {
        
        let expectation = expectationWithDescription("Signup")
        
        let user = SCUser()
        user.signup(username, email: "\(NSUUID().UUIDString)@domain.ru", password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["_id"])
            
            user.data["username"] = self.username
            user.data["password"] = self.password
            user.data["email"] = "\(NSUUID().UUIDString)@domain.ru"
            
            user.signup() {
                success, error, result in
                assertSuccess(success, error, result)
                XCTAssertNotNil(result!["_id"])
                
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
}
