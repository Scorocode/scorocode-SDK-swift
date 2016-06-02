//
//  TestSC.swift
//  SC
//
//  Created by Aleksandr Konakov on 18/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

class TestSC: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        SC.initWith(applicationId: "", clientId: "", accessKey: "", fileKey: "", messageKey: "")
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
