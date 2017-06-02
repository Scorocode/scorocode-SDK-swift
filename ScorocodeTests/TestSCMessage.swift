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
    
    let applicationId = "cd02126a02e44643ba38c923cf699bb7"
    let clientId = "900ca6a05f604eb8a88aac6941efcaa4"
    let accessKey = "32e4b1c15e7d470dbbacab57fa6e8406"
    let fileKey = "98bd371cdca944bcbebd45eb13fa17b6"
    let messageKey = "171f8ac1fa6f4ed8b3ec623739b2ad04"
    
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
