//
//  TestSCObject.swift
//  SC
//
//  Created by Aleksandr Konakov on 19/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

class TestSCObject: XCTestCase {
    
    let collection = "testcoll"
    
    private let timeout = 3.0
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let obj1 = SCObject(collection: collection, id: "123")
        XCTAssertEqual(obj1.collection, collection)
        XCTAssertEqual(obj1.id, "123")
        
        let obj2 = SCObject(collection: collection)
        XCTAssertEqual(obj2.collection, collection)
        XCTAssertNil(obj2.id)
    }
    
    func testGet() {
        let obj = SCObject(collection: collection)
        obj.data["fieldName"] = "Value"
        XCTAssertEqual(obj.get("fieldName") as? String, "Value")
    }
    
    func testSet() {
        let obj = SCObject(collection: collection)
        obj.set(["fieldName": SCString("Value")])
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Set(["fieldName": SCString("Value")]))
    }
    
    func testPush() {
        let obj = SCObject(collection: collection)
        obj.push("fieldName", SCString("A"))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Push(name: "fieldName", value: SCString("A"), each: false))
    }
    
    func testPushEach() {
        let obj = SCObject(collection: collection)
        obj.pushEach("fieldName", SCArray([SCString("A")]))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Push(name: "fieldName", value: SCArray([SCString("A")]), each: true))
    }
    
    // TODO: Pull
    // TODO: PullAll
    
    func testAddToSet() {
        let obj = SCObject(collection: collection)
        obj.addToSet("fieldName", SCString("A"))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.AddToSet(name: "fieldName", value: SCString("A"), each: false))
    }
    
    func testAddToSetEach() {
        let obj = SCObject(collection: collection)
        obj.addToSetEach("fieldName", SCString("A"))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.AddToSet(name: "fieldName", value: SCString("A"), each: true))
    }
    
    func testPop() {
        let obj = SCObject(collection: collection)
        obj.pop("fieldName", 1)
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Pop("fieldName", 1))
    }
    
    func testInc() {
        let obj = SCObject(collection: collection)
        obj.inc("fieldName", SCInt(5))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Inc("fieldName", SCInt(5)))
    }
    
    func testCurrentDate() {
        let obj = SCObject(collection: collection)
        obj.currentDate("fieldName", typeSpec: "timestamp")
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.CurrentDate("fieldName", "timestamp"))
    }
    
    func testMul() {
        let obj = SCObject(collection: collection)
        obj.mul("fieldName", SCDouble(1.23))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Mul("fieldName", SCDouble(1.23)))
    }
    
    func testMin() {
        let obj = SCObject(collection: collection)
        obj.min("fieldName", SCDouble(1.23))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Min("fieldName", SCDouble(1.23)))
    }
    
    func testMax() {
        let obj = SCObject(collection: collection)
        obj.max("fieldName", SCDouble(1.23))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.Max("fieldName", SCDouble(1.23)))
    }
    
    func testGetById() {
        
        let expectation = expectationWithDescription("GetById")
        
        let obj = SCObject(collection: collection)
        obj.set([
            "fieldString": SCString("Some test string"),
            "readACL": SCArray([SCString("*"), SCString("0123456789")])
            ])
        obj.save() {
            success, error, result in
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["_id"])
            
            let docId = result!["_id"]! as! String
            obj.id = docId
            obj.data = result!
            
            SCObject.getById(docId, collection: self.collection) {
            
                success, error, result in
                assertSuccess(success, error, result)
                
                XCTAssertNotNil(result!["0"])
                
                let doc = result!["0"]!
                XCTAssertEqual(doc["_id"], docId)

                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
    }
    
    
    func testSave() {
        
        let expectation = expectationWithDescription("Save")
        
        let obj = SCObject(collection: collection)
        obj.set([
            "fieldString": SCString("Some test string"),
            "readACL": SCArray([SCString("*"), SCString("0123456789")])
            ])
        obj.save() {
            success, error, result in
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["_id"])
            
            obj.id = (result!["_id"]! as! String)
            obj.data = result!
            obj.set(["fieldString": SCString("Some new value")])
            
            obj.save() {
                success, error, result in
                assertSuccess(success, error, result)
                
                XCTAssertEqual((result!["fieldString"] as! String), "Some new value")
                
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testRemove() {
        
        let expectation = expectationWithDescription("Remove")
        
        let obj = SCObject(collection: collection)
        obj.set([
            "fieldString": SCString("Some test string"),
            "readACL": SCArray([SCString("*"), SCString("0123456789")])
            ])
        obj.save() {
            success, error, result in
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["_id"])
            
            let docId = result!["_id"]! as! String
            obj.id = docId
            
            obj.remove() {
                success, error, result in
                assertSuccess(success, error, result)
                
                let removedDocs = result!["docs"]! as! [String]
                
                // _id - в списке удаленных
                XCTAssertTrue(removedDocs.contains(docId))
                
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testRemoveNullId() {
        
        let expectation = expectationWithDescription("RemoveNullId")
        
        let obj = SCObject(collection: collection)
        
        obj.remove() {
            success, error, result in
            assertError(success, error, result)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
    }
}
