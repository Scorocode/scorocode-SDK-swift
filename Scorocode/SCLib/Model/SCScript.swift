//
//  SCScript.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public enum ScriptJobType : String {
    case custom = "custom"
    case daily = "daily"
    case monthly = "monthly"
    case once = "once"
}

public struct RepeatTimer {
    fileprivate let kRepeatTimerCustomName = "custom"
    fileprivate let kRepeatTimerDailyName = "daily"
    fileprivate let kRepeatTimerMonthlyName = "monthly"
    
    public var custom = _custom()
    public var daily = _daily()
    public var monthly = _monthly()
    
    public struct _custom {
        public var days = 0
        public var hours = 0
        public var minutes = 0
        
        func toDict() -> [String: Any] {
            return ["days": self.days, "hours": self.hours, "minutes": self.minutes]
        }
    }
    
    public struct _daily {
        public var on = [Int]()
        public var hours = 0
        public var minutes = 0
        
        func toDict() -> [String: Any] {
            return ["on": self.on, "hours": self.hours, "minutes": self.minutes]
        }
    }
    
    public struct _monthly {
        public var on = [Int]()
        public var days = [Int]()
        public var lastDate = false
        public var hours = 0
        public var minutes = 0
        
        func toDict() -> [String: Any] {
            return ["on": self.on, "days": self.days, "lastDate": self.lastDate, "hours": self.hours, "minutes": self.minutes]
        }
    }
    
    public func toDict() -> [String: Any] {
        var dict = [String: Any]()
        dict.updateValue(self.custom.toDict(), forKey: kRepeatTimerCustomName)
        dict.updateValue(self.daily.toDict(), forKey: kRepeatTimerDailyName)
        dict.updateValue(self.monthly.toDict(), forKey: kRepeatTimerMonthlyName)
        return dict
    }
}

public class SCScript {
    
    public var id: String?
    public var path: String?
    
    public var name = ""
    public var description = ""
    public var code = ""
    public var jobStartAt = SCDate(Date())
    public var isActiveJob = false
    public var jobType: ScriptJobType?
    public var ACL = [String]()
    public var repeatTimer = RepeatTimer()
    
    public init(id: String?, path: String?) {
        self.path = path
        self.id = id
    }
    
    public convenience init(path: String) {
        self.init(id: nil, path: path)
    }
    
    public convenience init(id: String) {
        self.init(id: id, path: nil)
    }
    // Запуск скрипта
    public func run(pool: [String: AnyObject], debug: Bool, callback: @escaping (Bool, SCError?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id скрипта не задан."))
            return
        }
        SCAPI.sharedInstance.runScript(self.id!, pool: pool, debug: debug, callback: callback)
    }
    
    // Получение скрипта
    public func load(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id скрипта не задан."), nil)
            return
        }
        SCAPI.sharedInstance.getScript(scriptId: self.id!) { (success, error, result, script) in
            if script != nil {
                self.path = script?.path ?? ""
                self.name = script?.name ?? ""
                self.description = script?.description ?? ""
                self.code = script?.code ?? ""
                self.jobStartAt = script?.jobStartAt ?? SCDate(Date())
                self.isActiveJob = script?.isActiveJob ?? false
                self.jobType = script?.jobType ?? nil
                self.ACL = script?.ACL ?? [String]()
                self.repeatTimer = script?.repeatTimer ?? RepeatTimer()
            }
            callback(success, error, result)
        }
    }
    
    // Создание нового скрипта
    public func create(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.path != nil else {
            callback(false, SCError.system("путь скрипта не задан."), nil)
            return
        }
        SCAPI.sharedInstance.createScript(script: self, callback: callback)
    }
    
    // Изменение скрипта
    public func save(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id скрипта не задан."), nil)
            return
        }
        SCAPI.sharedInstance.saveScript(script: self, callback: callback)
    }
    
    // Удаление скрипта
    public func delete(callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        guard self.id != nil else {
            callback(false, SCError.system("id скрипта не задан."), nil)
            return
        }
        SCAPI.sharedInstance.deleteScript(scriptId: self.id!, callback: callback)
    }
    
    
}
