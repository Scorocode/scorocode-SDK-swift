//
//  TestSC.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest

class TestSC: XCTestCase {
    
    override func setUp() {
        super.setUp()
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
        
        XCTAssertEqual(SCAPI.sharedInstance.applicationId, "")
        XCTAssertEqual(SCAPI.sharedInstance.clientId, "")
        XCTAssertEqual(SCAPI.sharedInstance.accessKey, "")
        XCTAssertEqual(SCAPI.sharedInstance.fileKey, "")
        XCTAssertEqual(SCAPI.sharedInstance.messageKey, "")
        
        SC.initWith(applicationId: "aaaa", clientId: "bbbb", accessKey: "cccc", fileKey: "dddd", messageKey: "eeee")
        
        XCTAssertEqual(SCAPI.sharedInstance.applicationId, "aaaa")
        XCTAssertEqual(SCAPI.sharedInstance.clientId, "bbbb")
        XCTAssertEqual(SCAPI.sharedInstance.accessKey, "cccc")
        XCTAssertEqual(SCAPI.sharedInstance.fileKey, "dddd")
        XCTAssertEqual(SCAPI.sharedInstance.messageKey, "eeee")
        
    }
}
