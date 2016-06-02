//
//  SC.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

class SC {
    
    class func initWith(applicationId applicationId: String, clientId: String, accessKey: String, fileKey: String, messageKey: String) {
        SCAPI.sharedInstance.applicationId = applicationId
        SCAPI.sharedInstance.clientId = clientId
        SCAPI.sharedInstance.accessKey = accessKey
        SCAPI.sharedInstance.fileKey = fileKey
        SCAPI.sharedInstance.messageKey = messageKey
    }
    
}