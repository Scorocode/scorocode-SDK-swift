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
    
    fileprivate let username = "juggle"
    fileprivate let email = "ara@juggle.ru"
    fileprivate let password = "select"
    
    fileprivate let timeout = 3.0
    
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
        
        let expectation = self.expectation(description: "Login")
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["sessionId"])
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testLogout() {
        
        let expectation = self.expectation(description: "Logout")
        
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
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSignup() {
        
        let expectation = self.expectation(description: "Signup")
        
        let user = SCUser()
        user.signup(username, email: "\(UUID().uuidString)@domain.ru", password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["_id"])
            
            user.data["username"] = self.username
            user.data["password"] = self.password
            user.data["email"] = "\(UUID().uuidString)@domain.ru"
            
            user.signup() {
                success, error, result in
                assertSuccess(success, error, result)
                XCTAssertNotNil(result!["_id"])
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
