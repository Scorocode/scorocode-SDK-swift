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
    fileprivate let kCollectionIndexName = "index"
    fileprivate let kCollectionFieldName = "collField"
    fileprivate let kCollectionTriggersName = "triggers"
    fileprivate let kFoldersPathName = "path"
    
    fileprivate let kScriptIDName = "script"
    fileprivate let kScriptName = "cloudCode"
    fileprivate let kScriptFilename = "name"
    fileprivate let kScriptDescription = "description"
    fileprivate let kScriptCode = "code"
    fileprivate let kScriptJobStartAt = "jobStartAt"
    fileprivate let kScriptIsActiveJob = "isActiveJob"
    fileprivate let kScriptJobtype = "jobType"
    fileprivate let kScriptPath = "path"
    fileprivate let kScriptTimerSettings = "repeat"
    fileprivate let kScriptACL = "ACL"
    
    fileprivate let kBotDictName = "bot"
    fileprivate let kBotName = "name"
    fileprivate let kBotTelegramBotId = "botId"
    fileprivate let kBotScriptID = "scriptId"
    fileprivate let kBotIsActive = "isActive"
    
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
        
        
        let lowPriorityQueue = DispatchQueue(label: "ru.scorocode.utility-queue",
                                             qos: .utility,
                                             attributes:.concurrent)
        
        Alamofire.request(SCAPIRouter.find(body)).responseJSON(queue: lowPriorityQueue, options: .allowFragments) {
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
                    let dictionary = bson.dictionaryFromBSONData(BSONData: data!)
                    callback(true, nil, dictionary)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }    }
    
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
    func runScript(_ scriptId: String, pool: [String: Any], debug: Bool, callback: @escaping (Bool, SCError?) -> Void) {
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
                    callback(true, nil, response["app"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Получение списка коллекций приложения и их настроек
    func collections(_ callback: @escaping (Bool, SCError?, [String: Any]?, [SCCollection]) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        Alamofire.request(SCAPIRouter.collections(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, nil, [])
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let dict = response["collections"].dictionaryObject
                    if dict != nil {
                        var collectionsArray = [SCCollection]()
                        for (_, value) in dict! {
                            if let dict = value as? [String: Any] {
                                let coll = self.parseCollection(dict: dict)
                                if coll != nil {
                                    collectionsArray.append(coll!)
                                }
                            }
                        }
                        callback(true, nil, dict, collectionsArray)
                    } else {
                        callback(true, nil, dict, [])
                    }
                } else {
                    callback(false, self.makeError(response), nil, [])
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
                    let result = response["collection"].dictionaryObject
                    if result != nil {
                        callback(true, nil, result, self.parseCollection(dict: result!))
                    } else {
                        callback(true, nil, result, nil)
                    }
                } else {
                    callback(false, self.makeError(response), nil, nil)
                }
            }
        }
    }
    
    func parseCollection(dict: [String: Any]) -> SCCollection? {
        if let id = dict["id"] as? String, let name = dict["name"] as? String {
            let coll = SCCollection(id: id, name: name)
            if let useDocsACL = dict["useDocsACL"] as? Bool {
                coll.useDocsACL = useDocsACL
            }
            if let aclDict = dict["ACL"] as? [String: Any] {
                if let createArray = aclDict["create"] as? [String] {
                    coll.acl.create = createArray
                }
                if let readArray = aclDict["read"] as? [String] {
                    coll.acl.read = readArray
                }
                if let removeArray = aclDict["remove"] as? [String] {
                    coll.acl.remove = removeArray
                }
                if let updateArray = aclDict["update"] as? [String] {
                    coll.acl.update = updateArray
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
        return nil
    }
    
    // Создание новой коллекции
    func createCollection(name : String, useDocsACL: Bool, ACLsettings: ACL, callback: @escaping (Bool, SCError?, [String: Any]?, String?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kCollectionDictName] = [kCollectionName: name,
                                     kCollectionUseDocsACL: useDocsACL, //? NSNumber(value: true) : NSNumber(value: false)
            kCollectionACL: ACLsettings.toDict()]
        
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
                    let result = response["collection"].dictionaryObject
                    if let collectionID = result?["id"] as? String {
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
        var collectionDict : [String: Any] = ["id": id,
                                              kCollectionUseDocsACL: useDocsACL,
                                              kCollectionACL: ACLsettings.toDict()]
        if name != nil {
            collectionDict[kCollectionName] = name!
        }
        body["collection"] = collectionDict
        
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
                    callback(true, nil, response["collection"].dictionaryObject)
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
        
        Alamofire.request(SCAPIRouter.cloneCollection(body)).responseJSON() {
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
    
    // Создание индекса коллекции
    func createCollectionIndex(collectionName: String, indexName: String, fieldName: String, order: IndexSortOrder, callback: @escaping (Bool, SCError?, [String:Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollection] = collectionName
        body[kCollectionIndexName] = ["name" : indexName, "fields" : [[
            "name": fieldName,
            "order": order.rawValue
            ]]]
        
        
        Alamofire.request(SCAPIRouter.createCollectionIndex(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, nil)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
        
    }
    
    // Удаление индекса коллекции
    func deleteCollectionIndex(collectionName: String, indexName: String, callback: @escaping (Bool, SCError?, [String:Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollection] = collectionName
        body[kCollectionIndexName] = ["name" : indexName]
        
        Alamofire.request(SCAPIRouter.deleteCollectionIndex(body)).responseJSON() {
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
    
    // Создание поля коллекции
    func createCollectonField(collectionName: String, fieldName: String, fieldType: FieldType, targetCollectonName: String?,callback: @escaping (Bool, SCError?, [String:Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollection] = collectionName
        body[kCollectionFieldName] = (targetCollectonName == nil) ?
            (["name" : fieldName,"type": fieldType.rawValue]) :
            (["name" : fieldName,"type": fieldType.rawValue, "target": targetCollectonName])
        
        Alamofire.request(SCAPIRouter.createCollectonField(body)).responseJSON() {
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
    
    // Удаление поля коллекции
    func deleteCollectonField(collectionName: String, fieldName: String, callback: @escaping (Bool, SCError?, [String:Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollection] = collectionName
        body[kCollectionFieldName] = ["name" : fieldName]
        
        Alamofire.request(SCAPIRouter.deleteCollectonField(body)).responseJSON() {
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
                    callback(true, nil, response["collection"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    //Изменение триггеров коллекции
    func updateCollectionTriggers(collectionName : String, triggers: Triggers, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kCollection] = collectionName
        body[kCollectionTriggersName] = triggers.toDict()
        
        Alamofire.request(SCAPIRouter.updateCollectionTriggers(body)).responseJSON() {
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
    
    // Получение списка папок и скриптов директории
    func getFoldersAndScriptsList(path: String, callback: @escaping (Bool, SCError?, [Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kFoldersPathName] = path
        
        Alamofire.request(SCAPIRouter.getFoldersAndScriptsList(body)).responseJSON() {
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
                    callback(true, nil, response["items"].arrayObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Создание новой папки
    func createFolder(path: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kFoldersPathName] = path
        
        Alamofire.request(SCAPIRouter.createFolder(body)).responseJSON() {
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
    
    // Удаление папки со всем содержимым
    func deleteFolder(path: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kFoldersPathName] = path
        
        Alamofire.request(SCAPIRouter.deleteFolder(body)).responseJSON() {
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
    
    // Получение скрипта
    func getScript(scriptId: String, callback: @escaping (Bool, SCError?, [String: Any]?, SCScript?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kScriptIDName] = scriptId
        
        Alamofire.request(SCAPIRouter.getScript(body)).responseJSON() {
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
                    let result = response["script"].dictionaryObject
                    if result != nil {
                        callback(true, nil, result, self.parseScript(dict: result!))
                    } else {
                        callback(false, nil, result, nil)
                    }
                } else {
                    callback(false, self.makeError(response), nil, nil)
                }
            }
        }
    }
    
    func parseScript(dict: [String: Any]) -> SCScript? {
        if let id = dict["_id"] as? String, let path = dict["path"] as? String {
            let script = SCScript(id: id, path: path)
            if let ACL = dict["ACL"] as? [String] {
                script.ACL = ACL
            }
            if let name = dict["name"] as? String {
                script.name = name
            }
            if let code = dict["code"] as? String {
                script.code = code
            }
            if let description = dict["description"] as? String {
                script.description = description
            }
            if let jobStartAt = dict["jobStartAt"] as? String {
                let en_US_POSIX = Locale(identifier: "en_US_POSIX")
                let rfc3339DateFormatter = DateFormatter()
                rfc3339DateFormatter.locale = en_US_POSIX
                rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
                rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                if let date = rfc3339DateFormatter.date(from: jobStartAt) {
                    script.jobStartAt = SCDate(date)
                }
            }
            if let isActiveJob = dict["isActiveJob"] as? Bool {
                script.isActiveJob = isActiveJob
            }
            if let jobType = dict["jobType"] as? String {
                if let type = ScriptJobType(rawValue: jobType) {
                    script.jobType = type
                }
            }
            if let timerSettings = dict["repeat"] as? [String: Any] {
                if let custom = timerSettings["custom"] as? [String: Any],
                    let days = custom["days"] as? Int,
                    let hours = custom["hours"] as? Int,
                    let minutes = custom["minutes"] as? Int {
                    script.repeatTimer.custom.days = days
                    script.repeatTimer.custom.hours = hours
                    script.repeatTimer.custom.minutes = minutes
                }
                if let daily = timerSettings["daily"] as? [String: Any],
                    let on = daily["on"] as? [Int],
                    let hours = daily["hours"] as? Int,
                    let minutes = daily["minutes"] as? Int {
                    script.repeatTimer.daily.on = on
                    script.repeatTimer.daily.hours = hours
                    script.repeatTimer.daily.minutes = minutes
                }
                if let monthly = timerSettings["monthly"] as? [String: Any],
                    let days = monthly["days"] as? [Int],
                    let hours = monthly["hours"] as? Int,
                    let minutes = monthly["minutes"] as? Int,
                    let lastDate = monthly["lastDate"] as? Bool,
                    let on = monthly["on"] as? [Int] {
                    script.repeatTimer.monthly.on = on
                    script.repeatTimer.monthly.lastDate = lastDate
                    script.repeatTimer.monthly.days = days
                    script.repeatTimer.monthly.hours = hours
                    script.repeatTimer.monthly.minutes = minutes
                }
            }
            return script
        } else {
            return nil
        }
    }
    
    // Создание нового скрипта
    func createScript(script: SCScript, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        body[kScriptName] = [kScriptPath: script.path!,
                             kScriptName:script.name,
                             kScriptCode:script.code,
                             kScriptJobtype: script.jobType!.rawValue,
                             kScriptJobStartAt: script.jobStartAt.apiValue,
                             kScriptDescription: script.description,
                             kScriptIsActiveJob: script.isActiveJob,
                             kScriptACL: script.ACL,
                             kScriptTimerSettings: script.repeatTimer.toDict()]
        
        Alamofire.request(SCAPIRouter.createScript(body)).responseJSON() {
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
                    callback(true, nil, response["cloudCode"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Изменение скрипта
    func saveScript(script: SCScript, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kScriptIDName] = script.id!
        
        body[kScriptName] = [kScriptPath: script.path!,
                             kScriptFilename:script.name,
                             kScriptCode:script.code,
                             kScriptJobtype: script.jobType!.rawValue,
                             kScriptJobStartAt: script.jobStartAt.apiValue,
                             kScriptDescription: script.description,
                             kScriptIsActiveJob: script.isActiveJob,
                             kScriptACL: script.ACL,
                             kScriptTimerSettings: script.repeatTimer.toDict()]
        
        Alamofire.request(SCAPIRouter.saveScript(body)).responseJSON() {
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
                    callback(true, nil, response["script"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // Удаление скрипта
    func deleteScript(scriptId: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        body[kScriptIDName] = scriptId
        
        Alamofire.request(SCAPIRouter.deleteScript(body)).responseJSON() {
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
    
    // Изменение бота
    func saveBot(bot: SCBot, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        body[kBotDictName] = ["_id": bot.id!,
                              kBotName:bot.name,
                              kBotTelegramBotId:bot.telegramBotId,
                              kBotScriptID: bot.scriptId,
                              kBotIsActive: bot.isActive]
        
        Alamofire.request(SCAPIRouter.saveBot(body)).responseJSON() {
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
    
    func parseBot(bot: [String:Any]) -> SCBot? {
        if let id = bot["_id"] as? String, let name = bot["name"] as? String {
            let b = SCBot(id: id, name: name)
            if let botId = bot["botId"] as? String {
                b.telegramBotId = botId
            }
            if let scriptId = bot["scriptId"] as? String {
                b.scriptId = scriptId
            }
            if let isActive = bot["isActive"] as? Bool {
                b.isActive = isActive
            }
            return b
        } else {
            return nil
        }
    }
    
    // Получение списка ботов приложения
    func getBots(callback: @escaping (Bool, SCError?, [SCBot]) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        Alamofire.request(SCAPIRouter.getBots(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                print(error)
                callback(false, error, [])
                return
            }
            if let responseValue = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let array = response["items"].arrayObject
                    if array != nil {
                        var botsArray = [SCBot]()
                        for value in array! {
                            if let dict = value as? [String: Any] {
                                let bot = self.parseBot(bot: dict)
                                if bot != nil {
                                    botsArray.append(bot!)
                                }
                            }
                        }
                        callback(true, nil, botsArray)
                    } else {
                        callback(true, nil, [])
                    }
                } else {
                    callback(false, self.makeError(response), [])
                }
            }
        }
    }
    
    // Создание бота
    func createBot(bot: SCBot, callback: @escaping (Bool, SCError?, [String: Any]?, String?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        body[kBotDictName] = [kBotName: bot.name,
                              kBotTelegramBotId: bot.telegramBotId,
                              kBotScriptID: bot.scriptId,
                              kBotIsActive: bot.isActive]
        
        Alamofire.request(SCAPIRouter.createBot(body)).responseJSON() {
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
                    let result = response["bot"].dictionaryObject
                    if let id = result?["_id"] as? String {
                        callback(true, nil, result, id)
                    } else {
                        callback(true, nil, result, nil)
                    }
                } else {
                    callback(false, self.makeError(response), nil, nil)
                }
            }
        }
    }
    
    // Удаление бота
    func deleteBot(botId: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId as Any?
        body[kClientKey] = clientId as Any?
        body[kAccessKey] = accessKey as Any?
        
        body[kBotDictName] = ["_id": botId]
        
        Alamofire.request(SCAPIRouter.deleteBot(body)).responseJSON() {
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
