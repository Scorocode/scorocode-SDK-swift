//
//  TestSCQuery.swift
//  SC
//
//  Created by Aleksandr Konakov on 18/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

class TestSCQuery: XCTestCase {
    
    var query: SCQuery!
    
    let fieldName = "fieldName"
    let scString = SCString("A")
    let scInt = SCInt(5)
    let scArray = SCArray([SCString("A"), SCString("B")])
    
    
    override func setUp() {
        super.setUp()
        
        query = SCQuery(collection: "testcoll")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testCollection() {
        XCTAssertEqual(query.collection, "testcoll")
    }
    
    func testUserQuery() {
        
        XCTAssertNil(query.userQuery)
        
        query.raw("{ \"fieldString\" : \"Строка\" }")
        XCTAssertEqual(query.userQuery! as! [String: String], ["fieldString" : "Строка"])
    }
        
    func testLimit() {
        XCTAssertNil(query.limit)
        
        query.limit(5)
        XCTAssertEqual(query.limit, 5)
    }
    
    func testSkip() {
        XCTAssertNil(query.skip)
        
        query.skip(10)
        XCTAssertEqual(query.skip, 10)
    }
    
    func testFields() {
        XCTAssertNil(query.fields)
        
        query.fields(["field1", "field2"])
        XCTAssertEqual(query.fields!, ["field1", "field2"])
    }
    
    func testAddOperator() {
        XCTAssertNil(query.operators)
        let op = SCOperator.equalTo(fieldName, scString)
        query.addOperator(fieldName, oper: op)
        XCTAssertTrue(query.operators![fieldName]! == op)
    }
    
    
    func testSort() {
        XCTAssertNil(query.sort)
        
        query.ascending("field1")
        query.descending("field2")
        XCTAssertEqual(query.sort!, ["field1" : 1, "field2" : -1])
    }
    
    func testReset() {
        
        XCTAssertNil(query.operators)
        XCTAssertNil(query.userQuery)
        XCTAssertNil(query.sort)
        XCTAssertNil(query.fields)
        XCTAssertNil(query.andOr)
        
        query.equalTo("fieldName", SCString("A"))
        query.raw("{ \"fieldString\" : \"Строка\" }")
        query.ascending("field1")
        query.descending("field2")
        query.fields(["field1", "field2"])
        let and1 = SCOperator.equalTo("fieldString", SCString("Строка"))
        let and2 = SCOperator.equalTo("fieldNumber", SCInt(33))
        query.and([and1, and2])
        
        query.reset()
        
        XCTAssertNil(query.operators)
        XCTAssertNil(query.userQuery)
        XCTAssertNil(query.sort)
        XCTAssertNil(query.fields)
        XCTAssertNil(query.andOr)
    }
    
    func testAscending() {
        XCTAssertNil(query.sort)
        query.ascending("field1")
        XCTAssertEqual(query.sort!, ["field1" : 1])
    }
    
    func testDescending() {
        XCTAssertNil(query.sort)
        query.descending("field1")
        XCTAssertEqual(query.sort!, ["field1" : -1])
    }
    
    func testPage() {
        XCTAssertNil(query.skip)
        XCTAssertNil(query.limit)
        
        query.page(-1)
        XCTAssertNil(query.skip)
        XCTAssertNil(query.limit)
        
        query.page(5)
        XCTAssertNil(query.limit)
        XCTAssertEqual(query.skip, 0)
        
        query.limit(10)
        query.page(5)
        XCTAssertEqual(query.skip, 40)
    }
    
    func testEqualTo() {
        XCTAssertNil(query.operators)
        query.equalTo(fieldName, scString)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.equalTo(fieldName, scString))
    }
    
    func testNotEqualTo() {
        XCTAssertNil(query.operators)
        query.notEqualTo(fieldName, scString)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.notEqualTo(fieldName, scString))
    }
    
    func testContainedIn() {
        XCTAssertNil(query.operators)
        query.containedIn(fieldName, scArray)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.containedIn(fieldName, scArray))
    }

    func testContainsAll() {
        XCTAssertNil(query.operators)
        query.containsAll(fieldName, scArray)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.containsAll(fieldName, scArray))
    }
    
    func testNotContainedIn() {
        XCTAssertNil(query.operators)
        query.notContainedIn(fieldName, scArray)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.notContainedIn(fieldName, scArray))
    }
    
    func testGreaterThan() {
        XCTAssertNil(query.operators)
        query.greaterThan(fieldName, scInt)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.greaterThan(fieldName, scInt))
    }
    
    func testGreaterThanOrEqualTo() {
        XCTAssertNil(query.operators)
        query.greaterThanOrEqualTo(fieldName, scInt)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.greaterThanOrEqualTo(fieldName, scInt))
    }
    
    func testLessThan() {
        XCTAssertNil(query.operators)
        query.lessThan(fieldName, scInt)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.lessThan(fieldName, scInt))
    }
    
    func testLessThanOrEqualTo() {
        XCTAssertNil(query.operators)
        query.lessThanOrEqualTo(fieldName, scInt)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.lessThanOrEqualTo(fieldName, scInt))
    }
    
    func testExists() {
        XCTAssertNil(query.operators)
        query.exists(fieldName)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.exists(fieldName))
    }
    
    func testDoesNotExist() {
        XCTAssertNil(query.operators)
        query.doesNotExist(fieldName)
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.doesNotExist(fieldName))
    }
    
    func testContains() {
        XCTAssertNil(query.operators)
        query.contains(fieldName, "[A-Z]")
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.contains(fieldName, "[A-Z]", ""))
    }
    
    func testStartsWith() {
        XCTAssertNil(query.operators)
        query.startsWith(fieldName, "[A-Z]")
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.startsWith(fieldName, "[A-Z]", ""))
    }
    
    func testEndsWith() {
        XCTAssertNil(query.operators)
        query.endsWith(fieldName, "[A-Z]")
        XCTAssertTrue(query.operators![fieldName]! == SCOperator.endsWith(fieldName, "[A-Z]", ""))
    }
}
