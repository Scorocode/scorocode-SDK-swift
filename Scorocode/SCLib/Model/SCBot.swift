//
//  SCBot.swift
//  Scorocode
//
//  Created by Alexey Kuznetsov on 20.04.17.
//  Copyright © 2017 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public class SCBot {
    
    public var id: String?
    public var name = ""
    
    public var telegramBotId = ""
    public var scriptId = ""
    public var isActive = false
    
    public init(id: String?, name: String) {
        self.name = name
        self.id = id
    }
    
    public convenience init(name: String) {
        self.init(id: nil, name: name)
    }
    
    // Изменение бота
    public func save(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id бота не задан."), nil)
            return
        }
        SCAPI.sharedInstance.saveBot(bot: self, callback: callback)
    }
    
    // Создание бота
    public func create(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.name != "", self.telegramBotId != "", self.scriptId != "" else {
            callback(false, SCError.system("Имя бота, телеграм-токен и идентификатор серверного скрипта должны быть заданы! "), nil)
            return
        }
        SCAPI.sharedInstance.createBot(bot: self) { (success, error, result, id) in
            if id != nil {
                self.id = id
            }
            callback(success, error, result)
        }
    }
    
    // Удаление бота
    public func delete(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id бота не задан."), nil)
            return
        }
        SCAPI.sharedInstance.deleteBot(botId: self.id!, callback: callback)
    }
}
