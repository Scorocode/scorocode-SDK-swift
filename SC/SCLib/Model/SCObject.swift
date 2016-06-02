//
//  SCObject.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

struct SCNewObjectAttributes {
    var id: String?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    var readACL: [String]?
    var updateACL: [String]?
    var removeACL: [String]?
    
    init() {
        
    }
}

class SCObject {
    
    private var _id: String?
    var id: String? {
        get {
            return _id
        }
        set {
            _id = newValue
        }
    }
    
    private var _update = SCUpdate()
    var update: SCUpdate {
        return _update
    }
    
    var data = [String: AnyObject]()
    
    private let _collection: String
    var collection: String {
        get {
            return _collection
        }
    }
    
    init(collection: String, id: String?) {
        self._collection = collection
        self._id = id
    }
    
    convenience init(collection: String) {
        self.init(collection: collection, id: nil)
    }
    
    func get(name: String) -> AnyObject? {
        return data[name]
    }
    
    func set(dic: [String: SCValue]) {
        _update.set(dic)
    }
    
    func push(name: String, _ value: SCValue) {
        _update.push(name, value)
    }
    
    func pushEach(name: String, _ value: SCValue) {
        _update.pushEach(name, value)
    }
    
    func pull(name: String, _ value: SCPullable) {
        _update.pull(name, value)
    }
    
    func pullAll(name: String, _ value: SCValue) {
        _update.pullAll(name, value)
    }
    
    func addToSet(name: String, _ value: SCValue) {
        _update.addToSet(name, value)
    }
    
    func addToSetEach(name: String, _ value: SCValue) {
        _update.addToSetEach(name, value)
    }
    
    func pop(name: String, _ value: Int) {
        _update.pop(name, value)
    }
    
    func inc(name: String, _ value: SCValue) {
        _update.inc(name, value)
    }
    
    func currentDate(name: String, typeSpec: String) {
        _update.currentDate(name, typeSpec: typeSpec)
    }
    
    func mul(name: String, _ value: SCValue) {
        _update.mul(name, value)
    }
    
    func min(name: String, _ value: SCValue) {
        _update.min(name, value)
    }
    
    func max(name: String, _ value: SCValue) {
        _update.max(name, value)
    }
    
    class func getById(id: String, collection: String, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var query = SCQuery(collection: collection)
        query.equalTo("_id", SCString(id))
        SCAPI.sharedInstance.find(query, callback: callback)
    }
    
    func save(callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        if _id != nil && _update.operators.count > 0 {
            SCAPI.sharedInstance.updateById(self, callback: callback)
        } else {
            SCAPI.sharedInstance.insert(self, callback: callback)
        }
    }
    
    // Удаляет текущий документ
    func remove(callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        guard _id != nil else {
            callback(false, SCError.System("Id не заполнен"), nil)
            return
        }
        
        var query = SCQuery(collection: _collection)
        query.equalTo("_id", SCString(_id!))
        SCAPI.sharedInstance.remove(query, callback: callback)
    }
    
    func upload(field: String, filename: String, data: NSData, callback: (Bool, SCError?) -> Void) {
        
        guard let id = _id else { return }
        
        let encodedData = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        SCAPI.sharedInstance.upload(field, filename: filename, data: encodedData, docId: id, collection: collection, callback: callback)
    }
    
    func deleteFile(field: String, filename: String, callback: (Bool, SCError?) -> Void) {
        
        guard let id = _id else { return }
        
        SCAPI.sharedInstance.deleteFile(field, filename: filename, docId: id, collection: collection, callback: callback)
    }
    
    func getFile(field: String, filename: String, callback: (Bool, SCError?) -> Void) {
        SCAPI.sharedInstance.getFile(self.collection, field: field, filename: filename, callback: callback)
    }
    
    func getFileLink(fieldName: String, callback: (Bool, SCError?, NSURL?) -> Void) {
        if let filename = get(fieldName) as? String {
            SCAPI.sharedInstance.getFileLink(_collection, fieldName: fieldName, filename: filename, callback: callback)
        }
    }
    
}