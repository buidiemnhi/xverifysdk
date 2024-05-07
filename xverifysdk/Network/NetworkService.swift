
import Foundation
import Alamofire
import UIKit

enum DataError: Error, LocalizedError {
    case rejected(String)
    
    var errorDescription: String? {
        switch self {
        case .rejected (let message):
            return NSLocalizedString(message, comment: "")
        }
    }
}

public struct APIResponse<T: Decodable>: Decodable {
    let success: Bool?
    let error: ErrorModel?
    let message: String?
    var data: T?
    
    private enum CodingKeys: String, CodingKey {
        case success = "success"
        case error = "error"
        case data = "data"
        case message = "message"
    }
}

public class NetworkService {
    private var headers: HTTPHeaders
    private var session: Session
    private var proto: String
    private var hostname: String
    
    
    public init(proto: String, hostname: String, customHeaders: [String: String]) {
        self.proto = proto
        self.hostname = hostname
        
        self.headers = HTTPHeaders()
        self.headers["Content-Type"] = "application/json"
        self.headers["Accept"] = "application/json"
        
        for (key, value) in customHeaders {
            self.headers[key] = value
        }
        
        // Custom configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7000 // Set connect timeout to 7000 seconds
        configuration.timeoutIntervalForResource = 600 // Set read timeout to 600 seconds
        
        // Custom ServerTrustManager that trusts all SSL certificates
        let serverTrustManager = ServerTrustManager(evaluators: [self.hostname: DisabledTrustEvaluator()])
        
        // Create a custom session
        self.session = Session(configuration: configuration, serverTrustManager: serverTrustManager)
    }
    
    private func fetchData<T: Decodable>(url: URL,
                                         method: HTTPMethod = .get,
                                         parameters: Parameters? = nil,
                                         headers: HTTPHeaders? = nil,
                                         completion: @escaping (Result<T, Error>) -> Void) {
        
        DispatchQueue.global().async {
            self.session.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
                DispatchQueue.main.async {
                    switch (response.result) {
                    case .success(let data):
                        do {
                            let json = String(data: data, encoding: .utf8)
                            print("Original JSON:")
                            print(json ?? "Failed to convert data to string")
                            
                            var apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                            
                            if var model = apiResponse as? APIResponse<EidVerifyModel> {
                                if let range = json?.range(of: "\"responds\":\\s*\\{[\\s\\S]*?\\}", options: .regularExpression) {
                                    let respondsData = String(json![range])
                                    print("Extracted Responds:")
                                    print(respondsData)
                                    
                                    model.data?.responds = String(respondsData.suffix(from: respondsData.index(respondsData.startIndex, offsetBy: 11)))
                                    apiResponse = model as! APIResponse<T>
                                } else {
                                    print("Pattern not found.")
                                }
                            }
                            
                            if apiResponse.success ?? false {
                                completion(.success(apiResponse.data!))
                            } else {
                                completion(.failure(DataError.rejected(apiResponse.error?.message ?? apiResponse.message ?? "Server responds error")))
                            }
                        } catch let error {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func fetchEidData(url: URL,
                              method: HTTPMethod = .get,
                              parameters: Parameters? = nil,
                              headers: HTTPHeaders? = nil,
                              completion: @escaping (Result<CecaVerifyResponseModel, Error>) -> Void) {
        
        DispatchQueue.global().async {
            self.session.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
                DispatchQueue.main.async {
                    switch (response.result) {
                    case .success(let data):
                        do {
                            let jsonString = String(data: data, encoding: .utf8) ?? ""
                            print("Original JSON: \(jsonString)")
                            if let data = jsonString.data(using: .utf8) {
                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                                if let model = CecaVerifyResponseModel(JSON: json ?? [String:Any]()) {
                                    if let info = model.info {
                                        if info.responseCode == 0 {
                                            completion(.success(model))
                                        } else {
                                            completion(.failure(DataError.rejected(info.responseMessage)))
                                        }
                                    }
                                }
                            }
                            
                        } catch let error {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func constructURL(path: String) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.proto
        urlComponents.host = self.hostname
        urlComponents.path = path
        
        return urlComponents.url!
    }
    
    public func setCustomsHeader(customHeaders: [String: String]) {
        for (key, value) in customHeaders {
            self.headers[key] = value
        }
    }
    
    public func get<T: Decodable>(path: String, parameters: Parameters? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        return self.fetchData(url: constructURL(path: path), method: .get, parameters: parameters, headers: self.headers, completion: completion)
    }
    
    public func post<T: Decodable>(path: String, parameters: Parameters? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        return self.fetchData(url: constructURL(path: path), method: .post, parameters: parameters, headers: self.headers, completion: completion)
    }
    
    public func postEid(path: String, parameters: Parameters? = nil, completion: @escaping (Result<CecaVerifyResponseModel, Error>) -> Void) {
        return self.fetchEidData(url: constructURL(path: path), method: .post, parameters: parameters, headers: self.headers, completion: completion)
    }
    
    public func uploadFile<T: Decodable>(path: String, pathFace: URL, pathLeft: URL, pathRight:URL, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let dataMid = try? Data(contentsOf: pathFace),
              let dataLeft = try? Data(contentsOf: pathLeft),
              let dataRight = try? Data(contentsOf: pathRight)
        else {
            return
        }
        let url = constructURL(path: path)
        let fileMidName = pathFace.lastPathComponent
        let fileLeftName = pathLeft.lastPathComponent
        let fileRightName = pathRight.lastPathComponent
        self.session.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(dataLeft, withName: "portrait_left", fileName: fileLeftName, mimeType: "multipart/form-data")
                multipartFormData.append(dataMid, withName: "portrait_mid", fileName: fileMidName, mimeType: "multipart/form-data")
                multipartFormData.append(dataRight, withName: "portrait_right", fileName: fileRightName, mimeType: "multipart/form-data")
            },
            to: url,
            usingThreshold: .max,
            method: .post,
            headers: self.headers).responseData { response in
                DispatchQueue.main.async {
                    switch (response.result) {
                    case .success(let data):
                        do {
                            let json = String(data: data, encoding: .utf8)
                            print("Original JSON:")
                            print(json ?? "Failed to convert data to string")
                            
                            let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                            print(apiResponse)
                            if let model = apiResponse as? APIResponse<LivenessVerifyModel> {
                                if let _ = model.data {
                                    if let data = apiResponse.data {
                                        completion(.success(data))
                                    } else {
                                        completion(.failure(DataError.rejected(apiResponse.error?.message ?? apiResponse.message ?? "Server responds error")))
                                    }
                                }
                                return
                            }
                            completion(.failure(DataError.rejected(apiResponse.error?.message ?? apiResponse.message ?? "Server responds error")))
                        } catch let error {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    public func uploadFaceMatchingFile<T: Decodable>(path: String, originFacePath: URL, capturedFacePath: URL, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let dataOriginFace = try? Data(contentsOf: originFacePath),
              let dataCapturedFace = try? Data(contentsOf: capturedFacePath)
        else {
            return
        }
        let url = constructURL(path: path)
        let fileName1 = originFacePath.lastPathComponent
        let fileName2 = capturedFacePath.lastPathComponent
        print("originFacePath \(fileName1)")
        print("capturedFacePath \(fileName2)")
        self.session.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(dataOriginFace, withName: "img1", fileName: fileName1, mimeType: "multipart/form-data")
                multipartFormData.append(dataCapturedFace, withName: "img2", fileName: fileName2, mimeType: "multipart/form-data")
            },
            to: url,
            usingThreshold: .max,
            method: .post,
            headers: self.headers).responseData { response in
                DispatchQueue.main.async {
                    switch (response.result) {
                    case .success(let data):
                        do {
                            let json = String(data: data, encoding: .utf8)
                            print("Original JSON: \(json)")
                            
                            let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                            print(apiResponse)
                            if let model = apiResponse as? APIResponse<FaceMatchingModel> {
                                if let _ = model.data {
                                    if let data = apiResponse.data {
                                        completion(.success(data))
                                    } else {
                                        completion(.failure(DataError.rejected(apiResponse.error?.message ?? apiResponse.message ?? "Server responds error")))
                                    }
                                }
                                return
                            }
                            completion(.failure(DataError.rejected(apiResponse.error?.message ?? apiResponse.message ?? "Server responds error")))
                        } catch let error {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    
    public func uploadOCRFile<T: Decodable>(path: String, frontPath: URL, backPath: URL, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let front = try? Data(contentsOf: frontPath),
              let back = try? Data(contentsOf: backPath)
        else {
            return
        }
        let url = constructURL(path: path)
        let fileName1 = frontPath.lastPathComponent
        let fileName2 = backPath.lastPathComponent
        print("front: \(fileName1)")
        print("back: \(fileName2)")
        self.session.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(front, withName: "img1", fileName: fileName1, mimeType: "multipart/form-data")
                multipartFormData.append(back, withName: "img2", fileName: fileName2, mimeType: "multipart/form-data")
            },
            to: url,
            usingThreshold: .max,
            method: .post,
            headers: self.headers).responseData { response in
                DispatchQueue.main.async {
                    switch (response.result) {
                    case .success(let data):
                        do {
                            let json = String(data: data, encoding: .utf8)
                            print("Original JSON: \(json)")
                            
                            let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                            print(apiResponse)
                            if let model = apiResponse as? APIResponse<OCRResponseModel> {
                                if let data = model.data {
                                    completion(.success(apiResponse.data!))
                                } else {
                                    completion(.failure(DataError.rejected(apiResponse.error?.message ?? apiResponse.message ?? "Server responds error")))
                                }
                                return
                            }
                            completion(.failure(DataError.rejected(apiResponse.error?.message ?? apiResponse.message ?? "Server responds error")))
                        } catch let error {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
}



