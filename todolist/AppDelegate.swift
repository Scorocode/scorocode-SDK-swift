//
//  AppDelegate.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 25/10/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let user = User.sharedInstance
    var alerts = [String]()
    var alertActive = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //push
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            application.registerUserNotificationSettings(pushNotificationSettings)
            application.registerForRemoteNotifications()
        }
        
        //scorocode init
        let applicationId = "0b0adf87cf064d118f2df6ca485937af"
        let clientId = "adeb3bf8810d388bbf57dede2812f3ee"
        let accessKey = "b28b2afa05e14ad481aa358b23210a73"
        let fileKey = "3824781938324a8a81025d7e6594d901"
        let messageKey = "9de581f126354bf2bf304f3dd7af2142"
        SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
        
        // Check if launched from notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]  {
            performActionOnPushNotification(userInfo: notification as! [NSObject : AnyObject])
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0;
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        user.token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("DEVICE TOKEN = \(user.token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Received notification: \(userInfo)")
        performActionOnPushNotification(userInfo: userInfo)
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        print("Received notification: \(userInfo)");
        performActionOnPushNotification(userInfo: userInfo)
    }
 
    func performActionOnPushNotification(userInfo: [NSObject : AnyObject]) {
        print("receive an push, notification, trying to parse...")
        if let aps = userInfo[("aps" as NSString)] as? [String: Any] {
            if let alert = aps["alert"] as? String {
                alerts.append(alert)
                if !alertActive {
                    showNotificationInAlert()
                }
            }
        }
    }
    
    func showNotificationInAlert() {
        if alerts.count > 0 {
            let text = alerts[0]
            let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: {action in
                self.alerts.remove(at: 0)
                self.showNotificationInAlert()
            })
            alert.addAction(ok)
            let navigationController = UIApplication.shared.windows[0].rootViewController as? UINavigationController
            let activeViewCont = navigationController!.visibleViewController!
            activeViewCont.present(alert, animated: true, completion: nil)
            alertActive = true
        } else {
            alertActive = false
        }
    }
}

// Receive displayed notifications for iOS 10 devices.
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received notification: \(userInfo)");
        performActionOnPushNotification(userInfo: userInfo as [NSObject : AnyObject])
        
    }
}


