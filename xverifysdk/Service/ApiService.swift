
import Foundation

public let APISERVICE = ApiService.shared

public class ApiService {
    public static var shared: ApiService = ApiService()
    
    public static var EID_PROTOCOL = "https"
    public static var EID_HOSTNAME = "api.jth.vn";

    private static var EID_VERIFY_ENDPOINT              = "/eid/api/verify";
    private static var EID_VERIFY_LIVENESS_ENDPOINT     = "/ekyc/api/verify-liveness";
    private static var EID_FACE_MATCHING_ENDPOINT       = "/ekyc/api/face-match";
    private static var EID_VERIFY_CECA_ENDPOINT         = "/ceca/api/verify";
    private static var VERIFY_OCR_ENDPOINT = "/ekyc/api/verify-ocrid";
    
    private static var HEADER_X_API_KEY = "x-api-key";
    private static var HEADER_SERVICE_TYPE = "ServiceType";
    private static var HEADER_CUSTOMER_CODE = "code"
    private static var HEADER_OS_TYPE = "os-type"
    
    private var network: NetworkService?
    
    private var customerCode: String = ""
    
    private init() {
    }
    
    public func initialize(apiKey: String) {
        self.network = NetworkService(proto: ApiService.EID_PROTOCOL, hostname: ApiService.EID_HOSTNAME, customHeaders: [ApiService.HEADER_X_API_KEY: apiKey])
    }
    
    public func initialize(apiKey: String, apiBaseUrl: String, customerCode: String) {
        self.customerCode = customerCode
        self.network = NetworkService(proto: ApiService.EID_PROTOCOL, hostname: apiBaseUrl, customHeaders: [ApiService.HEADER_X_API_KEY: apiKey, ApiService.HEADER_CUSTOMER_CODE: customerCode,ApiService.HEADER_OS_TYPE: "iOS"])
    }
        
    public func verifyEid(path: String, idCard: String, dsCert: String, deviceType: String, province: String, code: String, completion: @escaping (Result<EidVerifyModel, Error>) -> Void) {
        
        var parameters = [String: Any]()
        parameters["id_card"] = idCard
        parameters["ds_cert"] = dsCert
        parameters["device_type"] = deviceType
        parameters["province"] = province
        parameters["code"] = self.customerCode
        
        network?.post(path: path == "" ? ApiService.EID_VERIFY_ENDPOINT : path, parameters: parameters, completion: completion)
    }
    
    public func verifyLiveness(path: String, pathFace: String, pathLeft: String, pathRight: String, completion: @escaping (Result<LivenessVerifyModel, Error>) -> Void) {
        if let pathLeftUrl = URL(string: pathLeft),
           let pathFaceUrl = URL(string: pathFace),
           let pathRightUrl = URL(string: pathRight) {
            network?.uploadFile(path: path == "" ? ApiService.EID_VERIFY_LIVENESS_ENDPOINT : path, pathFace: pathFaceUrl, pathLeft: pathLeftUrl, pathRight: pathRightUrl, completion: completion)
        }
    }
    
    public func verifyCecaEid(path: String, request: CecaRequestModel, serviceType: Int,  completion: @escaping (Result<CecaVerifyResponseModel, Error>) -> Void) {
        network?.setCustomsHeader(customHeaders: [ApiService.HEADER_SERVICE_TYPE:"\(serviceType)"])
        network?.postEid(path: path == "" ? ApiService.EID_VERIFY_CECA_ENDPOINT : path, parameters: request.toJsonObj(), completion: completion)
    }
    
    public func verifyFaceMatching(path: String, originFacePath: String, capturedFacePath: String, completion: @escaping (Result<FaceMatchingModel, Error>) -> Void) {
        if let originFacePathUrl = URL(string: originFacePath),
           let capturedFacePathUrl = URL(string: capturedFacePath) {
            network?.uploadFaceMatchingFile(path: path == "" ? ApiService.EID_FACE_MATCHING_ENDPOINT : path, originFacePath: originFacePathUrl, capturedFacePath: capturedFacePathUrl, completion: completion)
        }
    }
    
    public func verifyOCR(path: String, frontPath: String, backPath: String, completion: @escaping(Result<OCRResponseModel,Error>) -> Void) {
        if let frontPath = URL(string: frontPath),
           let backPath = URL(string: backPath) {
            network?.uploadOCRFile(path: path == "" ? ApiService.VERIFY_OCR_ENDPOINT : path, frontPath: frontPath, backPath: backPath, completion: completion)
        }
    }
}
