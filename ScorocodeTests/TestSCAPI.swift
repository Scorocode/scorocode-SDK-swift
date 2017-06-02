//
//  TestSCAPI.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest

class TestSCAPI: XCTestCase {
    
    private let username = "alexey"
    private let email = "alexey@company.com"
    private let password = "alexey"
    
    let applicationId = "cd02126a02e44643ba38c923cf699bb7"
    let clientId = "900ca6a05f604eb8a88aac6941efcaa4"
    let accessKey = "32e4b1c15e7d470dbbacab57fa6e8406"
    let fileKey = "98bd371cdca944bcbebd45eb13fa17b6"
    let messageKey = "171f8ac1fa6f4ed8b3ec623739b2ad04"
    
    private let collection = "testcollection"
    
    private let timeout = 3.0
    
    private var insertedDocId: String!
    
    override func setUp() {
        super.setUp()
        
        insertedDocId = ""
        SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin() {
        
        let exp = expectation(description: "Login")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            XCTAssertNotNil(result!["sessionId"])
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testLogout() {
        
        let exp = expectation(description: "Logout")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            SCAPI.sharedInstance.logout() {
                success, error in
                
                XCTAssertTrue(success)
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRegister() {
        
        let exp = expectation(description: "Logout")
        
        let username = "newUser"
        let email = "\(NSUUID().uuidString)@domain.ru"
        let password = "password"
        
        SCAPI.sharedInstance.register(username, email: email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            SCAPI.sharedInstance.register(username, email: email, password: password) {
                success, error, result in
                
                assertError(success: success, error: error, result: result)
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testCount() {
        
        let exp = expectation(description: "Count")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in

            assertSuccess(success: success, error: error, result: result)
            
            let query = SCQuery(collection: self.collection)
            query.count() {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)

    }
    
    func testFind() {
        
        let exp = expectation(description: "Find")
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            let query = SCQuery(collection: self.collection)
            query.find() {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                var queryRaw = SCQuery(collection: self.collection)
                queryRaw.raw("{ \"fieldString\" : \"NewValue\" }")
                    queryRaw.find() {
                    success, error, result in
                    
                    assertSuccess(success: success, error: error, result: result)
                }
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testInsert() {
        
        let exp = expectation(description: "Insert")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("Some test string"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                XCTAssertNotNil(result!["_id"])
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testUpdate() {
        
        let exp = expectation(description: "Update")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("OldValue"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                // Возвращен _id
                XCTAssertNotNil(result!["_id"])
                
                let docId = result!["_id"]! as! String
                
                var query = SCQuery(collection: self.collection)
                query.equalTo("fieldString", SCString("OldValue"))
                
                var update = SCUpdate()
                update.set(["fieldString": SCString("NewValue")])
                
                SCAPI.sharedInstance.update(query, update: update) {
                    success, error, result in
                    
                    assertSuccess(success: success, error: error, result: result)
                    
                    let removedDocs = result!["docs"]! as! [String]
                    
                    // _id - в списке обновленных
                    XCTAssertTrue(removedDocs.contains(docId))
                    
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testRemove() {
        
        let exp = expectation(description: "Remove")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("Some test string"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                // Возвращен _id
                XCTAssertNotNil(result!["_id"])
                
                let docId = result!["_id"]! as! String
                
                var query = SCQuery(collection: self.collection)
                query.equalTo("_id", SCString(docId))
                
                SCAPI.sharedInstance.remove(query) {
                    success, error, result in
                    
                    assertSuccess(success: success, error: error, result: result)
                    
                    let removedDocs = result!["docs"]! as! [String]
                    
                    // _id - в списке удаленных
                    XCTAssertTrue(removedDocs.contains(docId))
                    
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testUpdateById() {
        
        let exp = expectation(description: "UpdateById")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("OldValue"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                // Возвращен _id
                XCTAssertNotNil(result!["_id"])
                
                let newObj = SCObject(collection: self.collection, id: (result!["_id"]! as! String))
                newObj.data = result!
                newObj.set(["fieldString": SCString("NewValue")])
                SCAPI.sharedInstance.updateById(newObj) {
                    success, error, result in
                    
                    assertSuccess(success: success, error: error, result: result)
                    
                    XCTAssertEqual((result!["fieldString"]! as! String), "NewValue")
                    
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testSendPush() {
        
        let exp = expectation(description: "SendPush")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            let query = SCQuery(collection: "devices")
            
            SCAPI.sharedInstance.sendPush(query, title: "Test Message", text: "Test message text", debug: false) {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testSendSMS() {
        
        let exp = expectation(description: "SendSMS")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            
            let query = SCQuery(collection: "users")

            SCAPI.sharedInstance.sendSms(query, text: "Test Message") {
                success, error, result in
                
                assertSuccess(success: success, error: error, result: result)
                
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testScripts() {
        
        let exp = expectation(description: "Scripts")
        
        // TODO: успешное выполнение
        
        SCAPI.sharedInstance.runScript("abc", pool: [:], debug: false) {
            success, error in
            
            assertError(success: success, error: error, result: nil)
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    
    func testStat() {
        
        let exp = expectation(description: "Stat")
        
        // TODO: успешное выполнение
        
        SCAPI.sharedInstance.stat() {
            success, error, result in
            
            assertSuccess(success: success, error: error, result: result)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
