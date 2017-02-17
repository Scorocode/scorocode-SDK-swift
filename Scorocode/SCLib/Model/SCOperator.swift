//
//  SCOperator.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum SCOperator: SCPullable {
    
    case equalTo(String, SCValue)
    case notEqualTo(String, SCValue)
    case containedIn(String, SCArray)
    case containsAll(String, SCArray)
    case notContainedIn(String, SCArray)
    case greaterThan(String, SCValue)
    case greaterThanOrEqualTo(String, SCValue)
    case lessThan(String, SCValue)
    case lessThanOrEqualTo(String, SCValue)
    case exists(String)
    case doesNotExist(String)
    case contains(String, String, String)
    case startsWith(String, String, String)
    case endsWith(String, String, String)
    case or([SCOperator])
    case and([SCOperator])
    
    public var name: String? {
        switch self {
        case .equalTo(let name, _):
            return name
        case .notEqualTo(let name, _):
            return name
        case .containedIn(let name, _):
            return name
        case .containsAll(let name, _):
            return name
        case .notContainedIn(let name, _):
            return name
        case .greaterThan(let name, _):
            return name
        case .greaterThanOrEqualTo(let name, _):
            return name
        case .lessThan(let name, _):
            return name
        case .lessThanOrEqualTo(let name, _):
            return name
        case .exists(let name):
            return name
        case .doesNotExist(let name):
            return name
        case .contains(let name, _, _):
            return name
        case .startsWith(let name, _, _):
            return name
        case .endsWith(let name, _, _):
            return name
        case .and(_):
            return nil
        case .or(_):
            return nil
        }
    }
    
    public var dic: Any {
        
        switch self {
            
        case .equalTo(_, let value):
            return value.apiValue
            
        case .notEqualTo(_, let value):
            return ["$ne" : value.apiValue]
            
        case .containedIn(_, let value):
            return ["$in" : value.apiValue]
            
        case .containsAll(_, let value):
            return ["$all" : value.apiValue]
            
        case .notContainedIn(_, let value):
            return ["$nin" : value.apiValue]
            
        case .greaterThan(_, let value):
            return ["$gt" : value.apiValue]
            
        case .greaterThanOrEqualTo(_, let value):
            return ["$gte" : value.apiValue]
            
        case .lessThan(_, let value):
            return ["$lt" : value.apiValue]
            
        case .lessThanOrEqualTo(_, let value):
            return ["$lte" : value.apiValue]
            
        case .exists:
            return ["$exists" : true]
            
        case .doesNotExist:
            return ["$exists" : false]
            
        case .contains(_, let pattern, let options):
            return ["$regex" : pattern, "$options" : options]
            
        case .startsWith(_, let pattern, let options):
            return ["$regex" : "^" + pattern, "$options" : options]
            
        case .endsWith(_, let pattern, let options):
            return ["$regex" : pattern + "$", "$options" : options]

        case .or(let operators):
            return operators.map({ $0.expression })
            
        case .and(let operators):
            return operators.map({ $0.expression })
        }
        
    }
    
    public var expression: Any {
        
        switch self {
            
        case .equalTo(let name, let value):
            return [name: value.apiValue]
            
        case .notEqualTo(let name, let value):
            return [name: ["$ne" : value.apiValue]]
            
        case .containedIn(let name, let value):
            return [name: ["$in" : value.apiValue]]
            
        case .containsAll(let name, let value):
            return [name: ["$all" : value.apiValue]]
            
        case .notContainedIn(let name, let value):
            return [name: ["$nin" : value.apiValue]]
            
        case .greaterThan(let name, let value):
            return [name: ["$gt" : value.apiValue]]
            
        case .greaterThanOrEqualTo(let name, let value):
            return [name: ["$gte" : value.apiValue]]
            
        case .lessThan(let name, let value):
            return [name: ["$lt" : value.apiValue]]
            
        case .lessThanOrEqualTo(let name, let value):
            return [name: ["$lte" : value.apiValue]]
            
        case .exists(let name):
            return [name: ["$exists" : true]]
            
        case .doesNotExist(let name):
            return [name: ["$exists" : false]]
            
        case .contains(let name, let pattern, let options):
            return [name: ["$regex" : pattern, "$options" : options]]
            
        case .startsWith(let name, let pattern, let options):
            return [name: ["$regex" : "^" + pattern, "$options" : options]]
            
        case .endsWith(let name, let pattern, let options):
            return [name: ["$regex" : pattern + "$", "$options" : options]]
            
        case .or(let operators):
            return [ "$or": operators.map({ $0.expression }) ]
            
        case .and(let operators):
            return [ "$and": operators.map({ $0.expression }) ]
        }
        
    }
}

public func == (lhs: [SCOperator], rhs: [SCOperator]) -> Bool {
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

public func !=(lhs: SCOperator, rhs: SCOperator) -> Bool {
    return !(lhs == rhs)
}


public func ==(lhs: SCOperator, rhs: SCOperator) -> Bool {
    switch (lhs, rhs) {
        
    case (let SCOperator.equalTo(name1, v1), let SCOperator.equalTo(name2, v2)):
        return name1 == name2 && v1 == v2
    
    case (let SCOperator.notEqualTo(name1, v1), let SCOperator.notEqualTo(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.containedIn(name1, v1), let SCOperator.containedIn(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.containsAll(name1, v1), let SCOperator.containsAll(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.notContainedIn(name1, v1), let SCOperator.notContainedIn(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.greaterThan(name1, v1), let SCOperator.greaterThan(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.greaterThanOrEqualTo(name1, v1), let SCOperator.greaterThanOrEqualTo(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.lessThan(name1, v1), let SCOperator.lessThan(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.lessThanOrEqualTo(name1, v1), let SCOperator.lessThanOrEqualTo(name2, v2)):
        return name1 == name2 && v1 == v2
        
    case (let SCOperator.exists(name1), let SCOperator.exists(name2)):
        return name1 == name2
        
    case (let SCOperator.doesNotExist(name1), let SCOperator.doesNotExist(name2)):
        return name1 == name2
        
    case (let SCOperator.contains(name1, pattern1, options1), let SCOperator.contains(name2, pattern2, options2)):
        return name1 == name2 && pattern1 == pattern2 && options1 == options2
        
    case (let SCOperator.startsWith(name1, pattern1, options1), let SCOperator.startsWith(name2, pattern2, options2)):
        return name1 == name2 && pattern1 == pattern2 && options1 == options2
        
    case (let SCOperator.endsWith(name1, pattern1, options1), let SCOperator.endsWith(name2, pattern2, options2)):
        return name1 == name2 && pattern1 == pattern2 && options1 == options2
        
    default:
        return false
    }
}
