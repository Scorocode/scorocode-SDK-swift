//
//  TestSCValue.swift
//  SC
//
//  Created by Aleksandr Konakov on 16/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
import Foundation
@testable import SC

class TestSCValue: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSCBool() {
        let scBool = SCBool(true)
        XCTAssert((scBool.apiValue as! Bool) == true)
    }
    
    func testSCString() {
        let scString = SCString("AbCdE")
        XCTAssert((scString.apiValue as! String) == "AbCdE")
    }
    
    func testSCInt() {
        let scInt = SCInt(5)
        XCTAssert((scInt.apiValue as! Int) == 5)
    }
    
    func testSCDouble() {
        let scDouble = SCDouble(3.1415926)
        XCTAssert((scDouble.apiValue as! Double) == 3.1415926)
    }
    
    func testSCDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let scDate = SCDate(dateFormatter.date(from: "2016-05-31")!)
        XCTAssert((scDate.apiValue as! String) == "2016-05-30T21:00:00Z")
    }
    
    func testSCArray() {
        let v1 = SCString("AB")
        let v2 = SCString("CD")
        let arr = SCArray([v1, v2])
        XCTAssert(arr.apiValue as! NSObject == ["AB", "CD"])
    }
    
    func testSCDictionary() {
        let dic = SCDictionary(["key1": SCString("AB"), "key2": SCBool(false)])
        XCTAssert(dic.apiValue as! NSObject == ["key1": "AB", "key2": false])
    }
    
    func testEqualBool() {
        let v1 = SCBool(true)
        let v2 = SCBool(true)
        let v3 = SCBool(false)
        
        XCTAssertEqual(true, v1 == v2)
        XCTAssertNotEqual(true, v1 == v3)
    }
    
    func testEqualString() {
        let v1 = SCString("A")
        let v2 = SCString("A")
        let v3 = SCString("B")
        
        XCTAssertEqual(true, v1 == v2)
        XCTAssertNotEqual(true, v1 == v3)
    }
    
    func testEqualInt() {
        let v1 = SCInt(1)
        let v2 = SCInt(1)
        let v3 = SCInt(2)
        
        XCTAssertEqual(true, v1 == v2)
        XCTAssertNotEqual(true, v1 == v3)
    }
    
    func testEqualDouble() {
        let v1 = SCDouble(1.23)
        let v2 = SCDouble(1.23)
        let v3 = SCDouble(4.56)
        
        XCTAssertEqual(true, v1 == v2)
        XCTAssertNotEqual(true, v1 == v3)
    }
    
    func testEqualDate() {
        let now = Date()
        let v1 = SCDate(now)
        let v2 = SCDate(now)
        let v3 = SCDate(now.addingTimeInterval(1))
        
        XCTAssertEqual(true, v1 == v2)
        XCTAssertNotEqual(true, v1 == v3)
    }
    
    func testNotEqual() {
        let v1 = SCString("A")
        let v2 = SCInt(5)
        
        XCTAssertNotEqual(true, v1 == v2)
    }
    
    func testEqualArray() {
        let v1 = SCArray([SCString("A"), SCString("B")])
        let v2 = SCArray([SCString("A"), SCString("B")])
        
        XCTAssertEqual(true, v1 == v2)
    }
    
    func testNotEqualArray() {
        let v1 = SCArray([SCString("A"), SCString("B"), SCString("C")])
        let v2 = SCArray([SCString("A"), SCString("B")])
        
        XCTAssertEqual(false, v1 == v2)
        
        let v3 = SCArray([SCString("A"), SCString("C")])
        let v4 = SCArray([SCString("A"), SCString("B")])
        
        XCTAssertEqual(false, v3 == v4)
    }
    
    func testEqualDictionary() {
        let v1 = SCDictionary(["key1" : SCString("A"), "key2" : SCString("B")])
        let v2 = SCDictionary(["key1" : SCString("A"), "key2" : SCString("B")])
        
        XCTAssertEqual(true, v1 == v2)
    }
    
    func testNotEqualDictionary() {
        let v1 = SCDictionary(["key1" : SCString("A"), "key2" : SCString("B")])
        let v2 = SCDictionary(["key1" : SCString("A")])
        
        XCTAssertEqual(false, v1 == v2)
        
        let v3 = SCDictionary(["key1" : SCString("A"), "key2" : SCString("B")])
        let v4 = SCDictionary(["key1" : SCString("A"), "key2" : SCString("C")])
        
        XCTAssertEqual(false, v3 == v4)
    }
}
