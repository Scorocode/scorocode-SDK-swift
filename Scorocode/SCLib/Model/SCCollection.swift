//
//  SCCollection.swift
//  Scorocode
//
//  Created by Alexey Kuznetsov on 16.03.17.
//  Copyright © 2017 Prof-IT Group OOO. All rights reserved.
//

import Foundation


public struct ACL {
    public var create = SCArray([SCString]())
    public var read = SCArray([SCString]())
    public var remove = SCArray([SCString]())
    public var update = SCArray([SCString]())
    
    fileprivate let kCollectionACLcreate = "create"
    fileprivate let kCollectionACLread = "read"
    fileprivate let kCollectionACLremove = "remove"
    fileprivate let kCollectionACLupdate = "update"
    
    public func toDict() -> [String: Any] {
        var dict = [String: Any]()
        dict.updateValue(self.read.apiValue, forKey: kCollectionACLread)
        dict.updateValue(self.create.apiValue, forKey: kCollectionACLcreate)
        dict.updateValue(self.update.apiValue, forKey: kCollectionACLupdate)
        dict.updateValue(self.remove.apiValue, forKey: kCollectionACLremove)
        return dict
    }

}

public struct Triggers {
    
    fileprivate let kCollectionTriggersAfterInsert = "afterInsert"
    fileprivate let kCollectionTriggersAfterRemove = "afterRemove"
    fileprivate let kCollectionTriggersAfterUpdate = "afterUpdate"
    fileprivate let kCollectionTriggersBeforeInsert = "beforeInsert"
    fileprivate let kCollectionTriggersBeforeRemove = "beforeRemove"
    fileprivate let kCollectionTriggersBeforeUpdate = "beforeUpdate"
    
    fileprivate let kCollectionCode = "code"
    fileprivate let kCollectionIsActive = "isActive"
    
    public var afterInsert = _afterInsert()
    public var afterRemove = _afterRemove()
    public var afterUpdate = _afterUpdate()
    public var beforeInsert = _beforeInsert()
    public var beforeRemove = _beforeRemove()
    public var beforeUpdate = _beforeUpdate()
    
    
    public struct _afterInsert {
        public var code = ""
        public var isActive = false
    }
    
    public struct _afterRemove {
        public var code = ""
        public var isActive = false
    }
    
    public struct _afterUpdate {
        public var code = ""
        public var isActive = false
    }
    
    public struct _beforeInsert {
        public var code = ""
        public var isActive = false
    }
    
    public struct _beforeRemove {
        public var code = ""
        public var isActive = false
    }
    
    public struct _beforeUpdate {
        public var code = ""
        public var isActive = false
    }
    
    public func toDict() -> [String: Any] {
        var dict = [String: Any]()
        dict.updateValue([kCollectionCode: self.afterInsert.code, kCollectionIsActive: self.afterInsert.isActive], forKey: kCollectionTriggersAfterInsert)
        dict.updateValue([kCollectionCode: self.afterRemove.code, kCollectionIsActive: self.afterRemove.isActive], forKey: kCollectionTriggersAfterRemove)
        dict.updateValue([kCollectionCode: self.afterUpdate.code, kCollectionIsActive: self.afterUpdate.isActive], forKey: kCollectionTriggersAfterUpdate)
        dict.updateValue([kCollectionCode: self.beforeInsert.code, kCollectionIsActive: self.beforeInsert.isActive], forKey: kCollectionTriggersBeforeInsert)
        dict.updateValue([kCollectionCode: self.beforeRemove.code, kCollectionIsActive: self.beforeRemove.isActive], forKey: kCollectionTriggersBeforeRemove)
        dict.updateValue([kCollectionCode: self.beforeUpdate.code, kCollectionIsActive: self.beforeUpdate.isActive], forKey: kCollectionTriggersBeforeUpdate)
        return dict
    }
}

public class SCCollection {
    
    public var name: String?
    public var id: String?
    public var useDocsACL = false
    public var acl = ACL()
    public var triggers = Triggers()
    
    public init(id: String?, name: String) {
        self.name = name
        self.id = id
    }
    
    public convenience init(name: String) {
        self.init(id: nil, name: name)
    }
    
    // Создание новой коллекции
    public func create(useDocsACL: Bool = false, ACLsettings: ACL = ACL(), callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.name != nil else {
            callback(false, SCError.system("Имя коллекции не задано."), nil)
            return
        }
        SCAPI.sharedInstance.createCollection(name: self.name!, useDocsACL: useDocsACL, ACLsettings: ACLsettings) { (success, error, result, id) in
            if id != nil {
                self.id = id
            }
            callback(success, error, result)
        }
    }
    
    // Изменение настроек коллекции
    public func save(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id коллекции не задан."), nil)
            return
        }
        SCAPI.sharedInstance.updateCollection(id: self.id!, name: self.name, useDocsACL: self.useDocsACL, ACLsettings: self.acl, callback: callback)
    }
    
    // Удаление коллекции
    public func delete(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id коллекции не задан."), nil)
            return
        }
        SCAPI.sharedInstance.deleteCollection(id: self.id!, callback: callback)
    }
    
    // Создание дубликата коллекции
    public func clone(name: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id коллекции не задан."), nil)
            return
        }
        SCAPI.sharedInstance.cloneCollection(id: self.id!, name: name, callback: callback)
    }
    
    // Загрузка или просмотр существующей коллекции
    public func load(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.name != nil else {
            callback(false, SCError.system("имя коллекции не задано."), nil)
            return
        }
        SCAPI.sharedInstance.getCollection(self.name!) { (success, error, result, coll) in
            if coll != nil {
                self.id = coll!.id
                self.name = coll!.name
                self.acl = coll!.acl
                self.triggers = coll!.triggers
            }
            callback(success, error, result)
        }
    }
}

