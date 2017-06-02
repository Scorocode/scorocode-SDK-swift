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

public class SCObject {
    
    fileprivate var _id: String?
    public var id: String? {
        get {
            return _id
        }
        set {
            _id = newValue
        }
    }
    
    fileprivate var _update = SCUpdate()
    public var update: SCUpdate {
        return _update
    }
    
    var data = [String: Any]()
    
    fileprivate let _collection: String
    public var collection: String {
        get {
            return _collection
        }
    }
    
    public init(collection: String, id: String?) {
        self._collection = collection
        self._id = id
    }
    
    public convenience init(collection: String) {
        self.init(collection: collection, id: nil)
    }
    
    public func get(_ name: String) -> Any? {
        return data[name]
    }
    
    public func set(_ dic: [String: SCValue]) {
        _update.set(dic)
    }
    
    public func push(_ name: String, _ value: SCValue) {
        _update.push(name, value)
    }
    
    public func pushEach(_ name: String, _ value: SCValue) {
        _update.pushEach(name, value)
    }
    
    public func pull(_ name: String, _ value: SCPullable) {
        _update.pull(name, value)
    }
    
    public func pullAll(_ name: String, _ value: SCValue) {
        _update.pullAll(name, value)
    }
    
    public func addToSet(_ name: String, _ value: SCValue) {
        _update.addToSet(name, value)
    }
    
    public func addToSetEach(_ name: String, _ value: SCValue) {
        _update.addToSetEach(name, value)
    }
    
    public func pop(_ name: String, _ value: Int) {
        _update.pop(name, value)
    }
    
    public func inc(_ name: String, _ value: SCValue) {
        _update.inc(name, value)
    }
    
    public func currentDate(_ name: String, typeSpec: String) {
        _update.currentDate(name, typeSpec: typeSpec)
    }
    
    public func mul(_ name: String, _ value: SCValue) {
        _update.mul(name, value)
    }
    
    public func min(_ name: String, _ value: SCValue) {
        _update.min(name, value)
    }
    
    public func max(_ name: String, _ value: SCValue) {
        _update.max(name, value)
    }
    
    public class func getById(_ id: String, collection: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var query = SCQuery(collection: collection)
        query.equalTo("_id", SCString(id))
        SCAPI.sharedInstance.find(query, callback: callback)
    }
    
    public func save(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        if _id != nil && _update.operators.count > 0 {
            SCAPI.sharedInstance.updateById(self, callback: callback)
        } else {
            SCAPI.sharedInstance.insert(self, callback: callback)
        }
    }
    
    // Удаляет текущий документ
    public func remove(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard _id != nil else {
            callback(false, SCError.system("Id не заполнен"), nil)
            return
        }
        
        var query = SCQuery(collection: _collection)
        query.equalTo("_id", SCString(_id!))
        SCAPI.sharedInstance.remove(query, callback: callback)
    }
    
    public func upload(_ field: String, filename: String, data: Data, callback: @escaping (Bool, SCError?) -> Void) {
        
        guard let id = _id else { return }
        
        let encodedData = data.base64EncodedString(options: NSData.Base64EncodingOptions())
        SCAPI.sharedInstance.upload(field, filename: filename, data: encodedData, docId: id, collection: collection, callback: callback)
    }
    
    public func deleteFile(_ field: String, filename: String, callback: @escaping (Bool, SCError?) -> Void) {
        guard let id = _id else { return }
        SCAPI.sharedInstance.deleteFile(field, filename: filename, docId: id, collection: collection, callback: callback)
    }
    
    public func getFileLink(_ fieldName: String, fileName: String) -> String {
        guard let id = _id else {
            let _ = SCError.system("Id не заполнен")
            return ""
        }
        return SCAPI.sharedInstance.getFileLink(collectionId: _collection, documentId: id, fieldName: fieldName, fileName: fileName)
    }
    
}
