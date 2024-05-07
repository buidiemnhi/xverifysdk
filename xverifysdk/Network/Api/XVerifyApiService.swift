//
//  XVerifyService.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

class XVerifyApiService: BaseApiService {
    
    private static var CECA_EID_VERIFY_ENDPOINT = "/ceca/api/verify"
        
    private static var _baseApiUrl: String = "https://api.uat.ceca.gov.vn"
    private static var _apiKey: String = ""
    private static var _serviceType: String = ""
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private class var _service: XVerifyApiService {
        XVerifyApiService()
    }
    
    private class func _buildHeaders(serviceType: String) -> [String:String] {
        var customHeaders = headers
        customHeaders[httpRequestHeaderXApiKey] = _apiKey
        customHeaders["ServiceType"] = serviceType
        return customHeaders
    }
    
    // --------------------------------------
    // MARK: Initialization
    // --------------------------------------
    
    class func initialize(apiKey: String) {
        _apiKey = apiKey
    }
    
    class func initialize(baseApiUrl: String, apiKey: String) {
        _baseApiUrl = baseApiUrl
        _apiKey = apiKey
    }
    
    // --------------------------------------
    // MARK: Verify Service
    // --------------------------------------
    
//    class func verify(proxyUrl: String = "", proxyEndpoint: String = "", serviceType: String, request: CecaRequestModel, callback: ObjectResult<CecaVerifyResponseModel>? = nil) {
//        let url = BUILDURLENDPOINT(baseUrl: !stringIsNullOrEmpty(proxyUrl) ? proxyUrl : _baseApiUrl,
//                                   endPoint: !stringIsNullOrEmpty(proxyEndpoint) ? proxyEndpoint : CECA_EID_VERIFY_ENDPOINT)
//        var params: [String: Any] = [:]
//        let request = XVerifyApiService.POST(url, params, _buildHeaders(serviceType: serviceType))
//        _service.request(request, model: CecaVerifyResponseModel.self, callback: callback)
//    }
}
