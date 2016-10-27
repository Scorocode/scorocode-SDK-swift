//
//  SCUpdate.swift
//  SC
//
//  Created by Aleksandr Konakov on 09/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

public struct SCUpdate {
    
    fileprivate var _operators = [SCUpdateOperator]()
    public var operators: [SCUpdateOperator] {
        return _operators
    }

    public mutating func addOperator(_ oper: SCUpdateOperator) {
        _operators.append(oper)
    }

    public mutating func set(_ dic: [String: SCValue]) {
        let op = SCUpdateOperator.set(dic)
        addOperator(op)
    }

    
    public mutating func push(_ name: String, _ value: SCValue) {
        let op = SCUpdateOperator.push(name: name, value: value, each: false)
        addOperator(op)
    }
    
    public mutating func pushEach(_ name: String, _ value: SCValue) {
        guard value is SCArray else {
            print("Wrong value type - should be SCArray")
            return
        }
        
        let op = SCUpdateOperator.push(name: name, value: value, each: true)
        addOperator(op)
    }
    
    public mutating func pull(_ name: String, _ value: SCPullable) {
        let op = SCUpdateOperator.pull(name, value)
        addOperator(op)
    }

    public mutating func pullAll(_ name: String, _ value: SCValue) {
        guard value is SCArray else {
            print("Wrong value type - should be SCArray")
            return
        }
        
        let op = SCUpdateOperator.pullAll(name, value)
        addOperator(op)
    }
    
    public mutating func addToSet(_ name: String, _ value: SCValue) {
        let op = SCUpdateOperator.addToSet(name: name, value: value, each: false)
        addOperator(op)
    }
    
    public mutating func addToSetEach(_ name: String, _ value: SCValue) {
        let op = SCUpdateOperator.addToSet(name: name, value: value, each: true)
        addOperator(op)
    }
    
    public mutating func pop(_ name: String, _ value: Int) {
        guard value == 1 || value == -1 else {
            print("Wrong value")
            return
        }
        let op = SCUpdateOperator.pop(name, value)
        addOperator(op)
    }
    
    public mutating func inc(_ name: String, _ value: SCValue) {
        guard value is SCDouble || value is SCInt else {
            print("Wrong value type")
            return
        }
        let op = SCUpdateOperator.inc(name, value)
        addOperator(op)
    }
    
    public mutating func currentDate(_ name: String, typeSpec: String) {
        guard typeSpec == "date" || typeSpec == "timestamp" else {
            print("Wrong type specification")
            return
        }
        let op = SCUpdateOperator.currentDate(name, typeSpec)
        addOperator(op)
    }

    public mutating func mul(_ name: String, _ value: SCValue) {
        guard value is SCDouble || value is SCInt else {
            print("Wrong value type")
            return
        }
        let op = SCUpdateOperator.mul(name, value)
        addOperator(op)
    }

    public mutating func min(_ name: String, _ value: SCValue) {
        let op = SCUpdateOperator.min(name, value)
        addOperator(op)
    }
    
    public mutating func max(_ name: String, _ value: SCValue) {
        let op = SCUpdateOperator.max(name, value)
        addOperator(op)
    }
    
}
