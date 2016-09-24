//
//  SCAPIRouter.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum SCAPIRouter: URLRequestConvertible {
  /// Returns a URL request or throws if an `Error` was encountered.
  ///
  /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
  ///
  /// - returns: A URL request.
  public func asURLRequest() throws -> URLRequest {
    
  }

    
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
    
    var URLRequest: NSMutableURLRequest {
        
        var method: Alamofire.Method {
        
            switch self {
                
            case .login: return .POST
            case .logout: return .POST
            case .register: return .POST
                
            case .insert: return .POST
            case .remove: return .POST
            case .update: return .POST
            case .updateById: return .POST
            case .find: return .POST
            case .count: return .POST
                
            case .upload: return .POST
            case .deleteFile: return .POST
            case .getFile: return .GET
            case .getFileLink: return .POST
                
            case .sendEmail: return .POST
            case .sendPush: return .POST
            case .sendSms: return .POST
                
            case .scripts: return .POST
                
            case .stat: return .POST
            }
        }
        
        let result: (path: String, parameters: [String: AnyObject]?) = {
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
        let URLRequest = NSMutableURLRequest(url: URL!)
        URLRequest.setValue(String("application/json"), forHTTPHeaderField: "Content-Type")
        
        let encoding = method == Alamofire.Method.POST ? Alamofire.ParameterEncoding.json : Alamofire.ParameterEncoding.url
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: result.parameters)
        
        encodedRequest.httpMethod = method.rawValue
        
        if let httpBody = encodedRequest.httpBody {
            let s = String(data: httpBody, encoding: String.Encoding.utf8)
            print(s)
        }
        
        return encodedRequest
    }
    
}
