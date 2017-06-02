//
//  User.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 06/11/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import Foundation

class User {
    static let sharedInstance = User() //singletone
    
    var id : String = ""
    var email : String = ""
    var password : String = ""
    var name : String = ""
    var token : String = ""
    var isBoss = false
    
    fileprivate init() {} //singletone
    
    func parseUser(userDictionary: [String:Any]?) {
        if let name = userDictionary?["username"] as? String,
            let id = userDictionary?["_id"] as? String,
            let email = userDictionary?["email"] as? String,
            let roles = userDictionary?["roles"] as? [String] {
            self.name = name
            self.id = id
            self.email = email
            if let roleId = roles.first {
                var scQuery = SCQuery(collection: "roles")
                scQuery.equalTo("_id", SCString(roleId))
                scQuery.find({ (success, error, result) in
                    if success, let role = (result?.values.first as? [String: Any])?["name"] as? String, role == "boss" {
                        self.isBoss = true
                    }
                })
            } else {
                self.isBoss = false
            }
        }
    }
    
    func saveTokenToServer() {
        var scQuery = SCQuery(collection: "devices")
        scQuery.equalTo("deviceId", SCString(token)) // one device - one user.
        scQuery.remove() {
            success, error, result in
            if success {
                let scObject = SCObject(collection: "devices")
                scObject.set(["userId": SCString(self.id),
                              "deviceType": SCString("ios"),
                              "deviceId": SCString(self.token)
                    ])
                scObject.save() {
                    success, error, result in
                    if success {
                        print("token saved.")
                    } else if error != nil {
                        print("token didnt saved! Error: \(error.debugDescription)")
                    }
                }
            } else {
                print("Error while updating device token, Error: \(error!)")
            }
        }
    }
    
    func removeTokenFromServer() {
        var scQuery = SCQuery(collection: "devices")
        scQuery.equalTo("deviceId", SCString(self.token)) // one device - one user.
        scQuery.remove() {
            success, error, result in
            if success {
                print("token removed")
            } else if error != nil {
                print("Error while updating device token, Error: \(error!)")
            }
        }

    }
    
    func clear() {
        id = ""
        email = ""
        password = ""
        name = ""
        isBoss = false
        token = ""
        
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "password")
        //remove token from server:
        removeTokenFromServer()
    }
    
    func saveCredentials(email: String, password: String) {
        self.email = email
        self.password = password
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    func getCredentials() -> Bool {
        guard let email = UserDefaults.standard.object(forKey: "email") as? String, email != "",
            let password = UserDefaults.standard.object(forKey: "password") as? String, password != "" else {
                return false
        }
        self.email = email
        self.password = password
        return true
    }
}

class IdAndName {
    var id : String = ""
    var name : String = ""
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}


