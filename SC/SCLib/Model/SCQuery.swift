//
//  SCQuery.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

public struct SCQuery {
    
    fileprivate let _collection: String
    public var collection: String {
        return _collection
    }
    
    fileprivate var _userQuery: [String: AnyObject]?
    public var userQuery: [String: AnyObject]? {
        return _userQuery
    }
    
    fileprivate var _operators: [String: SCOperator]?
    public var operators: [String: SCOperator]? {
        return _operators
    }
    
    fileprivate var _andOr: SCOperator?
    public var andOr: SCOperator? {
        return _andOr
    }
    
    fileprivate var _limit: Int?
    public var limit: Int? {
        return _limit
    }
    
    fileprivate var _skip: Int?
    public var skip: Int? {
        return _skip
    }
    
    fileprivate var _sort: [String: Int]?
    public var sort: [String: Int]? {
        return _sort
    }
    
    fileprivate var _fields: [String]?
    public var fields: [String]? {
        return _fields
    }
        
    public init(collection: String) {
        self._collection = collection
    }
    
    // Поиск документов, на основе сформированного условия выборки. Возвращает ошибку или массив документов.
    public func find(_ callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {

        SCAPI.sharedInstance.find(self, callback: callback)
    }
    
    // Подсчет количества документов в коллекции согласно условию выборки.
    public func count(_ callback: @escaping (Bool, SCError?, Int?) -> Void) {
        
        SCAPI.sharedInstance.count(self, callback: callback)
    }
    
    // Обновляет документы соответствующие условию выборки.
    public func update(_ update: SCUpdate, callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        SCAPI.sharedInstance.update(self, update: update, callback: callback)
    }
    
    // Удаляет документы соответствующие условию выборки.
    public func remove(_ callback: @escaping (Bool, SCError?, [String: AnyObject]?) -> Void) {
        
        SCAPI.sharedInstance.remove(self, callback: callback)
    }
    
    // Устанавливает лимит выборки (параметр limit протокола).
    public mutating func limit(_ limit: Int) {
        _limit = limit
    }
    
    // Метод для установки количества пропускаемых документов (параметр skip протокола).
    public mutating func skip(_ skip: Int) {
        _skip = skip
    }
    
    // Метод для рассчета skip, соответствующего номеру страницы на основе установленного значения limit.
    public mutating func page(_ page: Int) {
        guard page > 0 else { return }
        if let limit = _limit {
            _skip = (page - 1) * limit
        } else {
            _skip = 0
        }
    }
    
    // Установка пользовательского условия выборки
    public mutating func raw(_ json: String) {
        
        if let dataFromString = json.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            _userQuery = json.dictionaryObject as [String : AnyObject]?
        }
    }
    
    // Очистка условий выборки
    public mutating func reset() {
        _operators = nil
        _userQuery = nil
        _sort = nil
        _fields = nil
        _andOr = nil
    }
    
    // Сортировка по полю по возрастанию (параметр sort протокола)
    public mutating func ascending(_ name: String) {
        if _sort == nil {
            _sort = [String: Int]()
        }
        _sort![name] = 1
    }
    
    // Сортировка по полю по убыванию (параметр sort протокола)
    public mutating func descending(_ name: String) {
        if _sort == nil {
            _sort = [String: Int]()
        }
        _sort![name] = -1
    }
    
    // Установка списка возвращаемых полей (параметр fields протокола)
    public mutating func fields(_ names: [String]) {
        _fields = names
    }
    
    public mutating func addOperator(_ name: String, oper: SCOperator) {
        if _operators == nil {
            _operators = [String: SCOperator]()
        }
        _operators![name] = oper
    }
    
    public mutating func equalTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.equalTo(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func notEqualTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.notEqualTo(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func containedIn(_ name: String, _ value: SCArray) {
        let op = SCOperator.containedIn(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func containsAll(_ name: String, _ value: SCArray) {
        let op = SCOperator.containsAll(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func notContainedIn(_ name: String, _ value: SCArray) {
        let op = SCOperator.notContainedIn(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func greaterThan(_ name: String, _ value: SCValue) {
        let op = SCOperator.greaterThan(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func greaterThanOrEqualTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.greaterThanOrEqualTo(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func lessThan(_ name: String, _ value: SCValue) {
        let op = SCOperator.lessThan(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func lessThanOrEqualTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.lessThanOrEqualTo(name, value)
        addOperator(name, oper: op)
    }
    
    public mutating func exists(_ name: String) {
        let op = SCOperator.exists(name)
        addOperator(name, oper: op)
    }
    
    public mutating func doesNotExist(_ name: String) {
        let op = SCOperator.doesNotExist(name)
        addOperator(name, oper: op)
    }
    
    public mutating func contains(_ name: String, _ pattern: String) {
        let op = SCOperator.contains(name, pattern, "")
        addOperator(name, oper: op)
    }
    
    public mutating func startsWith(_ name: String, _ pattern: String) {
        let op = SCOperator.startsWith(name, pattern, "")
        addOperator(name, oper: op)
    }
    
    public mutating func endsWith(_ name: String, _ pattern: String) {
        let op = SCOperator.endsWith(name, pattern, "")
        addOperator(name, oper: op)
    }
    
    public mutating func and(_ operators: [SCOperator]) {
        let op = SCOperator.and(operators)
        _andOr = op
    }
    
    public mutating func or(_ operators: [SCOperator]) {
        let op = SCOperator.or(operators)
        _andOr = op
    }
    
}
