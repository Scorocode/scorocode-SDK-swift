//
//  TestSCAPI.swift
//  SC
//
//  Created by Aleksandr Konakov on 20/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

class TestSCAPI: XCTestCase {
    
    fileprivate let username = "juggle"
    fileprivate let email = "ara@juggle.ru"
    fileprivate let password = "select"
    
    fileprivate let applicationId = ""
    fileprivate let clientId = ""
    fileprivate let accessKey = ""
    fileprivate let fileKey = ""
    fileprivate let messageKey = ""
    
    fileprivate let collection = "testcoll"
    
    fileprivate let timeout = 3.0
    
    fileprivate var insertedDocId: String!
    
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
        
        let expectation = self.expectation(description: "Login")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            XCTAssertNotNil(result!["sessionId"])
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testLogout() {
        
        let expectation = self.expectation(description: "Logout")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            SCAPI.sharedInstance.logout() {
                success, error in
                
                XCTAssertTrue(success)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRegister() {
        
        let expectation = self.expectation(description: "Logout")
        
        let username = "newUser"
        let email = "\(UUID().uuidString)@domain.ru"
        let password = "password"
        
        SCAPI.sharedInstance.register(username, email: email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            SCAPI.sharedInstance.register(username, email: email, password: password) {
                success, error, result in
                
                assertError(success, error, result)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testCount() {
        
        let expectation = self.expectation(description: "Count")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in

            assertSuccess(success, error, result)
            
            let query = SCQuery(collection: self.collection)
            query.count() {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)

    }
    
    func testFind() {
        
        let expectation = self.expectation(description: "Find")
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let query = SCQuery(collection: self.collection)
            query.find() {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                var queryRaw = SCQuery(collection: self.collection)
                queryRaw.raw("{ \"fieldString\" : \"NewValue\" }")
                    queryRaw.find() {
                    success, error, result in
                    
                    assertSuccess(success, error, result)
                }
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testInsert() {
        
        let expectation = self.expectation(description: "Insert")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("Some test string"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                XCTAssertNotNil(result!["_id"])
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testUpdate() {
        
        let expectation = self.expectation(description: "Update")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("OldValue"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                // Возвращен _id
                XCTAssertNotNil(result!["_id"])
                
                let docId = result!["_id"]! as! String
                
                var query = SCQuery(collection: self.collection)
                query.equalTo("fieldString", SCString("OldValue"))
                
                var update = SCUpdate()
                update.set(["fieldString": SCString("NewValue")])
                
                SCAPI.sharedInstance.update(query, update: update) {
                    success, error, result in
                    
                    assertSuccess(success, error, result)
                    
                    let removedDocs = result!["docs"]! as! [String]
                    
                    // _id - в списке обновленных
                    XCTAssertTrue(removedDocs.contains(docId))
                    
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testRemove() {
        
        let expectation = self.expectation(description: "Remove")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("Some test string"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                // Возвращен _id
                XCTAssertNotNil(result!["_id"])
                
                let docId = result!["_id"]! as! String
                
                var query = SCQuery(collection: self.collection)
                query.equalTo("_id", SCString(docId))
                
                SCAPI.sharedInstance.remove(query) {
                    success, error, result in
                    
                    assertSuccess(success, error, result)
                    
                    let removedDocs = result!["docs"]! as! [String]
                    
                    // _id - в списке удаленных
                    XCTAssertTrue(removedDocs.contains(docId))
                    
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testUpdateById() {
        
        let expectation = self.expectation(description: "UpdateById")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let obj = SCObject(collection: self.collection)
            obj.set([
                "fieldString": SCString("OldValue"),
                "readACL": SCArray([SCString("*"), SCString("0123456789")])
                ])
            
            SCAPI.sharedInstance.insert(obj) {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                // Возвращен _id
                XCTAssertNotNil(result!["_id"])
                
                let newObj = SCObject(collection: self.collection, id: (result!["_id"]! as! String))
                newObj.data = result!
                newObj.set(["fieldString": SCString("NewValue")])
                SCAPI.sharedInstance.updateById(newObj) {
                    success, error, result in
                    
                    assertSuccess(success, error, result)
                    
                    XCTAssertEqual((result!["fieldString"]! as! String), "NewValue")
                    
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testSendEmail() {
        
        let expectation = self.expectation(description: "SendEmail")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let query = SCQuery(collection: "users")
            SCAPI.sharedInstance.sendEmail(query, subject: "Test Message", text: "Test message text") {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testSendPush() {
        
        let expectation = self.expectation(description: "SendPush")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let query = SCQuery(collection: "devices")
            SCAPI.sharedInstance.sendPush(query, subject: "Test Message", text: "Test message text") {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testSendSMS() {
        
        let expectation = self.expectation(description: "SendSMS")
        
        SCAPI.sharedInstance.login(email, password: password) {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            let query = SCQuery(collection: "users")
            SCAPI.sharedInstance.sendSms(query, subject: "Test Message", text: "Test message text") {
                success, error, result in
                
                assertSuccess(success, error, result)
                
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testScripts() {
        
        let expectation = self.expectation(description: "Scripts")
        
        // TODO: успешное выполнение
        
        SCAPI.sharedInstance.scripts("abc", pool: [:]) {
            success, error in
            
            assertError(success, error, nil)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    
    func testStat() {
        
        let expectation = self.expectation(description: "Stat")
        
        // TODO: успешное выполнение
        
        SCAPI.sharedInstance.stat() {
            success, error, result in
            
            assertSuccess(success, error, result)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
