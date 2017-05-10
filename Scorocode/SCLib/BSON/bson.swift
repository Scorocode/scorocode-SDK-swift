//
//  bson.swift
//  Scorocode-SDK-ios
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

extension Data {
    func dictionaryFromBSONData() -> [String:Any] {
        return dictionaryFromBSONBytes(byteArray: [UInt8](self))
    }
}

//BSON types
enum BSONType: UInt8 {
    case double = 0x01
    case string = 0x02
    case document = 0x03
    case array = 0x04
    case binary = 0x05
    //case kBSON_UNDEFINED = 0x06 //Deprecated
    //case objectID = 0x07 //NA
    case bool = 0x08
    case UTCDatetime = 0x09
    case null = 0x0A
    //case kBSON_REGEX = 0x0B //NA
    //case kBSON_DBPOINTER = 0x0C //Deprecated
    //case kBSON_JAVASCRIPT = 0x0D //NA
    //case kBSON_SYMBOL = 0x0E //NA
    //case kBSON_CODE_W_S = 0x0F //NA
    case int32 = 0x10
    //case kBSON_MONGO_TIMESTAMP = 0x11 //NA
    case int64 = 0x12
    //case kBSON_MIN_KEY = 0xFF //NA
    //case kBSON_MAX_KEY = 0x7F //NA
}

func bytesToString(bytesArray: [UInt8]) -> String? {
    //find 0x00
    for p in 0...bytesArray.count {
        if bytesArray[p] == 0 {
            let data = Data(bytes: bytesArray[0..<p])
            return String(data: data, encoding: .utf8)!
        }
    }
    return nil
}

func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
    /* crashes on 32bit architecture.
    return value.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }*/
    return value.withUnsafeBufferPointer {
        $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
            $0.pointee
        }
    }
}

//MARK: Deserialization
func dictionaryFromBSONBytes(byteArray: [UInt8]) -> [String:Any] {
    var pointer: Int = 4 //skip size
    let length = byteArray.count
    var dictionary = [String:Any]()
    while pointer < length - 1 {
        //read type
        guard let type = BSONType(rawValue: byteArray[pointer]) else {
            print("Invalid type (\(byteArray[pointer]))found in Document when reading at position: \(pointer)")
            return [:]
        }
        pointer = pointer + 1
        //read name
        guard let name = bytesToString(bytesArray: Array(byteArray[pointer...length - 1])) else {
            print("Error on string parse - string is not null-terminated.")
            return [:]
        }
        pointer = pointer + name.data(using: .utf8)!.count + 1 //with null terminated zero
        //read value
        var value: Any = 0
        switch type {
        case .string:
            let size = Int(fromByteArray(Array(byteArray[pointer...pointer + 3]), Int32.self)) //get size
            pointer = pointer + 4 //skip size
            guard let string = bytesToString(bytesArray: Array(byteArray[pointer...pointer + size])) else {
                print("Error on string parse - string is not null-terminated.")
                return [:]
            }
            value = string
            pointer = pointer + size
        case .binary:
            print("error - binary")
            return [:]
        case .UTCDatetime:
            value = Date(timeIntervalSince1970: Double(fromByteArray(Array(byteArray[pointer...pointer + 7]), Int64.self))/1000)
            pointer = pointer + 8
        case .bool:
            value = byteArray[pointer] == 0x1 ? NSNumber(value: true) : NSNumber(value: false)
            pointer = pointer + 1
        case .double:
            value = fromByteArray(Array(byteArray[pointer...pointer + 7]), Double.self)
            pointer = pointer + 8
        case .int32:
            value = fromByteArray(Array(byteArray[pointer...pointer + 3]), Int32.self)
            pointer = pointer + 4
        case .int64:
            value = fromByteArray(Array(byteArray[pointer...pointer + 7]), Int64.self)
            pointer = pointer + 8
        case .null:
            value = NSNull()
        case .array:
            let size = Int(fromByteArray(Array(byteArray[pointer...pointer + 3]), Int32.self))
            value = arrayFromBSONBytes(byteArray: Array(byteArray[pointer...pointer + size - 1]))
            pointer = pointer + size
        case .document:
            let size = Int(fromByteArray(Array(byteArray[pointer...pointer + 3]), Int32.self))
            value = dictionaryFromBSONBytes(byteArray: Array(byteArray[pointer...pointer + size - 1]))
            pointer = pointer + size
        }
        dictionary[name] = value as Any
    }
    return dictionary
}

func arrayFromBSONBytes(byteArray: [UInt8]) -> [Any] {
    let dictionary = dictionaryFromBSONBytes(byteArray: byteArray)
    return dictionary.sorted(by: { Int($0.0.0)! < Int($0.1.0)! }).map({$0.1})
}
