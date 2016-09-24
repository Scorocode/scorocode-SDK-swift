//
//  TestSCAPIRouter.swift
//  SC
//
//  Created by Aleksandr Konakov on 19/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
import Alamofire
@testable import SC

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
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.logout([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.register([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.insert([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.remove([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.update([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.updateById([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.find([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.count([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.upload([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.getFile("","","")
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.GET.rawValue)
        
        router = SCAPIRouter.getFileLink([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.sendEmail([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.sendPush([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.sendSms([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.scripts([:])
        XCTAssertEqual(router.URLRequest.httpMethod, Alamofire.Method.POST.rawValue)
    }
    
    
}
