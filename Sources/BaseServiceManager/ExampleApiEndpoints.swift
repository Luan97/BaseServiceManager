//
//  ExampleEnumEndpoint.swift
//  BaseServiceManager
//
//  Created by Luan Chiang on 3/21/19.
//  Copyright © 2019 Luan Chiang. All rights reserved.
//
// This BaseEnumEndpoint and BaseApiEndpoints should not be inside the framework due to
// need some customization work for domain specific configuration, this is just an example class

public enum ExampleEnumEndpoint: Int {
    case SEARCH
    case CURATED
    case VIDEOS
    
    // here can defined sub directory domain, for instance
    public var urlPath: String {
        switch self {
        case .SEARCH:
            return "search"
        case .CURATED:
            return "curated"
        default:
            return ""
        }
    }
}

public class ExampleApiEndpoints {
    public static var baseURL:String = "https://api.pexels.com/v1"
    public static var headerFields: [String:String] = ["Authorization":"563492ad6f917000010000017241767ea46b454390ac44fb6c7cdfd6"]
    /**
     urlWithEndpoint
     
     - Parameters:
        - endPoint: BaseEnumEndpoint
     
     - Returns: String
     */
    public static func urlWithEndpoint(_ endPoint:ExampleEnumEndpoint) -> String {
        if (endPoint.urlPath .contains("http") || endPoint.urlPath .contains("https")) {
            return endPoint.urlPath
        }
        // add up sub path if applicable
        if !endPoint.urlPath.isEmpty {
            return ExampleApiEndpoints.baseURL+"/"+endPoint.urlPath
        } else {
            return ExampleApiEndpoints.baseURL
        }
    }
}

