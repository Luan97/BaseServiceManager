//
//  BaseApiRequest.swift
//  BaseServiceManager
//
//  Created by Luan Chiang on 3/20/19.
//  Copyright © 2019 Luan Chiang. All rights reserved.
//

import Foundation

public enum ApiRequestType: String{
    case POST = "POST"
    case GET = "GET"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

public class BaseApiRequest {
    private static let kContentType = "Content-Type"
    private static let kApplicationJson = "application/json"
    private static let kContentLength = "Content-Length"
    private static let kAcceptEncoding = "Accept-Encoding"
    private static let kAccept = "Accept"
    private static let kGZip = "gzip"
    
    /**
     prepareCookieHeader
     
     - Returns: [String: String] */
    private class func prepareCookieHeader() -> [String: String] {
        //guard let dict = CookieManager.sharedInstance.retrieveCookies() as? [String: String] else {
            return [String: String]()
        //}
        // prepare cookie header
        //return dict
    }
    
    /**
     processCommonRequest
     
     - Parameters:
        - url: URL
     - Returns: URLRequest */
    private static func processCommonRequest(url:URL, headerFields:[String:String]?) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = prepareCookieHeader()
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.setValue(BaseApiRequest.kApplicationJson, forHTTPHeaderField: BaseApiRequest.kContentType)
        
        headerFields?.forEach({ (key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        })
        return request
    }
    
    /**
     prepareHttpBody

     - Parameters:
        - arguments: post body arguments
     - Returns: Data? */
    private static func prepareHttpBody(_ arguments:[String: AnyObject]?) -> Data? {
        guard let postData = try? JSONSerialization.data(withJSONObject: arguments as Any, options: []) else {
            return nil
        }
        return postData
    }
    
    /**
     processGetArguments
     
     - Parameters:
        - url: URL
        - arguments: [String: AnyObject]?
     - Returns: URL!
     */
    private static func processGetArguments(url:URL, arguments:[String: AnyObject]?) -> URL! {
        var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if (arguments != nil){
            comp!.queryItems = arguments!.map { item in
                URLQueryItem(name: item.key, value: String(describing: item.value))
            }
        }
        return comp!.url
    }
    
    /**
     composeRequest
     
     - Parameters:
        - type: ApiRequestType
        - url: URL!
        - arguments: [String: AnyObject]?
     - Returns: URLRequest
     */
    public static func composeRequest(type:ApiRequestType, url:URL, headerFields:[String: String]?, arguments:[String: AnyObject]?) -> URLRequest {
        let url = type == ApiRequestType.GET ? processGetArguments(url:url, arguments: arguments): url
        var request = processCommonRequest(url: url!, headerFields: headerFields)
        request.httpMethod = type.rawValue
        request.timeoutInterval = 60
        if let arguments = arguments {
            if (type != ApiRequestType.GET) {
                if let postBody = prepareHttpBody(arguments) {
                    let postBodyLength = String(postBody.count)
                    request.httpBody = postBody
                    request.setValue(postBodyLength, forHTTPHeaderField: BaseApiRequest.kContentLength)
                }
            }
        }
        
        return request
    }
}
