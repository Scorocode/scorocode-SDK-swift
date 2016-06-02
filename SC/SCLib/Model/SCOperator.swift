//
//  SCOperator.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SCOperator: SCPullable {
    
    case EqualTo(String, SCValue)
    case NotEqualTo(String, SCValue)
    case ContainedIn(String, SCArray)
    case ContainsAll(String, SCArray)
    case NotContainedIn(String, SCArray)
    case GreaterThan(String, SCValue)
    case GreaterThanOrEqualTo(String, SCValue)
    case LessThan(String, SCValue)
    case LessThanOrEqualTo(String, SCValue)
    case Exists(String)
    case DoesNotExist(String)
    case Contains(String, String, String)
    case StartsWith(String, String, String)
    case EndsWith(String, String, String)
    case Or([SCOperator])
    case And([SCOperator])
    
    var name: String? {
        switch self {
        case .EqualTo(let name, _):
            return name
        case .NotEqualTo(let name, _):
            return name
        case .ContainedIn(let name, _):
            return name
        case .ContainsAll(let name, _):
            return name
        case .NotContainedIn(let name, _):
            return name
        case .GreaterThan(let name, _):
            return name
        case .GreaterThanOrEqualTo(let name, _):
            return name
        case .LessThan(let name, _):
            return name
        case .LessThanOrEqualTo(let name, _):
            return name
        case .Exists(let name):
            return name
        case .DoesNotExist(let name):
            return name
        case .Contains(let name, _, _):
            return name
        case StartsWith(let name, _, _):
            return name
        case .EndsWith(let name, _, _):
            return name
        case .And(_):
            return nil
        case .Or(_):
            return nil
        }
    }
    
    var dic: AnyObject {
        
        switch self {
            
        case .EqualTo(_, let value):
            return value.apiValue
            
        case .NotEqualTo(_, let value):
            return ["$ne" : value.apiValue]
            
        case .ContainedIn(_, let value):
            return ["$in" : value.apiValue]
            
        case .ContainsAll(_, let value):
            return ["$all" : value.apiValue]
            
        case .NotContainedIn(_, let value):
            return ["$nin" : value.apiValue]
            
        case .GreaterThan(_, let value):
            return ["$gt" : value.apiValue]
            
        case .GreaterThanOrEqualTo(_, let value):
            return ["$gte" : value.apiValue]
            
        case .LessThan(_, let value):
            return ["$lt" : value.apiValue]
            
        case .LessThanOrEqualTo(_, let value):
            return ["$lte" : value.apiValue]
            
        case .Exists:
            return ["$exists" : true]
            
        case .DoesNotExist:
            return ["$exists" : false]
            
        case .Contains(_, let pattern, let options):
            return ["$regex" : pattern, "$options" : options]
            
        case .StartsWith(_, let pattern, let options):
            return ["$regex" : "^" + pattern, "$options" : options]
            
        case .EndsWith(_, let pattern, let options):
            return ["$regex" : pattern + "$", "$options" : options]

        case .Or(let operators):
            return operators.map({ $0.expression })
            
        case .And(let operators):
            return operators.map({ $0.expression })
        }
        
    }
    
    var expression: AnyObject {
        
        switch self {
            
        case .EqualTo(let name, let value):
            return [name: value.apiValue]
            
        case .NotEqualTo(let name, let value):
            return [name: ["$ne" : value.apiValue]]
            
        case .ContainedIn(let name, let value):
            return [name: ["$in" : value.apiValue]]
            
        case .ContainsAll(let name, let value):
            return [name: ["$all" : value.apiValue]]
            
        case .NotContainedIn(let name, let value):
            return [name: ["$nin" : value.apiValue]]
            
        case .GreaterThan(let name, let value):
            return [name: ["$gt" : value.apiValue]]
            
        case .GreaterThanOrEqualTo(let name, let value):
            return [name: ["$gte" : value.apiValue]]
            
        case .LessThan(let name, let value):
            return [name: ["$lt" : value.apiValue]]
            
        case .LessThanOrEqualTo(let name, let value):
            return [name: ["$lte" : value.apiValue]]
            
        case .Exists(let name):
            return [name: ["$exists" : true]]
            
        case .DoesNotExist(let name):
            return [name: ["$exists" : false]]
            
        case .Contains(let name, let pattern, let options):
            return [name: ["$regex" : pattern, "$options" : options]]
            
        case .StartsWith(let name, let pattern, let options):
            return [name: ["$regex" : "^" + pattern, "$options" : options]]
            
        case .EndsWith(let name, let pattern, let options):
            return [name: ["$regex" : pattern + "$", "$options" : options]]
            
        case .Or(let operators):
            return [ "$or": operators.map({ $0.expression }) ]
            
        case .And(let operators):
            return [ "$and": operators.map({ $0.expression }) ]
        }
        
    }
}

func == (lhs: [SCOperator], rhs: [SCOperator]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for (index, leftValue) in lhs.enumerate() {
        if leftValue != rhs[index] {
            return false
        }
    }
    return true
}

func !=(lhs: SCOperator, rhs: SCOperator) -> Bool {
    return !(lhs == rhs)
}


func ==(lhs: SCOperator, rhs: SCOperator) -> Bool {
    switch (lhs, rhs) {
        
    case (let SCOperator.EqualTo(name1, v1), let SCOperator.EqualTo(name2, v2)):
        return name1 == name2 && v1 == v2
    
    case (let SCOperator.NotEqualTo(name1, v1), let SCOperator.NotEqualTo(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.ContainedIn(name1, v1), let SCOperator.ContainedIn(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.ContainsAll(name1, v1), let SCOperator.ContainsAll(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.NotContainedIn(name1, v1), let SCOperator.NotContainedIn(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.GreaterThan(name1, v1), let SCOperator.GreaterThan(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.GreaterThanOrEqualTo(name1, v1), let SCOperator.GreaterThanOrEqualTo(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.LessThan(name1, v1), let SCOperator.LessThan(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.LessThanOrEqualTo(name1, v1), let SCOperator.LessThanOrEqualTo(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.Exists(name1), let SCOperator.Exists(name2)):
        return name1 == name2
        
    case (let SCOperator.DoesNotExist(name1), let SCOperator.DoesNotExist(name2)):
        return name1 == name2
        
    case (let SCOperator.Contains(name1, pattern1, options1), let SCOperator.Contains(name2, pattern2, options2)):
        return name1 == name2 && pattern1 == pattern2 && options1 == options2
        
    case (let SCOperator.StartsWith(name1, pattern1, options1), let SCOperator.StartsWith(name2, pattern2, options2)):
        return name1 == name2 && pattern1 == pattern2 && options1 == options2
        
    case (let SCOperator.EndsWith(name1, pattern1, options1), let SCOperator.EndsWith(name2, pattern2, options2)):
        return name1 == name2 && pattern1 == pattern2 && options1 == options2
        
    default:
        return false
    }
}
