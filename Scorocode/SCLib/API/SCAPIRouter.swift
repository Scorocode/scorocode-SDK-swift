//
//  SCAPIRouter.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum SCAPIRouter: URLRequestConvertible {
    
    public static let baseURLString = "https://api.scorocode.ru/api/v1/"
    
    case login([String: Any])
    case logout([String: Any])
    case register([String: Any])
    case insert([String: Any])
    case remove([String: Any])
    case update([String: Any])
    case updateById([String: Any])
    case find([String: Any])
    case count([String: Any])
    case upload([String: Any])
    case deleteFile([String: Any])
    case sendPush([String: Any])
    case sendSms([String: Any])
    case scripts([String: Any])
    case stat([String: Any])
    case app([String: Any])
    case collections([String: Any])
    case getCollection([String: Any])
    case createCollection([String: Any])
    case updateCollection([String: Any])
    case removeCollection([String: Any])
    case cloneCollection([String: Any])
    
    func asURLRequest() throws -> URLRequest {
        
        let result: (path: String, parameters: [String: Any]?) = {
            switch self {
                
            case .login(let body):
                return ("login", body)
                
            case .logout(let body):
                return ("logout", body)
                
            case .register(let body):
                return ("register", body)
                
            case .insert(let body):
                return ("data/insert", body)
                
            case .remove(let body):
                return ("data/remove", body)
                
            case .update(let body):
                return ("data/update", body)
                
            case .updateById(let body):
                return ("data/updatebyid", body)
                
            case .find(let body):
                return ("data/find", body)
                
            case .count(let body):
                return ("data/count", body)
                
            case .upload(let body):
                return ("upload", body)
                
            case .deleteFile(let body):
                return ("deletefile", body)
                
            case .sendPush(let body):
                return ("sendpush", body)
                
            case .sendSms(let body):
                return ("sendsms", body)
                
            case .scripts(let body):
                return ("scripts", body)
                
            case .stat(let body):
                return ("stat", body)
            case .app(let body):
                return ("app", body)
            case .collections(let body):
                return ("app/collections", body)
            case .getCollection(let body):
                return ("app/collections/get", body)
            case .createCollection(let body):
                return ("app/collections/create", body)
            case .updateCollection(let body):
                return ("app/collections/update", body)
            case .removeCollection(let body):
                return ("app/collections/delete", body)
            case .cloneCollection(let body):
                return ("app/collections/clone", body)
            }
        }()
        
        let baseURL = Foundation.URL(string: SCAPIRouter.baseURLString)
        let URL = Foundation.URL(string: result.path, relativeTo: baseURL)
        var urlRequest = URLRequest(url: URL!)
        urlRequest.setValue(String("application/json"), forHTTPHeaderField: "Content-Type")
        
        if method == .post {
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: result.parameters)
        } else {
            urlRequest = try URLEncoding.default.encode(urlRequest, with: result.parameters)
        }

        urlRequest.httpMethod = method.rawValue
        
        if let httpBody = urlRequest.httpBody {
            let s = String(data: httpBody, encoding: String.Encoding.utf8)!
            print(s)
        }
        
        return urlRequest
        
    }
    
    var method: HTTPMethod {
        
        switch self {
            
        case .login: return .post
        case .logout: return .post
        case .register: return .post
            
        case .insert: return .post
        case .remove: return .post
        case .update: return .post
        case .updateById: return .post
        case .find: return .post
        case .count: return .post
            
        case .upload: return .post
        case .deleteFile: return .post
            
        case .sendPush: return .post
        case .sendSms: return .post
            
        case .scripts: return .post
            
        case .stat: return .post
        case .app: return .post
            
        case .collections: return .post
        case .getCollection: return .post
        case .createCollection: return .post
        case .updateCollection: return .post
        case .removeCollection: return .post
        case .cloneCollection: return .post
        }
    }
}
