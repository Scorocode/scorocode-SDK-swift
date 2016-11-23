//
//  AppDelegate.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let applicationId = ""
        let clientId = ""
        let accessKey = ""
        let fileKey = ""
        let messageKey = ""
        
        SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
        
        return true
    }

}

