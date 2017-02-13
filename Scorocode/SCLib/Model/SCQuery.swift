//
//  SCQuery.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct SCQuery {
    
    fileprivate let _collection: String
    var collection: String {
        return _collection
    }
    
    fileprivate var _userQuery: [String: Any]?
    var userQuery: [String: Any]? {
        return _userQuery
    }
    
    fileprivate var _operators: [String: SCOperator]?
    var operators: [String: SCOperator]? {
        return _operators
    }
    
    fileprivate var _andOr: SCOperator?
    var andOr: SCOperator? {
        return _andOr
    }
    
    fileprivate var _limit: Int?
    var limit: Int? {
        return _limit
    }
    
    fileprivate var _skip: Int?
    var skip: Int? {
        return _skip
    }
    
    fileprivate var _sort: [String: Int]?
    var sort: [String: Int]? {
        return _sort
    }
    
    fileprivate var _fields: [String]?
    var fields: [String]? {
        return _fields
    }
        
    init(collection: String) {
        self._collection = collection
    }
    
    // Поиск документов, на основе сформированного условия выборки. Возвращает ошибку или массив документов.
    func find(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {

        SCAPI.sharedInstance.find(self, callback: callback)
    }
    
    // Подсчет количества документов в коллекции согласно условию выборки.
    func count(_ callback: @escaping (Bool, SCError?, Int?) -> Void) {
        
        SCAPI.sharedInstance.count(self, callback: callback)
    }
    
    // Обновляет документы соответствующие условию выборки.
    func update(_ update: SCUpdate, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        SCAPI.sharedInstance.update(self, update: update, callback: callback)
    }
    
    // Удаляет документы соответствующие условию выборки.
    func remove(_ callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        
        SCAPI.sharedInstance.remove(self, callback: callback)
    }
    
    // Устанавливает лимит выборки (параметр limit протокола).
    mutating func limit(_ limit: Int) {
        _limit = limit
    }
    
    // Метод для установки количества пропускаемых документов (параметр skip протокола).
    mutating func skip(_ skip: Int) {
        _skip = skip
    }
    
    // Метод для рассчета skip, соответствующего номеру страницы на основе установленного значения limit.
    mutating func page(_ page: Int) {
        guard page > 0 else { return }
        if let limit = _limit {
            _skip = (page - 1) * limit
        } else {
            _skip = 0
        }
    }
    
    // Установка пользовательского условия выборки
    mutating func raw(_ json: String) {
        
        if let dataFromString = json.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            _userQuery = json.dictionaryObject as [String : Any]?
        }
    }
    
    // Очистка условий выборки
    mutating func reset() {
        _operators = nil
        _userQuery = nil
        _sort = nil
        _fields = nil
        _andOr = nil
    }
    
    // Сортировка по полю по возрастанию (параметр sort протокола)
    mutating func ascending(_ name: String) {
        if _sort == nil {
            _sort = [String: Int]()
        }
        _sort![name] = 1
    }
    
    // Сортировка по полю по убыванию (параметр sort протокола)
    mutating func descending(_ name: String) {
        if _sort == nil {
            _sort = [String: Int]()
        }
        _sort![name] = -1
    }
    
    // Установка списка возвращаемых полей (параметр fields протокола)
    mutating func fields(_ names: [String]) {
        _fields = names
    }
    
    mutating func addOperator(_ name: String, oper: SCOperator) {
        if _operators == nil {
            _operators = [String: SCOperator]()
        }
        _operators![name] = oper
    }
    
    mutating func equalTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.equalTo(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func notEqualTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.notEqualTo(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func containedIn(_ name: String, _ value: SCArray) {
        let op = SCOperator.containedIn(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func containsAll(_ name: String, _ value: SCArray) {
        let op = SCOperator.containsAll(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func notContainedIn(_ name: String, _ value: SCArray) {
        let op = SCOperator.notContainedIn(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func greaterThan(_ name: String, _ value: SCValue) {
        let op = SCOperator.greaterThan(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func greaterThanOrEqualTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.greaterThanOrEqualTo(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func lessThan(_ name: String, _ value: SCValue) {
        let op = SCOperator.lessThan(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func lessThanOrEqualTo(_ name: String, _ value: SCValue) {
        let op = SCOperator.lessThanOrEqualTo(name, value)
        addOperator(name, oper: op)
    }
    
    mutating func exists(_ name: String) {
        let op = SCOperator.exists(name)
        addOperator(name, oper: op)
    }
    
    mutating func doesNotExist(_ name: String) {
        let op = SCOperator.doesNotExist(name)
        addOperator(name, oper: op)
    }
    
    mutating func contains(_ name: String, _ pattern: String) {
        let op = SCOperator.contains(name, pattern, "")
        addOperator(name, oper: op)
    }
    
    mutating func startsWith(_ name: String, _ pattern: String) {
        let op = SCOperator.startsWith(name, pattern, "")
        addOperator(name, oper: op)
    }
    
    mutating func endsWith(_ name: String, _ pattern: String) {
        let op = SCOperator.endsWith(name, pattern, "")
        addOperator(name, oper: op)
    }
    
    mutating func and(_ operators: [SCOperator]) {
        let op = SCOperator.and(operators)
        _andOr = op
    }
    
    mutating func or(_ operators: [SCOperator]) {
        let op = SCOperator.or(operators)
        _andOr = op
    }
    
}
