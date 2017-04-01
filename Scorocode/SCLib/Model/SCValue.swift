//
//  SCFieldType.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public protocol SCPullable {
    
}

public protocol SCValue: SCPullable {
    var apiValue: Any { get }
}

public struct SCBool: SCValue {
    let value: Bool
    
    public init(_ value: Bool) {
        self.value = value
    }

    public var apiValue: Any {
        return value as Any
    }
}

public struct SCString: SCValue {
    let value: String
    
    public init(_ value: String) {
        self.value = value
    }

    public var apiValue: Any {
        return value as Any
    }
}

public struct SCInt: SCValue {
    let value: Int
    
    public init(_ value: Int) {
        self.value = value
    }
    
    public var apiValue: Any {
        return value as Any
    }
}

public struct SCDouble: SCValue {
    let value: Double
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public var apiValue: Any {
        return value as Any
    }
}

public struct SCDate: SCValue {
    let value: Date
    
    public init(_ value: Date) {
        self.value = value
    }
    
    public var apiValue: Any {
        let en_US_POSIX = Locale(identifier: "en_US_POSIX")
        let rfc3339DateFormatter = DateFormatter()
        rfc3339DateFormatter.locale = en_US_POSIX
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
        rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return rfc3339DateFormatter.string(from: value) as Any
    }
}

public struct SCArray: SCValue {
    let value: [SCValue]
    
    public init(_ value: [SCValue]) {
        self.value = value
    }
    
    public var apiValue: Any {
        return value.map({ $0.apiValue })
    }
    
    public init(stringArray: [String]) {
        self.value = stringArray.map({SCString($0)})
    }
    
    public init(integerArray: [Int]) {
        self.value = integerArray.map({SCInt($0)})
    }
    
    public init(doubleArray: [Double]) {
        self.value = doubleArray.map({SCDouble($0)})
    }
    
    public init(boolArray: [Bool]) {
        self.value = boolArray.map({SCBool($0)})
    }
    
    public init(dateArray: [Date]) {
        self.value = dateArray.map({SCDate($0)})
    }
}

public struct SCDictionary: SCValue {
    let value: [String: SCValue]
    
    public init(_ value: [String: SCValue]) {
        self.value = value
    }
    
    public var apiValue: Any {
        var result = [String: Any]()
        for (key, val) in value {
            result[key] = val.apiValue
        }
        return result as Any
    }
}

public func == (lhs: [SCValue], rhs: [SCValue]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for (index, leftValue) in lhs.enumerated() {
        if leftValue != rhs[index] {
            return false
        }
    }
    return true
}

public func == (lhs: [String: SCValue], rhs: [String: SCValue]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for (key, leftValue) in lhs {
        if rhs[key] == nil || rhs[key]! != leftValue {
            return false
        }
    }
    return true
}


public func !=(lhs: SCValue, rhs: SCValue) -> Bool {
    return !(lhs == rhs)
}

public func ==(lhs: SCValue, rhs: SCValue) -> Bool {
    if lhs is SCBool && rhs is SCBool {
        return (lhs as! SCBool).value == (rhs as! SCBool).value
    }
    if lhs is SCString && rhs is SCString {
        return (lhs as! SCString).value == (rhs as! SCString).value
    }
    if lhs is SCInt && rhs is SCInt {
        return (lhs as! SCInt).value == (rhs as! SCInt).value
    }
    if lhs is SCDouble && rhs is SCDouble {
        return (lhs as! SCDouble).value == (rhs as! SCDouble).value
    }
    if lhs is SCDate && rhs is SCDate {
        return (lhs as! SCDate).value == (rhs as! SCDate).value
    }
    if lhs is SCArray && rhs is SCArray {
        return (lhs as! SCArray).value == (rhs as! SCArray).value
    }
    if lhs is SCDictionary && rhs is SCDictionary {
        return (lhs as! SCDictionary).value == (rhs as! SCDictionary).value
    }
    
    return false
}


