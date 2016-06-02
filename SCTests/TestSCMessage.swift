//
//  TestSCMessage.swift
//  SC
//
//  Created by Aleksandr Konakov on 20/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

class TestSCMessage: XCTestCase {
    
    private let timeout = 3.0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSendEmail() {
        
        let expectation = expectationWithDescription("SendEmail")
        
        let query = SCQuery(collection: "users")
        SCMessage.sendEmail(query, subject: "Subject", text: "Mesage text") {
            success, error, result in
            assertSuccess(success, error, result)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testSendPush() {
        
        let expectation = expectationWithDescription("SendPush")
        
        let query = SCQuery(collection: "devices")
        SCMessage.sendPush(query, subject: "Subject", text: "Mesage text") {
            success, error, result in
            assertSuccess(success, error, result)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testSendSms() {
        
        let expectation = expectationWithDescription("SendSms")
        
        let query = SCQuery(collection: "users")
        SCMessage.sendSms(query, subject: "Subject", text: "Mesage text") {
            success, error, result in
            assertSuccess(success, error, result)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
}
