//
//  SCAPI.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum SCError {
    case System(String)
    case API(String, String)
}

class SCAPI {
    
    private let kApplicationId = "app"
    private let kClientKey = "cli"
    private let kAccessKey = "acc"
    private let kUsername = "username"
    private let kEmail = "email"
    private let kPassword = "password"
    private let kSessionId = "sess"
    private let kCollection = "coll"
    private let kMessage = "msg"
    private let kMessageSubject = "subject"
    private let kMessageText = "text"
    private let kQuery = "query"
    private let kDoc = "doc"
    private let kSort = "sort"
    private let kFields = "fields"
    private let kLimit = "limit"
    private let kSkip = "skip"
    private let kScript = "script"
    private let kPool = "pool"
    private let kDocId = "docId"
    private let kField = "field"
    private let kFile = "file"
    private let kContent = "content"
    
    static let sharedInstance = SCAPI()
    
    internal var applicationId = ""
    internal var clientId = ""
    internal var accessKey = ""
    internal var fileKey = ""
    internal var messageKey = ""
    
    var sessionId: String!
    
    // MARK: User
    func login(email: String, password: String, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kEmail] = email
        body[kPassword] = password
        
        Alamofire.request(SCAPIRouter.Login(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
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
    
    func logout(callback: (Bool, SCError?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kSessionId] = sessionId
        
        Alamofire.request(SCAPIRouter.Logout(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    func register(username: String, email: String, password: String, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kUsername] = username
        body[kEmail] = email
        body[kPassword] = password
        
        Alamofire.request(SCAPIRouter.Register(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
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
    func insert(doc: SCObject, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kSessionId] = sessionId
        body[kCollection] = doc.collection

//        var bodyDoc = [String: AnyObject]()
//
//        for setter in doc.update.operators {
//            let key = setter.dic.allKeys[0] as! String
//            let value = setter.dic.allValues[0]
//            bodyDoc[key] = value
//        }
//        body[kDoc] = bodyDoc
        
        body[kDoc] = doc.update.operators[0].dic
        
        Alamofire.request(SCAPIRouter.Insert(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func remove(query: SCQuery, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        
        if let limit = query.limit {
            body[kLimit] = limit
        }
        
        Alamofire.request(SCAPIRouter.Remove(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func update(query: SCQuery, update: SCUpdate, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kDoc] = makeBodyDoc(update)
        
        Alamofire.request(SCAPIRouter.Update(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func updateById(obj: SCObject, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = obj.collection
        body[kQuery] = ["_id" : obj.id!]
        body[kDoc] = makeBodyDoc(obj.update)
        
        Alamofire.request(SCAPIRouter.UpdateById(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
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
    
    func find(query: SCQuery, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
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
        
        
        Alamofire.request(SCAPIRouter.Find(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let base64String = response["result"].stringValue
                    let data = NSData(base64EncodedData: base64String.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSDataBase64DecodingOptions())
                    let decodedData = data!.BSONValue()
                    let dictionary = decodedData as! [String : AnyObject]
                    callback(true, nil, dictionary)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func count(query: SCQuery, callback: (Bool, SCError?, Int?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        
        Alamofire.request(SCAPIRouter.Count(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func getFile(collection: String, field: String, filename: String, callback: (Bool, SCError?) -> Void) {
        
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        print("The file will be saved in \(destination)")
        Alamofire.download(SCAPIRouter.GetFile(collection, field, filename), destination: destination).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            dispatch_async(dispatch_get_main_queue()) {
                print("Total bytes read on main queue: \(totalBytesRead)")
            }
            }
            .response { _, _, _, error in
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                }
        }

    }
    
    func getFileLink(collection: String, fieldName: String, filename: String, callback: (Bool, SCError?, NSURL?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kCollection] = collection
        body[kField] = fieldName
        body[kFile] = filename
        
        Alamofire.request(SCAPIRouter.GetFileLink(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].URL)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // MARK: File
    func upload(field: String, filename: String, data: String, docId: String,  collection: String, callback: (Bool, SCError?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = collection
        body[kDocId] = docId
        body[kField] = field
        body[kContent] = data
        body[kFile] = filename
        
        Alamofire.request(SCAPIRouter.Upload(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    func deleteFile(field: String, filename: String, docId: String, collection: String, callback: (Bool, SCError?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = collection
        body[kDocId] = docId
        body[kField] = field
        body[kFile] = filename
        
        Alamofire.request(SCAPIRouter.DeleteFile(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
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
    func sendEmail(query: SCQuery, subject: String, text: String, callback: (Bool, SCError?, Int?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kMessage] = makeMessage(subject, text: text)
        
        Alamofire.request(SCAPIRouter.SendEmail(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["count"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func sendPush(query: SCQuery, subject: String, text: String, callback: (Bool, SCError?, Int?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kMessage] = makeMessage(subject, text: text)
        
        
        Alamofire.request(SCAPIRouter.SendPush(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["count"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func sendSms(query: SCQuery, subject: String, text: String, callback: (Bool, SCError?, Int?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kSessionId] = sessionId
        body[kCollection] = query.collection
        body[kQuery] = makeBodyQuery(query)
        body[kMessage] = makeMessage(subject, text: text)
        
        
        Alamofire.request(SCAPIRouter.SendSms(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
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
    func scripts(scriptId: String, pool: [String: AnyObject], callback: (Bool, SCError?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        body[kScript] = scriptId
        body[kPool] = pool
        
        Alamofire.request(SCAPIRouter.Scripts(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    func stat(callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kAccessKey] = accessKey
        
        Alamofire.request(SCAPIRouter.Stat(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.System((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    func makeError(response: JSON) -> SCError {
        let errCode = response["errCode"].stringValue
        let errMsg = response["errMsg"].stringValue
        return SCError.API(errCode, errMsg)
    }
    
    func makeMessage(subject: String, text: String) -> [String: String] {
        return [kMessageSubject: subject, kMessageText: text]
    }
    
    func makeBodyDoc(update: SCUpdate) -> [String: AnyObject] {
        var result = [String: AnyObject]()
        for op in update.operators {
            result[op.name] = op.dic
        }
        return result
    }
    
    func makeBodyQuery(query: SCQuery) -> [String: AnyObject] {
        
        if let userQuery = query.userQuery {
            return userQuery
        }
        
        var result = [String: AnyObject]()
        if let operators = query.operators {
            for (key, op) in operators {
                result[key] = op.dic
            }
        }
        if let andOr = query.andOr {
            switch andOr {
            case .And:
                result["$and"] = andOr.dic
            case .Or:
                result["$or"] = andOr.dic
            default:
                break
            }
        }

        return result
    }
    
}
