//
//  SC.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

class SC {
    
    class func initWith(applicationId: String, clientId: String, accessKey: String, fileKey: String, messageKey: String) {
        SCAPI.sharedInstance.applicationId = applicationId
        SCAPI.sharedInstance.clientId = clientId
        SCAPI.sharedInstance.accessKey = accessKey
        SCAPI.sharedInstance.fileKey = fileKey
        SCAPI.sharedInstance.messageKey = messageKey
    }
    
}
