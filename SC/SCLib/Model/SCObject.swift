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
    var createdAt: Date?
    var updatedAt: Date?
    var readACL: [String]?
    var updateACL: [String]?
    var removeACL: [String]?
    
    init() {
        
    }
}

open class SCObject {
    
    fileprivate var _id: String?
    open var id: String? {
        get {
            return _id
        }
        set {
            _id = newValue
        }
    }
    
    fileprivate var _update = SCUpdate()
    open var update: SCUpdate {
        return _update
    }
    
    open var data = [String: AnyObject]()
    
    fileprivate let _collection: String
    open var collection: String {
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
    
    open func get(_ name: String) -> AnyObject? {
        return data[name]
    }
    
    open func set(_ dic: [String: SCValue]) {
        _update.set(dic)
    }
    
    open func push(_ name: String, _ value: SCValue) {
        _update.push(name, value)
    }
    
    open func pushEach(_ name: String, _ value: SCValue) {
        _update.pushEach(name, value)
    }
    
    open func pull(_ name: String, _ value: SCPullable) {
        _update.pull(name, value)
    }
    
    open func pullAll(_ name: String, _ value: SCValue) {
        _update.pullAll(name, value)
    }
    
    open func addToSet(_ name: String, _ value: SCValue) {
        _update.addToSet(name, value)
    }
    
    open func addToSetEach(_ name: String, _ value: SCValue) {
        _update.addToSetEach(name, value)
    }
    
    open func pop(_ name: String, _ value: Int) {
        _update.pop(name, value)
    }
    
    open func inc(_ name: String, _ value: SCValue) {
        _update.inc(name, value)
    }
    
    open func currentDate(_ name: String, typeSpec: String) {
        _update.currentDate(name, typeSpec: typeSpec)
    }
    
    open func mul(_ name: String, _ value: SCValue) {
        _update.mul(name, value)
    }
    
    open func min(_ name: String, _ value: SCValue) {
        _update.min(name, value)
    }
    
    open func max(_ name: String, _ value: SCValue) {
        _update.max(name, value)
    }
    
    open class func getById(_ id: String, collection: String, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var query = SCQuery(collection: collection)
        query.equalTo("_id", SCString(id))
        SCAPI.sharedInstance.find(query, callback: callback)
    }
    
    open func save(_ callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        if _id != nil && _update.operators.count > 0 {
            SCAPI.sharedInstance.updateById(self, callback: callback)
        } else {
            SCAPI.sharedInstance.insert(self, callback: callback)
        }
    }
    
    // Удаляет текущий документ
    open func remove(_ callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        guard _id != nil else {
            callback(false, SCError.system("Id не заполнен"), nil)
            return
        }
        
        var query = SCQuery(collection: _collection)
        query.equalTo("_id", SCString(_id!))
        SCAPI.sharedInstance.remove(query, callback: callback)
    }
    
    open func upload(_ field: String, filename: String, data: Data, callback: @escaping (Bool, SCError?) -> Void) {
        
        guard let id = _id else { return }
        
        let encodedData = data.base64EncodedString(options: NSData.Base64EncodingOptions())
        SCAPI.sharedInstance.upload(field, filename: filename, data: encodedData, docId: id, collection: collection, callback: callback)
    }
    
    open func deleteFile(_ field: String, filename: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        guard let id = _id else { return }
        
        SCAPI.sharedInstance.deleteFile(field, filename: filename, docId: id, collection: collection, callback: callback)
    }
    
    open func getFile(_ field: String, filename: String, callback: (Bool, SCError?) -> Void) {
        SCAPI.sharedInstance.getFile(self.collection, field: field, filename: filename, callback: callback)
    }
    
    open func getFileLink(_ fieldName: String, callback: @escaping (Bool, SCError?, URL?) -> Void) {
        if let filename = get(fieldName) as? String {
            SCAPI.sharedInstance.getFileLink(_collection, fieldName: fieldName, filename: filename, callback: callback)
        }
    }
    
}
