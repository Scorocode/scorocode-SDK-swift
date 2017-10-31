//
//  SC.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public class SC {
    
    public class func initWith(applicationId: String, clientId: String, accessKey: String, fileKey: String, messageKey: String, scriptKey: String) {
        
        SCAPI.sharedInstance.applicationId = applicationId
        SCAPI.sharedInstance.clientId = clientId
        SCAPI.sharedInstance.accessKey = accessKey
        SCAPI.sharedInstance.fileKey = fileKey
        SCAPI.sharedInstance.messageKey = messageKey
        SCAPI.sharedInstance.scriptKey = scriptKey
    }
    
    public class func getStat(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        SCAPI.sharedInstance.stat(callback)
    }
    
    public class func getInfo(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        SCAPI.sharedInstance.app(callback)
    }
    
    public class func getCollections(_ callback: @escaping (Bool, SCError?, [String: Any]?, [SCCollection]) -> Void) {
        SCAPI.sharedInstance.collections(callback)
    }
    
    public class func getBotsList(callback: @escaping (Bool, SCError?, [SCBot]) -> Void) {
        SCAPI.sharedInstance.getBots(callback: callback)
    }
    
    public class func getFoldersAndScriptsList(path: String, callback: @escaping (Bool, SCError?, [Any]?) -> Void) {
        SCAPI.sharedInstance.getFoldersAndScriptsList(path: path, callback: callback)
    }
}

