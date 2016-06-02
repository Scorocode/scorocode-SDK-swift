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
        
        var router = SCAPIRouter.Login([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Logout([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Register([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Insert([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Remove([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Update([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.UpdateById([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Find([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Count([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Upload([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.GetFile("","","")
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.GET.rawValue)
        
        router = SCAPIRouter.GetFileLink([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.SendEmail([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.SendPush([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.SendSms([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
        
        router = SCAPIRouter.Scripts([:])
        XCTAssertEqual(router.URLRequest.HTTPMethod, Alamofire.Method.POST.rawValue)
    }
    
    
}
