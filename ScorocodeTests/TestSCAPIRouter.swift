//
//  TestSCAPIRouter.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest
import Alamofire

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
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.logout([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.register([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.insert([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.remove([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.update([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.updateById([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.find([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.count([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.upload([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.getFile("","","")
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.get.rawValue)
        
        router = SCAPIRouter.getFileLink([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.sendEmail([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.sendPush([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.sendSms([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
        
        router = SCAPIRouter.scripts([:])
        XCTAssertEqual(router.urlRequest?.httpMethod, Alamofire.HTTPMethod.post.rawValue)
    }
    
    
}
