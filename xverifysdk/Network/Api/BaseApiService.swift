//
//  BaseApiService.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import PINCache
import ObjectMapper

public typealias ObjectResult<T: Mappable> = (T?, NSError?) -> Void
public typealias ObjectArrayResult<T: Mappable> = ([T]?, NSError?) -> Void
public typealias BooleanResult = (Bool, NSError?) -> Void
public typealias StringResult = (String?, NSError?) -> Void
public typealias JsonResult = ([String: Any]?, NSError? ) -> Void

public class BaseApiService: NSObject {
    
    private let _restClient = RestClient();
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    public class var headers: [String: String] {
        [httpRequestHeaderNameAccept: httpRequestContentJson, httpRequestHeaderNameContentType: httpRequestContentJson]
    }
    
    public class var multiPartHeaders: [String: String] {
        [httpRequestHeaderNameAccept: httpRequestContentJson, httpRequestHeaderNameContentType: httpRequestContentJson]
    }
    
    public class var urlEncodedHeaders: [String: String] {
        [httpRequestHeaderNameAccept: httpRequestContentJson, httpRequestHeaderNameContentType: httpRequestContentFormUrlEncoded]
    }
    
    public class func GET(_ url: String) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodGet, parameters: nil, customHeaders: headers)
    }
    
    public class func GET(_ url: String, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodGet, parameters: nil, customHeaders: customHeaders)
    }

    public class func GET(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodGet, parameters: parameters, customHeaders: headers)
    }
    
    public class func GET(_ url: String, _ parameters: [String: Any]? = nil, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodGet, parameters: parameters, customHeaders: customHeaders)
    }

    public class func POST(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, parameters: parameters, customHeaders: headers)
    }
    
    public class func POST(_ url: String, _ parameters: [String: Any]? = nil, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, parameters: parameters, customHeaders: customHeaders)
    }
    
    public class func POST_MULTI_PART(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, parameters: parameters, customHeaders: multiPartHeaders)
    }
    
    public class func POST_URL_ENCODED(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, parameters: parameters, customHeaders: urlEncodedHeaders)
    }

    public class func POST(_ url: String, _ arrayParameters: [[String: Any]]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, arrayParameters: arrayParameters, customHeaders: headers)
    }
        
    public class func POST(_ url: String, _ arrayParameters: [[String: Any]]? = nil, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, arrayParameters: arrayParameters, customHeaders: customHeaders)
    }

    public class func POST(_ url: String, _ parameters: [String: Any]? = nil, _ filePath: String?) -> RestRequest {
        RestRequest.build(url, filePath: filePath, method: httpRequestMethodPost, parameters: parameters, customHeaders: headers)
    }
    
    public class func POST(_ url: String, _ parameters: [String: Any]? = nil, _ filePath: String?, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, filePath: filePath, method: httpRequestMethodPost, parameters: parameters, customHeaders: customHeaders)
    }

    public class func POST(_ url: String, _ parameters: [String: Any]? = nil, _ fileData: Data?) -> RestRequest {
        RestRequest.build(url, fileData: fileData, method: httpRequestMethodPost, parameters: parameters)
    }

    public class func PUT(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPut, parameters: parameters, customHeaders: headers)
    }
    
    public class func PUT(_ url: String, _ parameters: [String: Any]? = nil, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPut, parameters: parameters, customHeaders: customHeaders)
    }

    public class func DELETE(_ url: String) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodDelete, parameters: nil, customHeaders: headers)
    }
    
    public class func DELETE(_ url: String, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodDelete, parameters: nil, customHeaders: customHeaders)
    }

    public class func PATCH(_ url: String, _ filePath: String?) -> RestRequest {
        RestRequest.build(url, filePath: filePath, method: httpRequestMethodPatch, parameters: nil, customHeaders: headers)
    }
    
    public class func PATCH(_ url: String, _ filePath: String?, _ customHeaders: [String:String]) -> RestRequest {
        RestRequest.build(url, filePath: filePath, method: httpRequestMethodPatch, parameters: nil, customHeaders: customHeaders)
    }

    public class func BUILDURLPARAMS(_ url: String, params: [String]?) -> String {
        var resultUrl = url
        for param in params ?? [] {
            resultUrl += param
        }
        return resultUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    public class func BUILDURLENDPOINT(baseUrl: String, endPoint: String) -> String {
        
        var result = baseUrl
        
        if stringIsNullOrEmpty(endPoint) {
            return result
        }
        
        if result.hasSuffix("/") {
            result = String(format: "%@%@", result, endPoint)
        } else {
            if endPoint.hasPrefix("/") {
                result = String(format: "%@%@", result, endPoint)
            } else {
                result = String(format: "%@/%@", result, endPoint)
            }
        }
        return result
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadDataFromCache(_ request: RestRequest) -> RestResponse? {
        if PINCache.shared.containsObject(forKey: request.url) {
            Log.debug("CACHE RESPONSE load cached object for url=\(request.url!)")
            let cachedResult = PINCache.shared.object(forKey: request.url)
            return RestResponse.build(cachedResult, allHeaderFields: request.headers)
        }
        return nil
    }

    private func _saveDataToCache(_ request: RestRequest, _ response: RestResponse) {
        if response.isSuccess && response.result != nil {
            Log.debug("CACHE SAVE save object for url=\(request.url!)")
            DISPATCH_ASYNC_BG {
                PINCache.shared.setObject(response.result, forKey: request.url!)
            }
        }
    }

    private func _parse<T: Mappable>(response: RestResponse, model: T.Type) -> (Mappable?, NSError?) {

        // Check to see if response is success
        if !response.isSuccess {
            return (nil, ErrorUtils.error(response.headerStatusCode, message: response.statusMessage))
        }

        // Check to see if object is parsed and conform to protocols
        let object = Mapper<T>().map(JSONObject: response.result)
        if object == nil || !(object is ModelProtocol) {
            return (nil, ErrorUtils.error(ErrorCode.objectParsing))
        }

        // Check to see if model is valid
        let model = object as! ModelProtocol
        if !model.isValid() {
            if model.statusMessage != nil {
                return (nil, ErrorUtils.error(ErrorCode.invalidObject, message: model.statusMessage!))
            }
            return (nil, ErrorUtils.error(ErrorCode.invalidObject))
        }

        // Return valid object
        return (object, nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func request<T: Mappable>(_ restRequest: RestRequest, model: T.Type, shouldRefresh: Bool = true, shouldCache: Bool = true, callback: ObjectResult<T>? = nil) {

        // If the data is not refreshed, load from cache (if any)
        if !shouldRefresh {
            let cachedResponse = _loadDataFromCache(restRequest)
            if cachedResponse != nil {
                let (object, error) = _parse(response: cachedResponse!, model: model)
                if object != nil {
                    callback?(object as? T, error)
                }
            }
        }

        _restClient.invoke(restRequest, callback: RestCallback.callbackWithResult({ restResponse in
            let (object, error) = self._parse(response: restResponse, model: model)
            if object != nil && shouldCache {
                self._saveDataToCache(restRequest, restResponse)
            }
            callback?(object as? T, error)
        }))
    }

    func request(_ restRequest: RestRequest, callback: BooleanResult?) {
        _restClient.invoke(restRequest, callback: RestCallback.callbackWithResult({ response in
            if !response.isSuccess {
                callback?(false, ErrorUtils.error(response.headerStatusCode, message: response.statusMessage))
            } else {
                callback?(true, nil)
            }
        }))
    }

    func uploadRequest(_ restRequest: RestRequest, callback: BooleanResult?) {
        _restClient.uploadInvoke(restRequest, callback: RestCallback.callbackWithResult({ response in
            if !response.isSuccess {
                callback?(false, ErrorUtils.error(response.headerStatusCode, message: response.statusMessage))
            } else {
                callback?(true, nil)
            }
        }))
    }

    func multipartRequest<T: Mappable>(_ restRequest: RestRequest, model: T.Type, callback: ObjectResult<T>? = nil){
        _restClient.multiPartInvoke(restRequest, callback: RestCallback.callbackWithResult({ response in
            let (object, error) = self._parse(response: response, model: model)
            if object != nil {
                self._saveDataToCache(restRequest, response)
            }
            callback?(object as? T, error)
        }))
    }
    
    func genericRequest<T: Mappable>(_ restRequest: RestRequest, model: T.Type, shouldRefresh: Bool = true, shouldCache: Bool = true, callback: ObjectResult<T>? = nil) {

        // If the data is not refreshed, load from cache (if any)
        if !shouldRefresh {
            let cachedResponse = _loadDataFromCache(restRequest)
            if cachedResponse != nil {
                let (object, error) = _parse(response: cachedResponse!, model: model)
                if object != nil {
                    callback?(object as? T, error)
                }
            }
        }

        _restClient.genericInvoke(restRequest, callback: RestCallback.callbackWithResult({ restResponse in
            let (object, error) = self._parse(response: restResponse, model: model)
            if object != nil && shouldCache {
                self._saveDataToCache(restRequest, restResponse)
            }
            callback?(object as? T, error)
        }))
    }
}
