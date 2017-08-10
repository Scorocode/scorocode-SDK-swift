//
//  SCUser.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public class SCUser: SCObject {
    
    public init() {
        super.init(collection: "users", id: nil)
    }
    
    // Аутентификация пользователя приложения
    public func login(_ email: String, password: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        SCAPI.sharedInstance.login(email, password: password, callback: callback)
    }
    
    // Завершение активной сессии пользователя
    public func logout(_ callback: @escaping (Bool, SCError?) -> Void) {
        
        SCAPI.sharedInstance.logout(callback)
    }
    
    // Метод для регистрации нового пользователя в приложении. Поля устанавливаются методами родительского класса Object.
    public func signup(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard let username = get("username") as? String,
            let email = get("email") as? String,
            let password = get("password") as? String else { return }
        
        signup(username, email: email, password: password, callback: callback)
    }
    
    public func signup(_ username: String, email: String, password: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        SCAPI.sharedInstance.register(username, email: email, password: password, callback: callback)
    }
    
}
