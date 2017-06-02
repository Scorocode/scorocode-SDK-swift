//
//  TestSCObject.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest

class TestSCObject: XCTestCase {
    
    let collection = "testcollection"
    
    private let timeout = 5.0
    
    override func setUp() {
        super.setUp()
        let applicationId = "cd02126a02e44643ba38c923cf699bb7"
        let clientId = "900ca6a05f604eb8a88aac6941efcaa4"
        let accessKey = "32e4b1c15e7d470dbbacab57fa6e8406"
        let fileKey = "98bd371cdca944bcbebd45eb13fa17b6"
        let messageKey = "171f8ac1fa6f4ed8b3ec623739b2ad04"

        
        SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
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
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.set(["fieldName": SCString("Value")]))
    }
    
    func testPush() {
        let obj = SCObject(collection: collection)
        obj.push("fieldName", SCString("A"))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.push(name: "fieldName", value: SCString("A"), each: false))
    }
    
    func testPushEach() {
        let obj = SCObject(collection: collection)
        obj.pushEach("fieldName", SCArray([SCString("A")]))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.push(name: "fieldName", value: SCArray([SCString("A")]), each: true))
    }
    
    // TODO: Pull
    // TODO: PullAll
    
    func testAddToSet() {
        let obj = SCObject(collection: collection)
        obj.addToSet("fieldName", SCString("A"))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.addToSet(name: "fieldName", value: SCString("A"), each: false))
    }
    
    func testAddToSetEach() {
        let obj = SCObject(collection: collection)
        obj.addToSetEach("fieldName", SCString("A"))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.addToSet(name: "fieldName", value: SCString("A"), each: true))
    }
    
    func testPop() {
        let obj = SCObject(collection: collection)
        obj.pop("fieldName", 1)
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.pop("fieldName", 1))
    }
    
    func testInc() {
        let obj = SCObject(collection: collection)
        obj.inc("fieldName", SCInt(5))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.inc("fieldName", SCInt(5)))
    }
    
    func testCurrentDate() {
        let obj = SCObject(collection: collection)
        obj.currentDate("fieldName", typeSpec: "timestamp")
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.currentDate("fieldName", "timestamp"))
    }
    
    func testMul() {
        let obj = SCObject(collection: collection)
        obj.mul("fieldName", SCDouble(1.23))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.mul("fieldName", SCDouble(1.23)))
    }
    
    func testMin() {
        let obj = SCObject(collection: collection)
        obj.min("fieldName", SCDouble(1.23))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.min("fieldName", SCDouble(1.23)))
    }
    
    func testMax() {
        let obj = SCObject(collection: collection)
        obj.max("fieldName", SCDouble(1.23))
        XCTAssertEqual(obj.update.operators.last, SCUpdateOperator.max("fieldName", SCDouble(1.23)))
    }
    
    func testGetById() {
        
        let exp = expectation(description: "GetById")
        
        let obj = SCObject(collection: collection)
        obj.set([
            "fieldString": SCString("Some test string"),
            "readACL": SCArray([SCString("*"), SCString("0123456789")])
            ])
        obj.save() {
            success, error, result in
            assertSuccess(success: success, error: error, result: result)
            XCTAssertNotNil(result!["_id"])
            
            let docId = result!["_id"]! as! String
            obj.id = docId
            obj.data = result!
            
            SCObject.getById(docId, collection: self.collection) {
            
                success, error, result in
                assertSuccess(success: success, error: error, result: result)
                
                XCTAssertNotNil(result!["0"])
                
                let doc = result!["0"]! as! [String : Any]
                XCTAssertEqual(doc["_id"] as! String, docId)

                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    
    func testSave() {
        
        let exp = expectation(description: "Save")
        
        let obj = SCObject(collection: collection)
        obj.set([
            "fieldString": SCString("Some test string"),
            "readACL": SCArray([SCString("*"), SCString("0123456789")])
            ])
        obj.save() {
            success, error, result in
            assertSuccess(success: success, error: error, result: result)
            
            XCTAssertNotNil(result!["_id"])
            
            obj.id = (result!["_id"]! as! String)
            obj.data = result!
            obj.set(["fieldString": SCString("Some new value")])
            
            obj.save() {
                success, error, result in
                assertSuccess(success: success, error: error, result: result)
                
                XCTAssertEqual((result!["fieldString"] as! String), "Some new value")
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRemove() {
        
        let exp = expectation(description: "Remove")
        
        let obj = SCObject(collection: collection)
        obj.set([
            "fieldString": SCString("Some test string"),
            "readACL": SCArray([SCString("*"), SCString("0123456789")])
            ])
        obj.save() {
            success, error, result in
            assertSuccess(success: success, error: error, result: result)
            
            XCTAssertNotNil(result!["_id"])
            
            let docId = result!["_id"]! as! String
            obj.id = docId
            
            obj.remove() {
                success, error, result in
                assertSuccess(success: success, error: error, result: result)
                
                let removedDocs = result!["docs"]! as! [String]
                
                // _id - в списке удаленных
                XCTAssertTrue(removedDocs.contains(docId))
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRemoveNullId() {
        
        let exp = expectation(description: "RemoveNullId")
        
        let obj = SCObject(collection: collection)
        
        obj.remove() {
            success, error, result in
            assertError(success: success, error: error, result: result)
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
}
