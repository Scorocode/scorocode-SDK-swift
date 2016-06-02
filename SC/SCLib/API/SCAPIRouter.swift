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
    
    private static let baseURLString = "https://api.scorocode.ru/api/v1/"
    
    case Login([String: AnyObject])
    case Logout([String: AnyObject])
    case Register([String: AnyObject])
    case Insert([String: AnyObject])
    case Remove([String: AnyObject])
    case Update([String: AnyObject])
    case UpdateById([String: AnyObject])
    case Find([String: AnyObject])
    case Count([String: AnyObject])
    case Upload([String: AnyObject])
    case DeleteFile([String: AnyObject])
    case GetFile(String, String, String)
    case GetFileLink([String: AnyObject])
    case SendEmail([String: AnyObject])
    case SendPush([String: AnyObject])
    case SendSms([String: AnyObject])
    case Scripts([String: AnyObject])
    case Stat([String: AnyObject])
    
    var URLRequest: NSMutableURLRequest {
        
        var method: Alamofire.Method {
        
            switch self {
                
            case .Login: return .POST
            case .Logout: return .POST
            case .Register: return .POST
                
            case .Insert: return .POST
            case .Remove: return .POST
            case .Update: return .POST
            case .UpdateById: return .POST
            case .Find: return .POST
            case .Count: return .POST
                
            case .Upload: return .POST
            case .DeleteFile: return .POST
            case .GetFile: return .GET
            case .GetFileLink: return .POST
                
            case .SendEmail: return .POST
            case .SendPush: return .POST
            case .SendSms: return .POST
                
            case .Scripts: return .POST
                
            case .Stat: return .POST
            }
        }
        
        let result: (path: String, parameters: [String: AnyObject]?) = {
            switch self {
                
            case .Login(let body):
                return ("login", body)
                
            case .Logout(let body):
                return ("logout", body)
                
            case .Register(let body):
                return ("register", body)
                
            case .Insert(let body):
                return ("data/insert", body)
                
            case .Remove(let body):
                return ("data/remove", body)
                
            case .Update(let body):
                return ("data/update", body)
                
            case .UpdateById(let body):
                return ("data/updatebyid", body)
                
            case .Find(let body):
                return ("data/find", body)
                
            case .Count(let body):
                return ("data/count", body)
                
            case .Upload(let body):
                return ("upload", body)
                
            case .DeleteFile(let body):
                return ("deletefile", body)
                
            case .GetFile(let collection, let field, let filename):
                return ("getfile/\(SCAPI.sharedInstance.applicationId)/\(collection)/\(field)/\(filename)", nil)
                
            case .GetFileLink(let body):
                return ("getfilelink", body)
                
            case .SendEmail(let body):
                return ("sendemail", body)
                
            case .SendPush(let body):
                return ("sendpush", body)
                
            case .SendSms(let body):
                return ("sendsms", body)
                
            case .Scripts(let body):
                return ("scripts", body)
                
            case .Stat(let body):
                return ("stat", body)
            }
        }()
        
        let baseURL = NSURL(string: SCAPIRouter.baseURLString)
        let URL = NSURL(string: result.path, relativeToURL: baseURL)
        let URLRequest = NSMutableURLRequest(URL: URL!)
        URLRequest.setValue(String("application/json"), forHTTPHeaderField: "Content-Type")
        
        let encoding = method == Alamofire.Method.POST ? Alamofire.ParameterEncoding.JSON : Alamofire.ParameterEncoding.URL
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: result.parameters)
        
        encodedRequest.HTTPMethod = method.rawValue
        
        if let httpBody = encodedRequest.HTTPBody {
            let s = String(data: httpBody, encoding: NSUTF8StringEncoding)
            print(s)
        }
        
        return encodedRequest
    }
    
}