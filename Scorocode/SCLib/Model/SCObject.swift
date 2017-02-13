//
//  SCObject.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

struct SCNewObjectAttributes {
    var id: String?
    var createdAt: Date?
    var updatedAt: Date?
    var readACL: [String]?
    var updateACL: [String]?
    var removeACL: [String]?
    
    init() {
        
    }
}

class SCObject {
    
    fileprivate var _id: String?
    var id: String? {
        get {
            return _id
        }
        set {
            _id = newValue
        }
    }
    
    fileprivate var _update = SCUpdate()
    var update: SCUpdate {
        return _update
    }
    
    var data = [String: Any]()
    
    fileprivate let _collection: String
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
    
    func get(_ name: String) -> Any? {
        return data[name]
    }
    
    func set(_ dic: [String: SCValue]) {
        _update.set(dic)
    }
    
    func push(_ name: String, _ value: SCValue) {
        _update.push(name, value)
    }
    
    func pushEach(_ name: String, _ value: SCValue) {
        _update.pushEach(name, value)
    }
    
    func pull(_ name: String, _ value: SCPullable) {
        _update.pull(name, value)
    }
    
    func pullAll(_ name: String, _ value: SCValue) {
        _update.pullAll(name, value)
    }
    
    func addToSet(_ name: String, _ value: SCValue) {
        _update.addToSet(name, value)
    }
    
    func addToSetEach(_ name: String, _ value: SCValue) {
        _update.addToSetEach(name, value)
    }
    
    func pop(_ name: String, _ value: Int) {
        _update.pop(name, value)
    }
    
    func inc(_ name: String, _ value: SCValue) {
        _update.inc(name, value)
    }
    
    func currentDate(_ name: String, typeSpec: String) {
        _update.currentDate(name, typeSpec: typeSpec)
    }
    
    func mul(_ name: String, _ value: SCValue) {
        _update.mul(name, value)
    }
    
    func min(_ name: String, _ value: SCValue) {
        _update.min(name, value)
    }
    
    func max(_ name: String, _ value: SCValue) {
        _update.max(name, value)
    }
    
    class func getById(_ id: String, collection: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var query = SCQuery(collection: collection)
        query.equalTo("_id", SCString(id))
        SCAPI.sharedInstance.find(query, callback: callback)
    }
    
    func save(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        if _id != nil && _update.operators.count > 0 {
            SCAPI.sharedInstance.updateById(self, callback: callback)
        } else {
            SCAPI.sharedInstance.insert(self, callback: callback)
        }
    }
    
    // Удаляет текущий документ
    func remove(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard _id != nil else {
            callback(false, SCError.system("Id не заполнен"), nil)
            return
        }
        
        var query = SCQuery(collection: _collection)
        query.equalTo("_id", SCString(_id!))
        SCAPI.sharedInstance.remove(query, callback: callback)
    }
    
    func upload(_ field: String, filename: String, data: Data, callback: @escaping (Bool, SCError?) -> Void) {
        
        guard let id = _id else { return }
        
        let encodedData = data.base64EncodedString(options: NSData.Base64EncodingOptions())
        SCAPI.sharedInstance.upload(field, filename: filename, data: encodedData, docId: id, collection: collection, callback: callback)
    }
    
    func deleteFile(_ field: String, filename: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        guard let id = _id else { return }
        
        SCAPI.sharedInstance.deleteFile(field, filename: filename, docId: id, collection: collection, callback: callback)
    }
    
    func getFile(_ field: String, filename: String, callback: (Bool, SCError?) -> Void) {
        SCAPI.sharedInstance.getFile(self.collection, field: field, filename: filename, callback: callback)
    }
    
    func getFileLink(_ fieldName: String, callback: @escaping (Bool, SCError?, URL?) -> Void) {
        if let filename = get(fieldName) as? String {
            SCAPI.sharedInstance.getFileLink(_collection, fieldName: fieldName, filename: filename, callback: callback)
        }
    }
    
}
