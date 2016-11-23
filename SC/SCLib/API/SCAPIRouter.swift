//
//  SCAPIRouter.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation
import Alamofire

public enum SCAPIRouter: URLRequestConvertible {
    
    fileprivate static let baseURLString = "https://api.scorocode.ru/api/v1/"
    
    case login([String: AnyObject])
    case logout([String: AnyObject])
    case register([String: AnyObject])
    case insert([String: AnyObject])
    case remove([String: AnyObject])
    case update([String: AnyObject])
    case updateById([String: AnyObject])
    case find([String: AnyObject])
    case count([String: AnyObject])
    case upload([String: AnyObject])
    case deleteFile([String: AnyObject])
    case getFile(String, String, String)
    case getFileLink([String: AnyObject])
    case sendEmail([String: AnyObject])
    case sendPush([String: AnyObject])
    case sendSms([String: AnyObject])
    case scripts([String: AnyObject])
    case stat([String: AnyObject])
    
    public func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod {
            
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
            case .getFile: return .get
            case .getFileLink: return .post
                
            case .sendEmail: return .post
            case .sendPush: return .post
            case .sendSms: return .post
                
            case .scripts: return .post
                
            case .stat: return .post
            }
        }
        
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
                
            case .getFile(let collection, let field, let filename):
                return ("getfile/\(SCAPI.sharedInstance.applicationId)/\(collection)/\(field)/\(filename)", nil)
                
            case .getFileLink(let body):
                return ("getfilelink", body)
                
            case .sendEmail(let body):
                return ("sendemail", body)
                
            case .sendPush(let body):
                return ("sendpush", body)
                
            case .sendSms(let body):
                return ("sendsms", body)
                
            case .scripts(let body):
                return ("scripts", body)
                
            case .stat(let body):
                return ("stat", body)
            }
        }()
        
        let baseURL = Foundation.URL(string: SCAPIRouter.baseURLString)
        let URL = Foundation.URL(string: result.path, relativeTo: baseURL)
        var request = Foundation.URLRequest(url: URL!)
        request.setValue(String("application/json"), forHTTPHeaderField: "Content-Type")
        
        let encoding: ParameterEncoding = method == Alamofire.HTTPMethod.post ? Alamofire.JSONEncoding.default : Alamofire.URLEncoding.default
        do {
            var encodedRequest = try? encoding.encode(request, with: result.parameters! )
            encodedRequest?.httpMethod = method.rawValue
            if let httpBody = encodedRequest?.httpBody {
                let s = String(data: httpBody, encoding: String.Encoding.utf8)
                print(s)
            }
            return encodedRequest!
        }
    }
  
}
