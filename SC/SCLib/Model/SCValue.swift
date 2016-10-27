//
//  SCFieldType.swift
//  SC
//
//  Created by Aleksandr Konakov on 04/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

public protocol SCPullable {
    
}

public protocol SCValue: SCPullable {
    var apiValue: AnyObject { get }
}

public struct SCBool: SCValue {
    public let value: Bool
    
    public init(_ value: Bool) {
        self.value = value
    }

    public var apiValue: AnyObject {
        return value as AnyObject
    }
}

public struct SCString: SCValue {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }

    public var apiValue: AnyObject {
        return value as AnyObject
    }
}

public struct SCInt: SCValue {
    public let value: Int
    
    public init(_ value: Int) {
        self.value = value
    }
    
    public var apiValue: AnyObject {
        return value as AnyObject
    }
}

public struct SCDouble: SCValue {
    public let value: Double
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public var apiValue: AnyObject {
        return value as AnyObject
    }
}

public struct SCDate: SCValue {
    public let value: Date
    
    public init(_ value: Date) {
        self.value = value
    }
    
    public var apiValue: AnyObject {
        let en_US_POSIX = Locale(identifier: "en_US_POSIX")
        let rfc3339DateFormatter = DateFormatter()
        rfc3339DateFormatter.locale = en_US_POSIX
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
        rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return rfc3339DateFormatter.string(from: value) as AnyObject
    }
}

public struct SCArray: SCValue {
    public let value: [SCValue]
    
    public init(_ value: [SCValue]) {
        self.value = value
    }
    
    public var apiValue: AnyObject {
        return value.map({ $0.apiValue }) as AnyObject
    }
}

public struct SCDictionary: SCValue {
    let value: [String: SCValue]
    
    public init(_ value: [String: SCValue]) {
        self.value = value
    }
    
    public var apiValue: AnyObject {
        var result = [String: AnyObject]()
        for (key, val) in value {
            result[key] = val.apiValue
        }
        return result as AnyObject
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


