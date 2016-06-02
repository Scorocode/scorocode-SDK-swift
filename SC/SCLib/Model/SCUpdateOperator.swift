//
//  SCUpdateOperator.swift
//  SC
//
//  Created by Aleksandr Konakov on 09/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SCUpdateOperator: Equatable {
    
//    case Set(String, SCValue)
    case Set([String: SCValue])
    case Push(name: String, value: SCValue, each: Bool)
    case Pull(String, SCPullable)
    case PullAll(String, SCValue)
    case AddToSet(name: String, value: SCValue, each: Bool)
    case Pop(String, Int)
    case Inc(String, SCValue)
    case CurrentDate(String, String)
    case Mul(String, SCValue)
    case Min(String, SCValue)
    case Max(String, SCValue)

    var name: String {
        switch self {
        case .Set:
            return "$set"
        case .Push:
            return "$push"
        case .Pull:
            return "$pull"
        case .PullAll:
            return "$pullAll"
        case .AddToSet:
            return "$addToSet"
        case .Pop:
            return "$pop"
        case .Inc:
            return "$inc"
        case .CurrentDate:
            return "$currentDate"
        case .Mul:
            return "$mul"
        case .Min:
            return "$min"
        case .Max:
            return "$max"
        }
    }
    
    var dic: AnyObject {
        
        switch self {
            
//        case .Set(let name, let value):
//            return [name : value.apiValue]
        case .Set(let dic):
            var result = [String: AnyObject]()
            for (name, value) in dic {
                result[name] = value.apiValue
            }
            return result

        // TODO: $sort, $slice, $position
        case .Push(let name, let value, let each):
            if !each {
                return [name : value.apiValue]
            } else {
                return [name: ["$each" : value.apiValue]]
            }
    
        case .Pull(let name, let value):
            if let val = value as? SCValue {
                return [name : val.apiValue]
            } else {
                let cond = value as! SCOperator
                return [name : cond.dic]
            }

        case .PullAll(let name, let value):
            return [name : value.apiValue]
            
        case .AddToSet(let name, let value, let each):
            if !each {
                return [name : value.apiValue]
            } else {
                return [name: ["$each" : value.apiValue]]
            }
            
        case .Pop(let name, let value):
            return [name : SCInt(value).apiValue]
            
        case .Inc(let name, let value):
            return [name : value.apiValue]
            
        case .CurrentDate(let name, let typeSpec):
            let value = ["$type" : typeSpec]
            return [name : value]
            
        case .Mul(let name, let value):
            return [name : value.apiValue]
            
        case .Min(let name, let value):
            return [name : value.apiValue]
            
        case .Max(let name, let value):
            return [name : value.apiValue]
        }

    }
    
}

func ==(lhs: SCUpdateOperator, rhs: SCUpdateOperator) -> Bool {
    switch (lhs, rhs) {
        
//    case (let SCUpdateOperator.Set(name1, v1), let SCUpdateOperator.Set(name2, v2)):
//        return name1 == name2 && v1 == v2
    case (let SCUpdateOperator.Set(dic1), let SCUpdateOperator.Set(dic2)):
        return dic1 == dic2
        
    case (let SCUpdateOperator.Push(name1, v1, each1), let SCUpdateOperator.Push(name2, v2, each2)):
        return name1 == name2 && v1 == v2 && each1 == each2

        // TODO: Pull
    case (let SCUpdateOperator.Pull(name1, v1), let SCUpdateOperator.Pull(name2, v2)):
        if name1 != name2 { return false }
        
        switch (v1, v2) {
        case (is SCValue, is SCValue):
            return (v1 as! SCValue) == (v2 as! SCValue)
        default:
            return false
        }
        
    case (let SCUpdateOperator.PullAll(name1, v1), let SCUpdateOperator.PullAll(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCUpdateOperator.AddToSet(name1, v1, each1), let SCUpdateOperator.AddToSet(name2, v2, each2)):
        return name1 == name2 && v1 == v2 && each1 == each2
        
    case (let SCUpdateOperator.Pop(name1, v1), let SCUpdateOperator.Pop(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCUpdateOperator.Inc(name1, v1), let SCUpdateOperator.Inc(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCUpdateOperator.CurrentDate(name1, type1), let SCUpdateOperator.CurrentDate(name2, type2)):
        return name1 == name2 && type1 == type2
        
    case (let SCUpdateOperator.Mul(name1, v1), let SCUpdateOperator.Mul(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCUpdateOperator.Min(name1, v1), let SCUpdateOperator.Min(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCUpdateOperator.Max(name1, v1), let SCUpdateOperator.Max(name2, v2)):
        return name1 == name2 && v1 == v2
        
    default: return false
    }
}
