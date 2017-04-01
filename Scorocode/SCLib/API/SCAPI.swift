//
//  SCAPI.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum SCError {
    case system(String)
    case api(String, String)
}

public class SCAPI {
    
    fileprivate let kApplicationId = "app"
    fileprivate let kClientKey = "cli"
    fileprivate let kAccessKey = "acc"
    fileprivate let kUsername = "username"
    fileprivate let kEmail = "email"
    fileprivate let kPassword = "password"
    fileprivate let kSessionId = "sess"
    fileprivate let kCollection = "coll"
    fileprivate let kMessage = "msg"
    fileprivate let kMessageText = "text"
    fileprivate let kQuery = "query"
    fileprivate let kDoc = "doc"
    fileprivate let kSort = "sort"
    fileprivate let kFields = "fields"
    fileprivate let kLimit = "limit"
    fileprivate let kSkip = "skip"
    fileprivate let kScript = "script"
    fileprivate let kPool = "pool"
    fileprivate let kDocId = "docId"
    fileprivate let kField = "field"
    fileprivate let kFile = "file"
    fileprivate let kContent = "content"
    fileprivate let kDebug = "debug"
    fileprivate let kData = "data"
    fileprivate let kCollectionName = "name"
    fileprivate let kCollectionUseDocsACL = "useDocsACL"
    fileprivate let kCollectionACL = "ACL"
    fileprivate let kCollectionDictName = "collection"
    
    static let sharedInstance = SCAPI()
    
    internal var applicationId = ""
    internal var clientId = ""
    internal var accessKey = ""
    internal var fileKey = ""
    internal var messageKey = ""
    
    var sessionId: String!
    
    // MARK: User
    func login(_ email: String, password: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kEmail] = email
        body[kPassword] = password
        
        Alamofire.request(SCAPIRouter.login(body as [String : Any])).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let result = response["result"].dictionaryValue
                    if let sessionId = result["sessionId"] {
                        self.sessionId = sessionId.stringValue
                        callback(true, nil, response["result"].dictionaryObject)
                    }
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
        
    }
    
    func logout(_ callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kSessionId] = sessionId
        
        Alamofire.request(SCAPIRouter.logout(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    func register(_ username: String, email: String, password: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kUsername] = username as Any?
        body[kEmail] = email as Any?
        body[kPassword] = password as Any?
        
        Alamofire.request(SCAPIRouter.register(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    
    // MARK: Object
    func insert(_ doc: SCObject, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = doc.collection as Any?

//        var bodyDoc = [String: Any]()
//
//        for setter in doc.update.operators {
//            let key = setter.dic.allKeys[0] as! String
//            let value = setter.dic.allValues[0]
//            bodyDoc[key] = value
//        }
//        body[kDoc] = bodyDoc
        
        body[kDoc] = doc.update.operators[0].dic
        
        Alamofire.request(SCAPIRouter.insert(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func remove(_ query: SCQuery, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = query.collection as Any?
        body[kQuery] = makeBodyQuery(query) as Any?
        
        if let limit = query.limit {
            body[kLimit] = limit as Any?
        }
        
        Alamofire.request(SCAPIRouter.remove(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func update(_ query: SCQuery, update: SCUpdate, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = query.collection as Any?
        body[kQuery] = makeBodyQuery(query) as Any?
        body[kDoc] = makeBodyDoc(update) as Any?
        
        Alamofire.request(SCAPIRouter.update(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func updateById(_ obj: SCObject, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = obj.collection as Any?
        body[kQuery] = ["_id" : obj.id!]
        body[kDoc] = makeBodyDoc(obj.update) as Any?
        
        Alamofire.request(SCAPIRouter.updateById(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let result = response["result"].dictionaryObject
                    callback(true, nil, result)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func find(_ query: SCQuery, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = query.collection as Any?
        body[kQuery] = makeBodyQuery(query) as Any?
        
        if let sort = query.sort {
            body[kSort] = sort as Any?
        }
        
        if let fields = query.fields {
            body[kFields] = fields as Any?
        }
        
        if let skip = query.skip {
            body[kSkip] = skip as Any?
        }
        
        if let limit = query.limit {
            body[kLimit] = limit as Any?
        }
        
        
        Alamofire.request(SCAPIRouter.find(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let base64String = response["result"].stringValue
                    let data = Data(base64Encoded: base64String.data(using: String.Encoding.utf8)!, options: Data.Base64DecodingOptions())
                    let bson = BSON()
                    let dictionary = bson.dictionaryFromBSONData(BSONData: data!) as [String:AnyObject]
                    //print(dictionary)
                    callback(true, nil, dictionary)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func count(_ query: SCQuery, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = query.collection as Any?
        body[kQuery] = makeBodyQuery(query) as Any?
        
        Alamofire.request(SCAPIRouter.count(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func getFileLink(collectionId: String, documentId: String, fieldName: String, fileName: String) -> String {
        return SCAPIRouter.baseURLString + "getfile/\(applicationId)/\(collectionId)/\(fieldName)/\(documentId)/\(fileName)"
        // https://api.scorocode.ru/api/v1/getfile/{app}/{coll}/{field}/{docId}/{file}
    }
    
    // MARK: File
    func upload(_ field: String, filename: String, data: String, docId: String,  collection: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = collection as Any?
        body[kDocId] = docId as Any?
        body[kField] = field as Any?
        body[kContent] = data as Any?
        body[kFile] = filename as Any?
        
        Alamofire.request(SCAPIRouter.upload(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    func deleteFile(_ field: String, filename: String, docId: String, collection: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = collection as Any?
        body[kDocId] = docId as Any?
        body[kField] = field as Any?
        body[kFile] = filename as Any?
        
        Alamofire.request(SCAPIRouter.deleteFile(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }

    
    // MARK: Message
    func sendPush(_ query: SCQuery, data: Dictionary<String, Any>, debug: Bool, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = query.collection as Any?
        body[kQuery] = makeBodyQuery(query) as Any?
        body[kMessage] = ["data": data]
        body[kDebug] = debug //? NSNumber(value: true) : NSNumber(value: false)
        
        Alamofire.request(SCAPIRouter.sendPush(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["count"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func sendPush(_ query: SCQuery, title: String, text: String, debug: Bool, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = query.collection as Any?
        body[kQuery] = makeBodyQuery(query) as Any?
        body[kDebug] = debug //? NSNumber(value: true) : NSNumber(value: false)
        body[kMessage] =
            ["data":
                ["apns" :
                    ["aps" :
                        ["alert" :
                            [ "title" : title,
                              "body" : text]
                        ]
                    ]
                ]
            ]

        Alamofire.request(SCAPIRouter.sendPush(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["count"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }

    
    func sendSms(_ query: SCQuery, text: String, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kSessionId] = sessionId as Any?
        body[kCollection] = query.collection as Any?
        body[kQuery] = makeBodyQuery(query) as Any?
        body[kMessage] = [kMessageText: text] as Any?
        
        
        Alamofire.request(SCAPIRouter.sendSms(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["count"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    
    
    // MARK: Script
    func scripts(_ scriptId: String, pool: [String: Any], debug: Bool, callback: @escaping (Bool, SCError?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kScript] = scriptId as Any?
        body[kPool] = pool as Any?
        body[kDebug] = debug //? NSNumber(value: true) : NSNumber(value: false)
        
        Alamofire.request(SCAPIRouter.scripts(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    func stat(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        Alamofire.request(SCAPIRouter.stat(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Получение полной информации о приложении
    func app(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        Alamofire.request(SCAPIRouter.app(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Получение списка коллекций приложения и их настроек
    func collections(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        Alamofire.request(SCAPIRouter.collections(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Просмотр структуры и настроек конкретной коллекции.
    func getCollection(_ collection: String, callback: @escaping (Bool, SCError?, [String: Any]?, SCCollection?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kCollection] = collection as Any?
        
        Alamofire.request(SCAPIRouter.getCollection(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let result = response["result"].dictionaryObject
                    let coll = self.parseCollection(result: result)
                    callback(true, nil, result, coll)
                } else {
                    callback(false, self.makeError(response), nil, nil)
                }
            }
        }
    }
    
    func parseCollection(result: [String: Any]?) -> SCCollection? {
        guard result != nil else {
            return nil
        }
        if let dict = result?["collection"] as? [String: Any] {
            if let id = dict["id"] as? String, let name = dict["name"] as? String {
                let coll = SCCollection(id: id, name: name)
                if let useDocsACL = dict["useDocsACL"] as? Bool {
                    coll.useDocsACL = useDocsACL
                }
                if let aclDict = dict["ACL"] as? [String: Any] {
                    if let createArray = aclDict["create"] as? [String] {
                        coll.acl.create = SCArray(stringArray: createArray)
                    }
                    if let readArray = aclDict["read"] as? [String] {
                        coll.acl.read = SCArray(stringArray: readArray)
                    }
                    if let removeArray = aclDict["remove"] as? [String] {
                        coll.acl.read = SCArray(stringArray: removeArray)
                    }
                    if let updateArray = aclDict["update"] as? [String] {
                        coll.acl.read = SCArray(stringArray: updateArray)
                    }
                }
                if let triggersDict = dict["triggers"] as? [String: Any] {
                    if let afterInsert = triggersDict["afterInsert"] as? [String: Any],
                        let code = afterInsert["code"] as? String,
                        let isActive = afterInsert["isActive"] as? Bool {
                        coll.triggers.afterInsert.code = code
                        coll.triggers.afterInsert.isActive = isActive
                    }
                    if let afterRemove = triggersDict["afterRemove"] as? [String: Any],
                        let code = afterRemove["code"] as? String,
                        let isActive = afterRemove["isActive"] as? Bool {
                        coll.triggers.afterRemove.code = code
                        coll.triggers.afterRemove.isActive = isActive
                    }
                    if let afterUpdate = triggersDict["afterUpdate"] as? [String: Any],
                        let code = afterUpdate["code"] as? String,
                        let isActive = afterUpdate["isActive"] as? Bool {
                        coll.triggers.afterUpdate.code = code
                        coll.triggers.afterUpdate.isActive = isActive
                    }
                    if let beforeInsert = triggersDict["beforeInsert"] as? [String: Any],
                        let code = beforeInsert["code"] as? String,
                        let isActive = beforeInsert["isActive"] as? Bool {
                        coll.triggers.beforeInsert.code = code
                        coll.triggers.beforeInsert.isActive = isActive
                    }
                    if let beforeRemove = triggersDict["beforeRemove"] as? [String: Any],
                        let code = beforeRemove["code"] as? String,
                        let isActive = beforeRemove["isActive"] as? Bool {
                        coll.triggers.beforeRemove.code = code
                        coll.triggers.beforeRemove.isActive = isActive
                    }
                    if let beforeUpdate = triggersDict["beforeUpdate"] as? [String: Any],
                        let code = beforeUpdate["code"] as? String,
                        let isActive = beforeUpdate["isActive"] as? Bool {
                        coll.triggers.beforeUpdate.code = code
                        coll.triggers.beforeUpdate.isActive = isActive
                    }
                    return coll
                }
            } else {
                return nil
            }
        }
        return nil
    }
    
    // Создание новой коллекции
    func createCollection(name : String, useDocsACL: Bool, ACLsettings: ACL, callback: @escaping (Bool, SCError?, [String: Any]?, String?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kCollectionName] = name as Any?
        body[kCollectionUseDocsACL] = useDocsACL //? NSNumber(value: true) : NSNumber(value: false)
        body[kCollectionACL] = ACLsettings.toDict()
        
        Alamofire.request(SCAPIRouter.createCollection(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let result = response["result"].dictionaryObject
                    if let collectionID = (result?["collection"] as? [String: Any])?["id"] as? String {
                        callback(true, nil, result, collectionID)
                    } else {
                        callback(true, nil, result, nil)
                    }
                } else {
                    callback(false, self.makeError(response), nil, nil)
                }
            }
        }
    }
    
    // Изменение настроек коллекции
    func updateCollection(id: String, name: String?, useDocsACL: Bool, ACLsettings: ACL, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        if name != nil {
            body[kCollectionName] = name!
        }
        body[kCollectionUseDocsACL] = useDocsACL
        body[kCollectionACL] = ACLsettings.toDict()
        
        Alamofire.request(SCAPIRouter.updateCollection(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Удаление коллекции
    func deleteCollection(id: String, callback: @escaping (Bool, SCError?, [String:Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollectionDictName] = ["id": id]
        
        Alamofire.request(SCAPIRouter.removeCollection(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }

    }
    
    // Создание дубликата коллекции
    func cloneCollection(id: String, name: String, callback: @escaping (Bool, SCError?, [String:Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollectionDictName] = ["id": id, "name": name]
        
        Alamofire.request(SCAPIRouter.removeCollection(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
        
    }
    
    func makeError(_ response: JSON) -> SCError {
        let errCode = response["errCode"].stringValue
        let errMsg = response["errMsg"].stringValue
        return SCError.api(errCode, errMsg)
    }
    
    func makeBodyDoc(_ update: SCUpdate) -> [String: Any] {
        var result = [String: Any]()
        for op in update.operators {
            result[op.name] = op.dic
        }
        return result
    }
    
    func makeBodyQuery(_ query: SCQuery) -> [String: Any] {
        
        if let userQuery = query.userQuery {
            return userQuery
        }
        
        var result = [String: Any]()
        if let operators = query.operators {
            for (key, op) in operators {
                result[key] = op.dic
            }
        }
        if let andOr = query.andOr {
            switch andOr {
            case .and:
                result["$and"] = andOr.dic
            case .or:
                result["$or"] = andOr.dic
            default:
                break
            }
        }

        return result
    }
    
}
