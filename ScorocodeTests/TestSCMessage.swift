//
//  TestSCMessage.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest

class TestSCMessage: XCTestCase {
    
    private let timeout = 3.0
    
    let applicationId = "98bc4bacb5edea727cfb8fae25f71b59"
    let clientId = "39169707deb69fc061c5c995aa4cdefe"
    let accessKey = "61ad813bd71bd4f05aea53a3c996d53a"
    let fileKey = "351cb3d71efef69e346ac5657dd16c1c"
    let messageKey = "35d5a173e0391ae83d60a6a756a44051"
    
    override func setUp() {
        super.setUp()
        SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSendPush() {
        
        let exp = expectation(description: "SendPush")
        
        let query = SCQuery(collection: "devices")
        SCMessage.sendPush(query, title: "title", text: "Mesage text", debug: false) {
            success, error, result in
            assertSuccess(success: success, error: error, result: result)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSendSms() {
        
        let exp = expectation(description: "SendSms")
        
        let query = SCQuery(collection: "users")
        SCMessage.sendSms(query, text: "Mesage text") {
            success, error, result in
            assertSuccess(success: success, error: error, result: result)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
