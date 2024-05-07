import Alamofire
import SwiftDate

let kDefaultRetryCount: Int = 3
let kDefaultPageSize: Int = 500
let kDefaultPageNo: Int = 1
let kDefaultRequestTimeOut: TimeInterval = 10.0
let kDefaultResourceRequestTimeOut: TimeInterval = 10.0
let kDefaultRequestLongTimeOut: TimeInterval = 120.0
let kDefaultResourceLongRequestTimeOut: TimeInterval = 120.0

public class RestClient: NSObject {

    struct SessionSecData {
        var protectionSpace: URLProtectionSpace
        var userCredential: URLCredential
    }

    private var _sessionManager: Session!
    private var _uploadSessionManager: Session!
    private var _sessionRetrier = SessionRetrier()

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    private class func _validate(
        _ response: HTTPURLResponse?,
        object: [String: Any]?,
        error: NSError?) -> RestResponse {
            let allHeaderFields = response?.allHeaderFields
            var isSuccess: Bool = true

            var statusCode: Int = httpStatusCodeOk
            if response == nil && error != nil {
                statusCode = error?.code ?? httpStatusCodeOk
            } else {
                statusCode =  (response?.statusCode ?? httpStatusCodeOk)
            }

            var statusMessage: String? = HTTPURLResponse.localizedString(forStatusCode: statusCode)

            var result = object

            // Handle error case
            if result == nil || error != nil {
                if error != nil {
                    if statusCode > httpStatusCodeOk && statusCode < httpStatusCodeMultipleChoices {
                        statusMessage = error?.localizedDescription
                        statusCode = error!.code
                    }
                } else {
                    statusMessage = LOCALIZED("content_empty")
                    statusCode = httpStatusCodeNoContent
                }
                isSuccess = false
                result = [:]
            }
            if statusCode < httpStatusCodeOk || statusCode > httpStatusCodeMultipleChoices {
                if error != nil {
                    if statusCode == httpStatusCodeUnauthorized {
                        statusMessage = LOCALIZED("error_unauthorized")
                        NotificationCenter.default.post(name: .didUnAuthorized, object: nil)
                    } else if statusCode == httpStatusCodeInternalError {
                        statusMessage = LOCALIZED("error_500")
                    } else if statusCode == httpStatusCodeTimeout {
                        statusMessage = LOCALIZED("error_408")
                    } else if statusCode == httpStatusCodeConnectIssue {
                        statusMessage = LOCALIZED("error_code_-1020")
                    } else if statusCode == httpStatusCodeConnectionOffline || statusCode == httpStatusCodeDeviceOffline {
                        statusMessage = LOCALIZED("error_code_-1009")
                    } else if statusCode == httpStatusRequestTimeout {
                        statusMessage = LOCALIZED("error_code_-1001")
                    } else {
                        statusMessage = error?.localizedDescription
                    }
                    if statusCode == httpStatusCodeUnauthorized || statusCode == httpStatusAccountUnAuthorized{
                        NotificationCenter.default.post(name: .didUnAuthorized, object: nil)
                    }
                }

                isSuccess = false
            }

            if object != nil {
                Log.debug(String(format: "SERVICE RESPONSE result\n%@\n", object ?? ""))
            }

            return RestResponse.build(
                result,
                isSuccess: isSuccess,
                statusCode: statusCode,
                allHeaderFields: allHeaderFields,
                statusMessage: statusMessage)
        }

    private class func _validString(_ response: HTTPURLResponse?, object: String?, error: NSError?) -> RestResponse {
        let allHeaderFields = response?.allHeaderFields
        var isSuccess: Bool = true
        var statusCode: Int = httpStatusCodeOk
        if response == nil && error != nil {
            statusCode = error?.code ?? httpStatusCodeOk
        } else {
            statusCode =  (response?.statusCode ?? httpStatusCodeOk)
        }
        var statusMessage: String? = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        let result = object

        // Handle error case
        if result == nil || error != nil {
            if error != nil {
                if statusCode > httpStatusCodeOk && statusCode < httpStatusCodeMultipleChoices {
                    statusMessage = error?.localizedDescription
                    statusCode = error!.code
                }
            } else {
                statusMessage = LOCALIZED("content_empty")
                statusCode = httpStatusCodeNoContent
            }
            isSuccess = false
        }
        if statusCode < httpStatusCodeOk || statusCode > httpStatusCodeMultipleChoices {
            if error != nil {
                if statusCode == httpStatusCodeUnauthorized {
                    statusMessage = LOCALIZED("error_unauthorized")
                } else if statusCode == httpStatusCodeInternalError {
                    statusMessage = LOCALIZED("error_500")
                } else if statusCode == httpStatusCodeTimeout {
                    statusMessage = LOCALIZED("error_408")
                } else if statusCode == httpStatusCodeConnectIssue {
                    statusMessage = LOCALIZED("error_code_-1020")
                } else if statusCode == httpStatusCodeConnectionOffline || statusCode == httpStatusCodeDeviceOffline {
                    statusMessage = LOCALIZED("error_code_-1009")
                } else if statusCode == httpStatusRequestTimeout {
                    statusMessage = LOCALIZED("error_code_-1001")
                } else {
                    statusMessage = error?.localizedDescription
                }
            }
            isSuccess = false
        }

        return RestResponse.build(
            result,
            isSuccess: isSuccess,
            statusCode: statusCode,
            allHeaderFields: allHeaderFields,
            statusMessage: statusMessage)
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override init() {
        super.init()
        _initSessionManager()
        _initSessionManagerUpload()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _initSessionManager(_ host: String? = nil) {
        let configuration = URLSessionConfiguration.af.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.timeoutIntervalForRequest = kDefaultRequestTimeOut
        configuration.timeoutIntervalForResource = kDefaultResourceRequestTimeOut
        configuration.allowsCellularAccess = true
        configuration.urlCredentialStorage = nil
        configuration.httpCookieAcceptPolicy = .always
        _sessionManager = Session(configuration: configuration, interceptor: _sessionRetrier, serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:]))
    }
    
    private func _initSessionManagerUpload(_ host: String? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.timeoutIntervalForRequest = kDefaultRequestLongTimeOut
        configuration.timeoutIntervalForResource = kDefaultResourceLongRequestTimeOut
        configuration.allowsCellularAccess = true
        configuration.urlCredentialStorage = nil
        configuration.httpCookieAcceptPolicy = .always
        _uploadSessionManager =  Session(configuration: configuration, interceptor: _sessionRetrier, serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:]))
    }

    private func _initLogging(_ request: RestRequest, isArrayParametes: Bool) {
        if !isArrayParametes {
            // logging for params
            if  request.parameters == nil {
                Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
            } else {
                Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.parameters ?? "nil"))
            }
        } else {
            // Logging for array params
            if request.arrayParameters == nil {
                Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
            } else {
                Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.arrayParameters ?? "nil"))
            }
        }
    }

    private func _generateHeaders(headerDict: [String: String]) -> HTTPHeaders {
        var httpHeaders: HTTPHeaders = HTTPHeaders()
        headerDict.forEach { key, value in
            httpHeaders.add(HTTPHeader.init(name: key, value: value))
        }
        return httpHeaders
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func invoke(_ request: RestRequest, retryCount: Int = 3, callback: RestCallback? = nil) {
        _initLogging(request, isArrayParametes: false)
        let headers = _generateHeaders(headerDict: request.headers)
        // Request
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method),
            parameters: request.parameters,
            encoding: JSONEncoding.default,
            headers: headers)
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        dataRequest.response { _ in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseJSON { response in
            let httpUrlResponse = response.response
            var object: [String: Any] = [:]
            do {
                if let data = response.data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    object = json
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))------------ \(error != nil ? String.init(describing: request.headers)  : "")")
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }
    
    public func invokeArray(_ request: RestRequest, retryCount: Int = 3, callback: RestCallback? = nil) {

        // Logging
        _initLogging(request, isArrayParametes: true)
        let headers = _generateHeaders(headerDict: request.headers)
        // Request
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method),
            parameters: request.arrayParameters?.asParameters(),
            encoding: ArrayEncoding(),
            headers: headers)
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        dataRequest.response { _ in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseJSON { response in
            let httpUrlResponse = response.response
            var object: [String: Any] = [:]
            do {
                if let data = response.data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    object = json
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))")
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    public func genericInvoke(_ request: RestRequest, retryCount: Int = 3, callback: RestCallback? = nil) {

        // Logging
        _initLogging(request, isArrayParametes: false)
        let headers = _generateHeaders(headerDict: request.headers)
        // Request
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method),
            parameters: request.parameters,
            headers: headers)
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        dataRequest.response { _ in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseJSON { response in
            let httpUrlResponse = response.response
            var object: [String: Any] = [:]
            if let data = response.data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        object = json
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")

                }
            }
            do {
                if let data = response.data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                    let objcDict: [String: Any] = ["data": json]
                    object = objcDict
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))")
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    public func uploadDataInvoke( _ request: RestRequest, callback: RestCallback? = nil) {
        // Logging
        _initLogging(request, isArrayParametes: false)
        let headers = _generateHeaders(headerDict: request.headers)
        // Upload Request
        let uploadRequest = _uploadSessionManager.upload(multipartFormData: {multipartFormData in
            request.parameters?.forEach({ key, value in
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            })
        }, to: request.url, method: HTTPMethod(rawValue: request.method), headers: headers)
        uploadRequest.uploadProgress { progress in
            let value =  Int(progress.fractionCompleted * 100)
            print("\(value) %")
        }
        uploadRequest.responseJSON { response in
            let httpUrlResponse = response.response
            var object: [String: Any] = [:]
            do {
                if let data = response.data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    object = json
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))")
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }

    }

    public func uploadInvoke(_ request: RestRequest, callback: RestCallback? = nil) {
        // logging
        _initLogging(request, isArrayParametes: false)
        // header
        let headers = _generateHeaders(headerDict: request.headers)
        // Upload Request
        let uploadRequest = _sessionManager.upload(
            URL(fileURLWithPath: request.filePath!),
            to: request.url,
            method: HTTPMethod(rawValue: request.method!),
            headers: headers)
        uploadRequest.responseJSON { response in
            let httpUrlResponse = response.response
            let object = ["status": "success"]
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))")
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    public func booleanInvoke(_ request: RestRequest, encoding: String, callback: RestCallback? = nil) {
        // logging
        _initLogging(request, isArrayParametes: false)
        // header
        let headers = _generateHeaders(headerDict: request.headers)
        // Request
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method!),
            parameters: request.parameters ?? [:],
            encoding: JSONEncoding.default,
            headers: headers)
        dataRequest.response { response in
            let httpUrlResponse = response.response
            let object = ["status": "success"]
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))")
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    public func stringInvoke(_ request: RestRequest, encoding: String, retryCount: Int = 3, callback: RestCallback? = nil) {
        // logging
        _initLogging(request, isArrayParametes: false)
        // header
        let headers = _generateHeaders(headerDict: request.headers)

        // Request
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method!),
            parameters: request.parameters ?? [:],
            encoding: encoding != "" ? JSONEncoding.default : URLEncoding.default,
            headers: headers)
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        dataRequest.response { _ in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseString { response in
            let httpUrlResponse = response.response
            let object = response.value
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))")
            let restReponse = RestClient._validString(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    public func multiPartInvoke(_ request: RestRequest, retryCount: Int = 3, callback: RestCallback? = nil) {
        // Logging
        if request.parameters == nil {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
        } else {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.parameters ?? "nil"))
        }
        let headers = _generateHeaders(headerDict: request.headers)
        let uploadRequest = _uploadSessionManager.upload(multipartFormData: {multipartFormData in
            request.parameters?.forEach({ key, value in
                if value is URL{
                    multipartFormData.append(value as! URL, withName: key)
                } else if value is Data {
                    multipartFormData.append(value as! Data, withName: key)
                } else if value is String {
                    if let data = (value as? String)?.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                } else if value is Int {
                    if let data = String(value as! Int).data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            })
        }, to: request.url, method: HTTPMethod(rawValue: request.method), headers: headers)
        _sessionRetrier.addRetryInfo(request: uploadRequest, retryCount: retryCount)
        uploadRequest.uploadProgress { progress in
            let value =  Int(progress.fractionCompleted * 100)
            print("\(value) %")
        }.response { _ in
            self._sessionRetrier.deleteRetryInfo(request: uploadRequest)
        }.responseJSON { response in
            let httpUrlResponse = response.response
            var object: [String: Any] = [:]
            do {
                if let data = response.data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    object = json
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            let error = response.error as NSError?
            Log.debug("loading-------- \(String(describing: request.url))-------------------- \(String(describing: error?.localizedDescription))------------ \(error != nil ? String.init(describing: request.headers)  : "")")
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }
}


extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with _: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

extension Array {
    func asParameters() -> Parameters {
        ["kArrayParameters": self]
    }
}

struct ArrayEncoding: ParameterEncoding {

    public let options: JSONSerialization.WritingOptions

    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters,
              let array = parameters["kArrayParameters"] else {
                  return urlRequest
              }

        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            if urlRequest.value(forHTTPHeaderField: httpRequestHeaderNameAccept) == nil {
                urlRequest.setValue(httpRequestContentJson, forHTTPHeaderField: httpRequestHeaderNameAccept)
            }
            if urlRequest.value(forHTTPHeaderField: httpRequestHeaderNameContentType) == nil {
                urlRequest.setValue(httpRequestContentJson, forHTTPHeaderField: httpRequestHeaderNameContentType)
            }

            urlRequest.httpBody = data

        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
    }
}

class SessionRetrier: RequestInterceptor {
    private var _requestsAndRetryCounts: [(Request, Int)] = []
    private var _lock = NSLock()

    private func index(request: Request) -> Int? {
        return _requestsAndRetryCounts.firstIndex(where: { $0.0 === request })
    }

    func addRetryInfo(request: Request, retryCount: Int? = nil) {
        _lock.lock() ; defer { _lock.unlock() }
        guard index(request: request) == nil else { Log.error("ERROR addRetryInfo called for already tracked request"); return }
        _requestsAndRetryCounts.append((request, retryCount ?? kDefaultRetryCount))
    }

    func deleteRetryInfo(request: Request) {
        _lock.lock() ; defer { _lock.unlock() }
        guard let index = index(request: request) else { Log.error("ERROR deleteRetryInfo called for not tracked request"); return }
        _requestsAndRetryCounts.remove(at: index)
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        _lock.lock() ; defer { _lock.unlock() }

        guard let index = index(request: request) else {
            completion(.doNotRetryWithError(error))
            return }
        let (request, retryCount) = _requestsAndRetryCounts[index]

        if retryCount == 0 {
            completion(.doNotRetry)
        } else {
            Log.debug("Failed to connect to server=\(String(describing: request.request?.url)) retry=\(retryCount - 1)")
            _requestsAndRetryCounts[index] = (request, retryCount - 1)
            completion(.retryWithDelay(0.5))
        }
    }
}

