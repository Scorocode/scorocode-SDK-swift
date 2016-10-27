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

public enum SCError {
    case system(String)
    case api(String, String)
}

open class SCAPI {
    
    fileprivate let kApplicationId = "app"
    fileprivate let kClientKey = "cli"
    fileprivate let kAccessKey = "acc"
    fileprivate let kUsername = "username"
    fileprivate let kEmail = "email"
    fileprivate let kPassword = "password"
    fileprivate let kSessionId = "sess"
    fileprivate let kCollection = "coll"
    fileprivate let kMessage = "msg"
    fileprivate let kMessageSubject = "subject"
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
    
    open static let sharedInstance = SCAPI()
    
    internal var applicationId = ""
    internal var clientId = ""
    internal var accessKey = ""
    internal var fileKey = ""
    internal var messageKey = ""
    
    open var sessionId: String!
  
    open func login(_ email: String, password: String, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kEmail] = email
        body[kPassword] = password
        
        Alamofire.request(SCAPIRouter.login(body as [String : AnyObject])).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let result = response["result"].dictionaryValue
                    if let sessionId = result["sessionId"] {
                        self.sessionId = sessionId.stringValue
                        callback(true, nil, response["result"].dictionaryObject as [String : AnyObject]?)
                    }
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
        
    }
    
    open func logout(_ callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: String]()
        body[kApplicationId] = applicationId
        body[kClientKey] = clientId
        body[kSessionId] = sessionId
        
        Alamofire.request(SCAPIRouter.logout(body as [String : AnyObject])).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    open func register(_ username: String, email: String, password: String, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kUsername] = username as AnyObject?
        body[kEmail] = email as AnyObject?
        body[kPassword] = password as AnyObject?
        
        Alamofire.request(SCAPIRouter.register(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject as [String : AnyObject]?)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
  
    open func insert(_ doc: SCObject, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = doc.collection as AnyObject?
        body[kDoc] = doc.update.operators[0].dic
        
        Alamofire.request(SCAPIRouter.insert(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject as [String : AnyObject]?)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func remove(_ query: SCQuery, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = query.collection as AnyObject?
        body[kQuery] = makeBodyQuery(query) as AnyObject?
        
        if let limit = query.limit {
            body[kLimit] = limit as AnyObject?
        }
        
        Alamofire.request(SCAPIRouter.remove(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject as [String : AnyObject]?)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func update(_ query: SCQuery, update: SCUpdate, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = query.collection as AnyObject?
        body[kQuery] = makeBodyQuery(query) as AnyObject?
        body[kDoc] = makeBodyDoc(update) as AnyObject?
        
        Alamofire.request(SCAPIRouter.update(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject as [String : AnyObject]?)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func updateById(_ obj: SCObject, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = obj.collection as AnyObject?
        _ = obj.id!
        body[kQuery] = ["_id" : obj.id!] as AnyObject?
        body[kDoc] = makeBodyDoc(obj.update) as AnyObject?
        
        Alamofire.request(SCAPIRouter.updateById(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let result = response["result"].dictionaryObject
                    callback(true, nil, result as [String : AnyObject]?)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func find(_ query: SCQuery, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = query.collection as AnyObject?
        body[kQuery] = makeBodyQuery(query) as AnyObject?
        
        if let sort = query.sort {
            body[kSort] = sort as AnyObject?
        }
        
        if let fields = query.fields {
            body[kFields] = fields as AnyObject?
        }
        
        if let skip = query.skip {
            body[kSkip] = skip as AnyObject?
        }
        
        if let limit = query.limit {
            body[kLimit] = limit as AnyObject?
        }
        
        
        Alamofire.request(SCAPIRouter.find(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    let base64String = response["result"].stringValue
                    let data = Data(base64Encoded: base64String.data(using: String.Encoding.utf8)!, options: NSData.Base64DecodingOptions())
                    let decodedData = (data! as NSData).bsonValue()
                    let dictionary = decodedData as! [String : AnyObject]
                    callback(true, nil, dictionary)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func count(_ query: SCQuery, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = query.collection as AnyObject?
        body[kQuery] = makeBodyQuery(query) as AnyObject?
        
        Alamofire.request(SCAPIRouter.count(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func getFile(_ collection: String, field: String, filename: String, callback: (Bool, SCError?) -> Void) {
        var localPath: URL? = nil
        let downloadRequest = Alamofire.download(SCAPIRouter.getFile(collection, field, filename) as! URLConvertible, method: .get) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let pathComponent = response.suggestedFilename
            
            localPath = directoryURL.appendingPathComponent(pathComponent!)
            return (localPath!, DownloadRequest.DownloadOptions.createIntermediateDirectories)
        }
        downloadRequest.downloadProgress { (progress) in
            DispatchQueue.main.async {
                print("Total bytes read on main queue: \(progress.totalUnitCount)")
            }
        }.response { (response) in
            if let error = response.error {
                print("Failed with error: \(error)")
            }
            else {
                print("Downloaded file successfully")
            }
        }
    }
    
    open func getFileLink(_ collection: String, fieldName: String, filename: String, callback: @escaping (Bool, SCError?, URL?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kCollection] = collection as AnyObject?
        body[kField] = fieldName as AnyObject?
        body[kFile] = filename as AnyObject?
        
        Alamofire.request(SCAPIRouter.getFileLink(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].URL as URL?)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    // MARK: File
    open func upload(_ field: String, filename: String, data: String, docId: String,  collection: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = collection as AnyObject?
        body[kDocId] = docId as AnyObject?
        body[kField] = field as AnyObject?
        body[kContent] = data as AnyObject?
        body[kFile] = filename as AnyObject?
        
        Alamofire.request(SCAPIRouter.upload(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    open func deleteFile(_ field: String, filename: String, docId: String, collection: String, callback: @escaping (Bool, SCError?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = collection as AnyObject?
        body[kDocId] = docId as AnyObject?
        body[kField] = field as AnyObject?
        body[kFile] = filename as AnyObject?
        
        Alamofire.request(SCAPIRouter.deleteFile(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
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
    open func sendEmail(_ query: SCQuery, subject: String, text: String, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = query.collection as AnyObject?
        body[kQuery] = makeBodyQuery(query) as AnyObject?
        body[kMessage] = makeMessage(subject, text: text) as AnyObject?
        
        Alamofire.request(SCAPIRouter.sendEmail(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["count"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func sendPush(_ query: SCQuery, subject: String, text: String, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = query.collection as AnyObject?
        body[kQuery] = makeBodyQuery(query) as AnyObject?
        body[kMessage] = makeMessage(subject, text: text) as AnyObject?
        
        
        Alamofire.request(SCAPIRouter.sendPush(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["count"].intValue)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func sendSms(_ query: SCQuery, subject: String, text: String, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kSessionId] = sessionId as AnyObject?
        body[kCollection] = query.collection as AnyObject?
        body[kQuery] = makeBodyQuery(query) as AnyObject?
        body[kMessage] = makeMessage(subject, text: text) as AnyObject?
        
        
        Alamofire.request(SCAPIRouter.sendSms(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
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
    open func scripts(_ scriptId: String, pool: [String: AnyObject], callback: @escaping (Bool, SCError?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        body[kScript] = scriptId as AnyObject?
        body[kPool] = pool as AnyObject?
        
        Alamofire.request(SCAPIRouter.scripts(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil)
                } else {
                    callback(false, self.makeError(response))
                }
            }
        }
    }
    
    open func stat(_ callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        var body = [String: AnyObject]()
        body[kApplicationId] = applicationId as AnyObject?
        body[kClientKey] = clientId as AnyObject?
        body[kAccessKey] = accessKey as AnyObject?
        
        Alamofire.request(SCAPIRouter.stat(body)).responseJSON() {
            responseJSON in
            guard responseJSON.result.error == nil else {
                print(responseJSON.result.error)
                let error = SCError.system((responseJSON.result.error?.localizedDescription)!)
                callback(false, error, nil)
                return
            }
            
            if let responseValue: AnyObject = responseJSON.result.value as AnyObject? {
                let response = JSON(responseValue)
                if !response["error"].boolValue {
                    callback(true, nil, response["result"].dictionaryObject as [String : AnyObject]?)
                } else {
                    callback(false, self.makeError(response), nil)
                }
            }
        }
    }
    
    open func makeError(_ response: JSON) -> SCError {
        let errCode = response["errCode"].stringValue
        let errMsg = response["errMsg"].stringValue
        return SCError.api(errCode, errMsg)
    }
    
    open func makeMessage(_ subject: String, text: String) -> [String: String] {
        return [kMessageSubject: subject, kMessageText: text]
    }
    
    open func makeBodyDoc(_ update: SCUpdate) -> [String: AnyObject] {
        var result = [String: AnyObject]()
        for op in update.operators {
            result[op.name] = op.dic
        }
        return result
    }
    
    open func makeBodyQuery(_ query: SCQuery) -> [String: AnyObject] {
        
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
