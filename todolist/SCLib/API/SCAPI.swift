//
//  SCAPI.swift
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public enum SCError {
    case system(String)
    case api(String, String)
}

public class SCAPI {
    
    fileprivate let queue = DispatchQueue(label: "com.scorocode.low-priority-queue", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
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
    internal var scriptKey = ""
    
    var sessionId: String?
    
    // MARK: request
    func sendRequest(_ urlRequest: URLRequest?, callback: @escaping (SCError?, [String: Any]?) -> Void) {
        guard urlRequest != nil else {
            callback(SCError.system("Cannot create url request."), nil)
            return
        }
        self.queue.async {
            // set up the session
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            // make the request
            let task = session.dataTask(with: urlRequest!) {
                (data, response, error) in
                // check for any errors
                guard error == nil else {
                    DispatchQueue.main.async {
                        callback(SCError.system("Error: calling post request"), nil)
                    }
                    return
                }
                // make sure we got data
                guard let responseData = data else {
                    DispatchQueue.main.async {
                        callback(SCError.system("Error: did not receive data"), nil)
                    }
                    return
                }
                // parse the result as JSON, since that's what the API provides
                do {
                    guard let response = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                        DispatchQueue.main.async {
                            callback(SCError.system("error trying to convert data to JSON"), nil)
                        }
                        return
                    }
                    if let error = response["error"] as? Bool, error == true {
                        if let errCode = response["errCode"] as? Int,
                            let errMsg = response["errMsg"] as? String {
                            DispatchQueue.main.async {
                                callback(SCError.api("\(errCode)", errMsg), response)
                            }
                            return
                        } else {
                            DispatchQueue.main.async {
                                callback(SCError.system("unable to get error code or error message"), response)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            callback(nil, response)
                        }
                    }
                    return
                } catch  {
                    DispatchQueue.main.async {
                        callback(SCError.system("error trying to convert data to JSON"), nil)
                    }
                    return
                }
            }
            task.resume()
            session.finishTasksAndInvalidate()
        }
        
    }
    
    // MARK: User
    func login(_ email: String, password: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kEmail] = email
        body[kPassword] = password
        
        self.sendRequest(SCAPIRouter.login(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any],
                    let sessionId = dict["sessionId"] as? String {
                    self.sessionId = sessionId
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func logout(_ callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
        }
        
        self.sendRequest(SCAPIRouter.logout(body).urlRequest) { (error, result) in
            if error == nil {
                self.sessionId = nil
                callback(true, nil)
            } else {
                callback(false, error)
            }
        }
    }
    
    func register(_ username: String, email: String, password: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kUsername] = username
        body[kEmail] = email
        body[kPassword] = password
        
        self.sendRequest(SCAPIRouter.register(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    
    // MARK: Object
    func insert(_ doc: SCObject, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
        }
        body[kCollection] = doc.collection
        
        body[kDoc] = doc.update.operators[0].dic
        
        self.sendRequest(SCAPIRouter.insert(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func remove(_ query: SCQuery, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
        }
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        
        if let limit = query.limit {
            body[kLimit] = limit
        }
        
        self.sendRequest(SCAPIRouter.remove(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func update(_ query: SCQuery, update: SCUpdate, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
        }
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kDoc] = makeBodyDoc(update)
        
        self.sendRequest(SCAPIRouter.update(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func updateById(_ obj: SCObject, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
        }
        body[kCollection] = obj.collection
        body[kQuery] = ["_id" : obj.id!]
        body[kDoc] = makeBodyDoc(obj.update)
        
        self.sendRequest(SCAPIRouter.updateById(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func find(_ query: SCQuery, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
        }
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        
        if let sort = query.sort {
            body[kSort] = sort
        }
        
        if let fields = query.fields {
            body[kFields] = fields
        }
        
        if let skip = query.skip {
            body[kSkip] = skip
        }
        
        if let limit = query.limit {
            body[kLimit] = limit
        }
        
        self.sendRequest(SCAPIRouter.find(body).urlRequest) { (error, result) in
            if error == nil {
                if let base64String = result?["result"] as? String,
                    let data = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions()) {
                    self.queue.async {
                        let dictionary = data.dictionaryFromBSONData()
                        DispatchQueue.main.async {
                            callback(true, nil, dictionary)
                        }
                    }
                } else {
                    callback(false, SCError.system("Unable to convert response to dictionary"), nil)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func count(_ query: SCQuery, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
        }
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        
        self.sendRequest(SCAPIRouter.count(body).urlRequest) { (error, result) in
            if error == nil {
                if let int = result?["result"] as? Int {
                    callback(true, nil, int)
                } else {
                    callback(false, SCError.system("Unable to parse response"), nil)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func getFileLink(collectionId: String, documentId: String, fieldName: String, fileName: String) -> String {
        let urlString = SCAPIRouter.baseURLString + "getfile/\(applicationId)/\(collectionId)/\(fieldName)/\(documentId)/\(fileName)"
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            return url
        } else {
            print("Error: Unable to make correct url for this file: \(fileName)")
            return ""
        }
    }
    
    // MARK: File
    func upload(_ field: String, filename: String, data: String, docId: String,  collection: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
            body[kAccessKey] = fileKey
        } else {
            body[kAccessKey] = accessKey
        }
        body[kCollection] = collection
        body[kDocId] = docId
        body[kField] = field
        body[kContent] = data
        body[kFile] = filename
        
        self.sendRequest(SCAPIRouter.upload(body).urlRequest) { (error, result) in
            if error == nil {
                callback(true, nil)
            } else {
                callback(false, error)
            }
        }
    }
    
    func deleteFile(_ field: String, filename: String, docId: String, collection: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = fileKey
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
            body[kAccessKey] = fileKey
        } else {
            body[kAccessKey] = accessKey
        }
        body[kCollection] = collection
        body[kDocId] = docId
        body[kField] = field
        body[kFile] = filename
        
        self.sendRequest(SCAPIRouter.deleteFile(body).urlRequest) { (error, result) in
            if error == nil {
                callback(true, nil)
            } else {
                callback(false, error)
            }
        }
    }
    
    
    // MARK: Message
    func sendPush(_ query: SCQuery, data: Dictionary<String, Any>, debug: Bool, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
            body[kAccessKey] = messageKey
        } else {
            body[kAccessKey] = accessKey
        }
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kMessage] = ["data": data]
        body[kDebug] = debug
        
        self.sendRequest(SCAPIRouter.sendPush(body).urlRequest) { (error, result) in
            if error == nil {
                if let int = result?["count"] as? Int {
                    callback(true, nil, int)
                } else {
                    callback(false, SCError.system("Unable to parse response"), nil)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    func sendPush(_ query: SCQuery, title: String, text: String, debug: Bool, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
            body[kAccessKey] = messageKey
        } else {
            body[kAccessKey] = accessKey
        }
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kDebug] = debug
        body[kMessage] = ["data": ["apns": ["aps": ["alert": ["title" : title, "body" : text ]]]]]
        
        self.sendRequest(SCAPIRouter.sendPush(body).urlRequest) { (error, result) in
            if error == nil {
                if let int = result?["count"] as? Int {
                    callback(true, nil, int)
                } else {
                    callback(false, SCError.system("Unable to parse response"), nil)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    
    func sendSms(_ query: SCQuery, text: String, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        if let sessionId = sessionId {
            body[kSessionId] = sessionId
            body[kAccessKey] = messageKey
        } else {
            body[kAccessKey] = accessKey
        }
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kMessage] = [kMessageText: text]
        
        self.sendRequest(SCAPIRouter.sendSms(body).urlRequest) { (error, result) in
            if error == nil {
                if let int = result?["count"] as? Int {
                    callback(true, nil, int)
                } else {
                    callback(false, SCError.system("Unable to parse response"), nil)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    
    
    // MARK: Script
    func runScript(scriptId: String?, scriptPath: String?, pool: [String: Any], debug: Bool, callback: @escaping (Bool, SCError?) -> Void) {
        var body = [String: Any]()
        
        if let path = scriptPath {
            body["isRunByPath"] = true
            body["path"] = path
        }
        
        if let id = scriptId {
            body["script"] = id
        }
        
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        if sessionId == nil && accessKey.isEmpty {
            body[kAccessKey] = scriptKey
        } else if let sessionId = sessionId {
            body[kSessionId] = sessionId
            body[kAccessKey] = scriptKey
        } else {
            body[kAccessKey] = accessKey
        }
        body[kPool] = pool
        body[kDebug] = debug //? NSNumber(value: true) : NSNumber(value: false)
        
        self.sendRequest(SCAPIRouter.scripts(body).urlRequest) { (error, result) in
            if error == nil {
                callback(true, nil)
            } else {
                callback(false, error)
            }
        }
    }
    
    func stat(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        self.sendRequest(SCAPIRouter.app(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["app"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Получение полной информации о приложении
    func app(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        self.sendRequest(SCAPIRouter.app(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["app"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Получение списка коллекций приложения и их настроек
    func collections(_ callback: @escaping (Bool, SCError?, [String: Any]?, [SCCollection]) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        self.sendRequest(SCAPIRouter.collections(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["collections"] as? [String: Any] {
                    var collectionsArray = [SCCollection]()
                    for (_, value) in dict {
                        if let d = value as? [String: Any] {
                            let coll = self.parseCollection(dict: d)
                            if coll != nil {
                                collectionsArray.append(coll!)
                            }
                        }
                    }
                    callback(true, nil, dict, collectionsArray)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result, [])
                }
            } else {
                callback(false, error, nil, [])
            }
        }
    }
    
    // Просмотр структуры и настроек конкретной коллекции.
    func getCollection(_ collection: String, callback: @escaping (Bool, SCError?, [String: Any]?, SCCollection?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollection] = collection
        
        self.sendRequest(SCAPIRouter.getCollection(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["collection"] as? [String: Any] {
                    callback(true, nil, result, self.parseCollection(dict: dict))
                } else {
                    callback(false, SCError.system("Unable to parse response"), result, nil)
                }
            } else {
                callback(false, error, nil, nil)
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
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollectionDictName] = [kCollectionName: name,
                                     kCollectionUseDocsACL: useDocsACL,
                                     kCollectionACL: ACLsettings.toDict()]
        
        self.sendRequest(SCAPIRouter.createCollection(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["collection"] as? [String: Any],
                    let collectionID = dict["id"] as? String {
                    callback(true, nil, dict, collectionID)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result, nil)
                }
            } else {
                callback(false, error, nil, nil)
            }
        }
    }
    
    // Изменение настроек коллекции
    func updateCollection(id: String, name: String?, useDocsACL: Bool, ACLsettings: ACL, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        var collectionDict : [String: Any] = ["id": id,
                                              kCollectionUseDocsACL: useDocsACL,
                                              kCollectionACL: ACLsettings.toDict()]
        if name != nil {
            collectionDict[kCollectionName] = name!
        }
        body["collection"] = collectionDict
        
        self.sendRequest(SCAPIRouter.updateCollection(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["collection"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
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
        
        self.sendRequest(SCAPIRouter.removeCollection(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
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
        
        self.sendRequest(SCAPIRouter.cloneCollection(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
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
        
        self.sendRequest(SCAPIRouter.createCollectionIndex(body).urlRequest) { (error, result) in
            if error == nil {
                callback(true, nil, result)
            } else {
                callback(false, error, nil)
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
        
        self.sendRequest(SCAPIRouter.deleteCollectionIndex(body).urlRequest) { (error, result) in
            if error == nil {
                callback(true, nil, result)
            } else {
                callback(false, error, nil)
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
        
        self.sendRequest(SCAPIRouter.createCollectonField(body).urlRequest) { (error, result) in
            if error == nil {
                callback(true, nil, result)
            } else {
                callback(false, error, nil)
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
        
        self.sendRequest(SCAPIRouter.deleteCollectonField(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["collection"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    //Изменение триггеров коллекции
    func updateCollectionTriggers(collectionName : String, triggers: Triggers, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kCollection] = collectionName
        body[kCollectionTriggersName] = triggers.toDict()
        
        self.sendRequest(SCAPIRouter.updateCollectionTriggers(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["triggers"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Получение списка папок и скриптов директории
    func getFoldersAndScriptsList(path: String, callback: @escaping (Bool, SCError?, [Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kFoldersPathName] = path
        
        self.sendRequest(SCAPIRouter.getFoldersAndScriptsList(body).urlRequest) { (error, result) in
            if error == nil {
                if let array = result?["items"] as? [Any] {
                    callback(true, nil, array)
                } else {
                    callback(false, SCError.system("Unable to parse response"), [])
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Создание новой папки
    func createFolder(path: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kFoldersPathName] = path
        
        self.sendRequest(SCAPIRouter.createFolder(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Удаление папки со всем содержимым
    func deleteFolder(path: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kFoldersPathName] = path
        
        self.sendRequest(SCAPIRouter.deleteFolder(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Получение скрипта
    func getScript(scriptId: String, callback: @escaping (Bool, SCError?, [String: Any]?, SCScript?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kScriptIDName] = scriptId
        
        self.sendRequest(SCAPIRouter.getScript(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["script"] as? [String: Any] {
                    callback(true, nil, dict, self.parseScript(dict: dict))
                } else {
                    callback(false, SCError.system("Unable to parse response"), result, nil)
                }
            } else {
                callback(false, error, nil, nil)
            }
        }
    }
    
    func parseScript(dict: [String: Any]) -> SCScript? {
        if let id = dict["_id"] as? String, let path = dict["path"] as? String {
            let script = SCScript(id: id)
            script.path = path
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
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        body[kScriptName] = [kScriptPath: script.path!,
                             kScriptName:script.name,
                             kScriptCode:script.code,
                             kScriptJobtype: script.jobType.rawValue,
                             kScriptJobStartAt: script.jobStartAt.apiValue,
                             kScriptDescription: script.description,
                             kScriptIsActiveJob: script.isActiveJob,
                             kScriptACL: script.ACL,
                             kScriptTimerSettings: script.repeatTimer.toDict()]
        
        self.sendRequest(SCAPIRouter.createScript(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["cloudCode"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Изменение скрипта
    func saveScript(script: SCScript, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kScriptIDName] = script.id!
        
        body[kScriptName] = [kScriptFilename:script.name,
                             kScriptCode:script.code,
                             kScriptJobtype: script.jobType.rawValue,
                             kScriptJobStartAt: script.jobStartAt.apiValue,
                             kScriptDescription: script.description,
                             kScriptIsActiveJob: script.isActiveJob,
                             kScriptACL: script.ACL,
                             kScriptTimerSettings: script.repeatTimer.toDict()]
        
        self.sendRequest(SCAPIRouter.saveScript(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["script"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Удаление скрипта
    func deleteScript(scriptId: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kScriptIDName] = scriptId
        
        self.sendRequest(SCAPIRouter.deleteScript(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
    }
    
    // Изменение бота
    func saveBot(bot: SCBot, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        body[kBotDictName] = ["_id": bot.id!,
                              kBotName:bot.name,
                              kBotTelegramBotId:bot.telegramBotId,
                              kBotScriptID: bot.scriptId,
                              kBotIsActive: bot.isActive]
        
        self.sendRequest(SCAPIRouter.saveBot(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
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
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        self.sendRequest(SCAPIRouter.getBots(body).urlRequest) { (error, result) in
            if error == nil {
                if let array = result?["items"] as? [Any] {
                    var botsArray = [SCBot]()
                    for value in array {
                        if let dict = value as? [String: Any],
                            let bot = self.parseBot(bot: dict) {
                            botsArray.append(bot)
                        }
                    }
                    callback(true, nil, botsArray)
                } else {
                    callback(false, SCError.system("Unable to parse response"), [])
                }
            } else {
                callback(false, error, [])
            }
        }
    }
    
    // Создание бота
    func createBot(bot: SCBot, callback: @escaping (Bool, SCError?, [String: Any]?, String?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        body[kBotDictName] = [kBotName: bot.name,
                              kBotTelegramBotId: bot.telegramBotId,
                              kBotScriptID: bot.scriptId,
                              kBotIsActive: bot.isActive]
        
        self.sendRequest(SCAPIRouter.createBot(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["bot"] as? [String: Any], let id = dict["_id"] as? String {
                    callback(true, nil, dict, id)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result, nil)
                }
            } else {
                callback(false, error, nil, nil)
            }
        }
    }
    
    // Удаление бота
    func deleteBot(botId: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        var body = [String: Any]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        body[kBotDictName] = ["_id": botId]
        
        self.sendRequest(SCAPIRouter.deleteBot(body).urlRequest) { (error, result) in
            if error == nil {
                if let dict = result?["result"] as? [String: Any] {
                    callback(true, nil, dict)
                } else {
                    callback(false, SCError.system("Unable to parse response"), result)
                }
            } else {
                callback(false, error, nil)
            }
        }
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

