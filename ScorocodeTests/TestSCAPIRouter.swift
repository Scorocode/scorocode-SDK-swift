//
//  TestSCAPIRouter.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest

class TestSCAPIRouter: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testURLRequestMethod() {
        
        var router = SCAPIRouter.login([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.logout([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.register([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.insert([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.remove([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.update([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.updateById([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.find([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.count([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.upload([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.sendPush([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.sendSms([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
        
        router = SCAPIRouter.scripts([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, "POST")
    }
    
    
}
