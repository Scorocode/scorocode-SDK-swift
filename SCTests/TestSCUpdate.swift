//
//  TestUpdate.swift
//  SC
//
//  Created by Aleksandr Konakov on 18/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

class TestSCUpdate: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testOperators() {
        
        var update = SCUpdate()
        let op1 = SCUpdateOperator.push(name: "fieldName1", value: SCString("A"), each: false)
        update.addOperator(op1)
        let op2 = SCUpdateOperator.push(name: "fieldName2", value: SCString("b"), each: true)
        update.addOperator(op2)
        XCTAssertEqual(update.operators, [op1, op2])
    }
    
    func testAddOperator() {
        
        var update = SCUpdate()
        let op1 = SCUpdateOperator.push(name: "fieldName1", value: SCString("A"), each: false)
        update.addOperator(op1)
        XCTAssertEqual(update.operators.last!, op1)
    }
    
    func testSet() {
        var update = SCUpdate()
        update.set(["fieldName": SCString("A")])
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.set(["fieldName": SCString("A")]))
    }
    
    func testPush() {
        var update = SCUpdate()
        update.push("fieldName", SCString("A"))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.push(name: "fieldName", value: SCString("A"), each: false))
    }
    
    func testPushEach() {
        var update = SCUpdate()
        
        update.pushEach("fieldName", SCString("A"))
        XCTAssertEqual(update.operators, [SCUpdateOperator]())
        
        update.pushEach("fieldName", SCArray([SCString("A")]))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.push(name: "fieldName", value: SCArray([SCString("A")]), each: true))
    }
    
    // TODO: Pull
    func testPull() {
        var update = SCUpdate()
        
        update.pull("fieldName", SCString("A"))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.pull("fieldName", SCString("A")))
    }
    
    func testPullAll() {
        var update = SCUpdate()
        
        update.pullAll("fieldName", SCString("A"))
        XCTAssertEqual(update.operators, [SCUpdateOperator]())
        
        update.pullAll("fieldName", SCArray([SCString("A")]))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.pullAll("fieldName", SCArray([SCString("A")])))
    }
    
    func testAddToSet() {
        var update = SCUpdate()
        update.addToSet("fieldName", SCString("A"))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.addToSet(name: "fieldName", value: SCString("A"), each: false))
    }
    
    func testAddToSetEach() {
        var update = SCUpdate()
        update.addToSetEach("fieldName", SCString("A"))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.addToSet(name: "fieldName", value: SCString("A"), each: true))
    }
    
    func testPop() {
        var update = SCUpdate()
        
        update.pop("fieldName", 0)
        XCTAssertEqual(update.operators, [SCUpdateOperator]())
        
        update.pop("fieldName", 1)
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.pop("fieldName", 1))
    }
    
    func testInc() {
        var update = SCUpdate()
        
        update.inc("fieldName", SCString("A"))
        XCTAssertEqual(update.operators, [SCUpdateOperator]())
        
        update.inc("fieldName", SCInt(1))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.inc("fieldName", SCInt(1)))
    }
    
    func testCurrentDate() {
        var update = SCUpdate()
        
        update.currentDate("fieldName", typeSpec: "wrong")
        XCTAssertEqual(update.operators, [SCUpdateOperator]())
        
        update.currentDate("fieldName", typeSpec: "date")
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.currentDate("fieldName", "date"))
    }
    
    func testMul() {
        var update = SCUpdate()
        
        update.mul("fieldName", SCString("A"))
        XCTAssertEqual(update.operators, [SCUpdateOperator]())
        
        update.mul("fieldName", SCInt(5))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.mul("fieldName", SCInt(5)))
    }
    
    func testMin() {
        var update = SCUpdate()
        
        update.min("fieldName", SCInt(5))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.min("fieldName", SCInt(5)))
    }
    
    func testMax() {
        var update = SCUpdate()
        
        update.max("fieldName", SCInt(5))
        XCTAssertEqual(update.operators.last!, SCUpdateOperator.max("fieldName", SCInt(5)))
    }
    
    
    
    
}
