//
//  BaseServiceManager.swift
//  SharedService
//
//  Created by Luan Chiang on 3/15/19.
//  Copyright © 2019 Luan Chiang. All rights reserved.
//

import Foundation

final class BaseServiceManager: NSObject, URLSessionDelegate {
    private typealias RequestCompletionHandler = (Data?, URLResponse?, Error?) -> Void
    private typealias DownloadCompletionHandler = (URL?, URLResponse?, Error?) -> Void
    public typealias SuccessHandler = (_ result: Any?) -> Void
    public typealias FailureHandler = (_ error: BaseError?)-> Void
    private let kErrorMessage = "message"
    private let kErrorCode = "code"
    private let kResponse = "response"
    private let kErrors = "errors"
    private let kResults = "result"
    
    public static let shared = BaseServiceManager()
    let configuration = URLSessionConfiguration.default
    private var session: URLSession!
    
    private override init() {
        super.init()
        configuration.timeoutIntervalForResource = 60
        session = URLSession(configuration: configuration, delegate:self, delegateQueue: nil)
    }

    /**
     performRequest
     
     - Parameters:
        - urlRequest:URLRequest
        - success:SuccessHandler
        - failure:FailureHandler
     
     actual URLRequest endpoint request
     */
    @discardableResult
    public func performRequest(urlRequest: URLRequest, success: @escaping SuccessHandler, failure: @escaping FailureHandler) -> URLSessionDataTask{
        let completionHandler: RequestCompletionHandler = {[weak self] (data, urlResponse, error) in
            guard let self = self else {
                return
            }
            var baseError: BaseError?
            let httpStatusCode = self.statusCode(urlResponse)
            // check if URLSession request returns error
            if let error = error as NSError? {
                print(error.localizedDescription)
                baseError = BaseError.error(withCode: error.code)
                baseError?.errorCode = error.code
                baseError?.errorMessage = "There was a network error"
                failure(baseError)
                return
            }
            
            // check for success http status code
            if !self.isSuccessCheck(urlResponse) {
                baseError = BaseError.error(withCode: httpStatusCode)
                baseError?.errorCode = httpStatusCode
                failure(baseError)
                return
            }
            
            var jsonResponse: Any?
            guard let data = data else {
                print("Unable to parse the response")
                baseError = self.dataParsingIssue()
                failure(baseError)
                return
            }
            
            if let response = urlResponse as? HTTPURLResponse {
                let fields = response.allHeaderFields
                _ = HTTPCookie.cookies(withResponseHeaderFields: fields as! [String : String], for: urlResponse!.url!)
                // manage cookie storage here if necessary
            }
            do {
                jsonResponse = try JSONSerialization.jsonObject(with:data, options: [])
            } catch let error {
                baseError = BaseError.error(with: .JSON_SERIALIZE_ERROR)
                baseError?.errorMessage = error.localizedDescription
                failure(baseError)
            }
            
            if self.isSuccessCheck(urlResponse) {
                self.handleSuccessfulResponseData(jsonResponse, success: success, failure: failure)
                return
            }

            baseError = BaseError.error(withCode: httpStatusCode)
            baseError?.errorCode = httpStatusCode
            baseError?.informationDictionary = jsonResponse as? [AnyHashable : Any]
            baseError?.errorMessage = String(data: data, encoding:.utf8)
            
            failure(baseError)
        }
        let task = session.dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
        return task
    }
    
    /**
     performDecoderRequest<T:Decodable>
    
    - Parameters:
       - urlRequest:URLRequest
       - success:(T) -> ()
       - failure:FailureHandler
    
    actual URLRequest endpoint request
    */
    public func performDecoderRequest<T:Decodable>(urlRequest: URLRequest, success:@escaping (T) -> (), failure: @escaping FailureHandler) -> URLSessionDataTask {
        let completionHandler: RequestCompletionHandler = {[weak self] (data, urlResponse, error) in
            guard let self = self else {
                return
            }
            var baseError: BaseError?
            let httpStatusCode = self.statusCode(urlResponse)
            // check if URLSession request returns error
            if let error = error as NSError? {
                print(error.localizedDescription)
                let baseError = BaseError.error(withCode: error.code)
                baseError?.errorCode = error.code
                baseError?.errorMessage = "There was a network error"
                failure(baseError)
                return
            }
            
            // check for success http status code
            if !self.isSuccessCheck(urlResponse) {
                baseError = BaseError.error(withCode: httpStatusCode)
                baseError?.errorCode = httpStatusCode
                failure(baseError)
                return
            }
            // check if data exist
            guard let data = data else {
                print("Unable to parse the response")
                baseError = BaseError.error(withCode: httpStatusCode)
                baseError?.errorCode = httpStatusCode
                baseError?.errorMessage = "Unable to parse the response"
                failure(baseError)
                return
            }
            // do JSONDecodaber parsing
            do {
                let result = try JSONDecoder().decode(T.self , from: data)
                success(result)
                return
            } catch let error {
                print(error)
                baseError = BaseError.error(with: .JSON_DECODABLE_ERROR)
                baseError?.errorMessage = error.localizedDescription
                failure(baseError)
            }
        }
        let task = session.dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
        return task
    }
    
    public func dataParsingIssue() -> BaseError {
        let errorCode = EnumBaseErrorType.UNDEFINED.rawValue
        let baseError = BaseError(type: .UNDEFINED)
        baseError.errorCode = errorCode
        baseError.errorMessage = "Unable to parse the response"
        return baseError
    }
    
    private func handleSuccessfulResponseData(_ responseData: Any?, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        var resultData: Any?
        if let response = responseData as? [AnyHashable : Any] {
            let error = self.verifyAndReturnErrorIfAvailable(response[self.kErrors])
            if(error != nil){
                error?.informationDictionary = response
                failure(error)
                return
            }
            resultData = response
        }
        success(resultData)
    }
    
    private func verifyAndReturnErrorIfAvailable(_ errors: Any?) -> BaseError? {
        guard let errors = errors as? [Any], errors.count > 0 else {
            return nil
        }
        var responseError: BaseError?
        if let firstError = errors.first as? [String : Any?] {
            if let errorMessage = firstError[kErrorCode] as? String {
                responseError = BaseError.error(withApiErrorCode: errorMessage)
            } else {
                responseError = BaseError()
            }
            responseError?.errorMessage = firstError[kErrorMessage] as? String
        }
        return responseError
    }
    
    /**
     isSuccessCode
     
     - Parameters:
        - statusCode: Int
     
     - Returns: Bool
     */
    private func isSuccessCode(_ statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    /**
     isSuccessCheck
     
     - Parameters:
        - response: URLResponse
     
     - Returns: Bool
     */
    private func isSuccessCheck(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isSuccessCode(urlResponse.statusCode)
    }
    
    /**
     statusCode
     
     - Parameters:
        - response: URLResponse
     
     - Returns: Int
     */
    private func statusCode(_ response: URLResponse?) -> Int {
        guard let urlResponse = response as? HTTPURLResponse else {
            return 0
        }
        return urlResponse.statusCode
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let authMethod = challenge.protectionSpace.authenticationMethod
        guard authMethod == NSURLAuthenticationMethodHTTPBasic else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.rejectProtectionSpace, nil)
    }
}
