//
//  TestSCUpdateOperator.swift
//  SC
//
//  Created by Aleksandr Konakov on 16/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

class TestSCUpdateOperator: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testName() {
        let set = SCUpdateOperator.set(["fieldName": SCString("ABCD")])
        XCTAssertEqual(set.name, "$set")
        
        let push = SCUpdateOperator.push(name: "fieldName", value: SCString("A"), each: false)
        XCTAssertEqual(push.name, "$push")
        
        let pull = SCUpdateOperator.pull("fieldName", SCString("A"))
        XCTAssertEqual(pull.name, "$pull")
        
        let pullAll = SCUpdateOperator.pullAll("fieldName", SCString("A"))
        XCTAssertEqual(pullAll.name, "$pullAll")
        
        let addToSet = SCUpdateOperator.addToSet(name: "fieldName", value: SCString("A"), each: false)
        XCTAssertEqual(addToSet.name, "$addToSet")
        
        let pop = SCUpdateOperator.pop("fieldName", 1)
        XCTAssertEqual(pop.name, "$pop")
        
        let inc = SCUpdateOperator.inc("fieldName", SCInt(5))
        XCTAssertEqual(inc.name, "$inc")
        
        let currentDate = SCUpdateOperator.currentDate("fieldName", "timestamp")
        XCTAssertEqual(currentDate.name, "$currentDate")
        
        let mul = SCUpdateOperator.mul("fieldName", SCInt(5))
        XCTAssertEqual(mul.name, "$mul")
        
        let min = SCUpdateOperator.min("fieldName", SCInt(5))
        XCTAssertEqual(min.name, "$min")
        
        let max = SCUpdateOperator.max("fieldName", SCInt(5))
        XCTAssertEqual(max.name, "$max")
    }
    
    func testDic() {
        
        let set = SCUpdateOperator.set(["fieldName": SCString("ABCD")])
        XCTAssertEqual(set.dic as! [String : String], ["fieldName" : "ABCD"])
        
        let push = SCUpdateOperator.push(name: "fieldName", value: SCString("A"), each: false)
        XCTAssertEqual(push.dic as! [String : String], ["fieldName" : "A"])
        
        let pushEach = SCUpdateOperator.push(name: "fieldName", value: SCString("A"), each: true)
        XCTAssertEqual(pushEach.dic as! [String : [String : String]], ["fieldName" : ["$each" : "A"]])
        
        
        let pullValue = SCUpdateOperator.pull("fieldName", SCString("A"))
        XCTAssertEqual(pullValue.dic as! [String: String], ["fieldName" : "A"])
        
        let pullCondition = SCUpdateOperator.pull("fieldName", SCOperator.notEqualTo("fieldName", SCString("A")))
        XCTAssertEqual(pullCondition.dic as! [String: [String: String]], ["fieldName": ["$ne" : "A"]])
        
        
        let pullAll = SCUpdateOperator.pullAll("fieldName", SCString("A"))
        XCTAssertEqual(pullAll.dic as! [String: String], ["fieldName" : "A"])
        
        let addToSet = SCUpdateOperator.addToSet(name: "fieldName", value: SCString("A"), each: false)
        XCTAssertEqual(addToSet.dic as! [String: String], ["fieldName" : "A"])
        
        let addToSetEach = SCUpdateOperator.addToSet(name: "fieldName", value: SCString("A"), each: true)
        XCTAssertEqual(addToSetEach.dic as! [String: [String: String]], ["fieldName" : ["$each": "A"]])

        let pop = SCUpdateOperator.pop("fieldName", 1)
        XCTAssertEqual(pop.dic as! [String: Int], ["fieldName" : 1])
        
        let inc = SCUpdateOperator.inc("fieldName", SCInt(5))
        XCTAssertEqual(inc.dic as! [String: Int], ["fieldName" : 5])
        
        let currentDate = SCUpdateOperator.currentDate("fieldName", "timestamp")
        XCTAssertEqual(currentDate.dic as! [String: [String: String]], ["fieldName" : ["$type" : "timestamp"]])
        
        let mul = SCUpdateOperator.mul("fieldName", SCInt(5))
        XCTAssertEqual(mul.dic as! [String: Int], ["fieldName" : 5])

        let min = SCUpdateOperator.min("fieldName", SCInt(5))
        XCTAssertEqual(min.dic as! [String: Int], ["fieldName" : 5])
        
        let max = SCUpdateOperator.max("fieldName", SCInt(5))
        XCTAssertEqual(max.dic as! [String: Int], ["fieldName" : 5])
        
    }
    
    func testNotEqual() {
        let push = SCUpdateOperator.push(name: "fieldName", value: SCString("A"), each: false)
        let pop = SCUpdateOperator.pop("fieldName", 1)
        
        XCTAssertEqual(false, push == pop)
    }
}
