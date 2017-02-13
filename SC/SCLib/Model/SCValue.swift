//
//  SCFieldType.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

protocol SCPullable {
    
}

protocol SCValue: SCPullable {
    var apiValue: Any { get }
}

struct SCBool: SCValue {
    let value: Bool
    
    init(_ value: Bool) {
        self.value = value
    }

    var apiValue: Any {
        return value as Any
    }
}

struct SCString: SCValue {
    let value: String
    
    init(_ value: String) {
        self.value = value
    }

    var apiValue: Any {
        return value as Any
    }
}

struct SCInt: SCValue {
    let value: Int
    
    init(_ value: Int) {
        self.value = value
    }
    
    var apiValue: Any {
        return value as Any
    }
}

struct SCDouble: SCValue {
    let value: Double
    
    init(_ value: Double) {
        self.value = value
    }
    
    var apiValue: Any {
        return value as Any
    }
}

struct SCDate: SCValue {
    let value: Date
    
    init(_ value: Date) {
        self.value = value
    }
    
    var apiValue: Any {
        let en_US_POSIX = Locale(identifier: "en_US_POSIX")
        let rfc3339DateFormatter = DateFormatter()
        rfc3339DateFormatter.locale = en_US_POSIX
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
        rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return rfc3339DateFormatter.string(from: value) as Any
    }
}

struct SCArray: SCValue {
    let value: [SCValue]
    
    init(_ value: [SCValue]) {
        self.value = value
    }
    
    var apiValue: Any {
        return value.map({ $0.apiValue })
    }
}

struct SCDictionary: SCValue {
    let value: [String: SCValue]
    
    init(_ value: [String: SCValue]) {
        self.value = value
    }
    
    var apiValue: Any {
        var result = [String: Any]()
        for (key, val) in value {
            result[key] = val.apiValue
        }
        return result as Any
    }
}

func == (lhs: [SCValue], rhs: [SCValue]) -> Bool {
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

func == (lhs: [String: SCValue], rhs: [String: SCValue]) -> Bool {
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


func !=(lhs: SCValue, rhs: SCValue) -> Bool {
    return !(lhs == rhs)
}

func ==(lhs: SCValue, rhs: SCValue) -> Bool {
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


