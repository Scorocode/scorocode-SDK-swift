//
//  SCUser.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

class SCUser: SCObject {
    
    init() {
        super.init(collection: "users", id: nil)
    }
    
    // Аутентификация пользователя приложения
    func login(_ email: String, password: String, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        SCAPI.sharedInstance.login(email, password: password, callback: callback)
    }
    
    // Завершение активной сессии пользователя
    static func logout(_ callback: (Bool, SCError?) -> Void) {
        
        SCAPI.sharedInstance.logout(callback)
    }
    
    // Метод для регистрации нового пользователя в приложении. Поля устанавливаются методами родительского класса Object.
    func signup(_ callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        guard let username = get("username") as? String,
            let email = get("email") as? String,
            let password = get("password") as? String else { return }
        
        signup(username, email: email, password: password, callback: callback)
    }
    
    func signup(_ username: String, email: String, password: String, callback: (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        SCAPI.sharedInstance.register(username, email: email, password: password, callback: callback)
    }
    
}
