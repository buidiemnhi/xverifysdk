//
//  ContentRequestModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaContentRequestModel: Mappable, ModelProtocol {
    
    public dynamic var transactionId: String = "1.0.0"
    public dynamic var data: CecaDataRequestModel?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        transactionId <- map["transactionId"]
        data <- map["data"]
    }
    
    public func toJsonObj () -> [String: Any] {
        var params: [String: Any] = [:]
        params["transactionId"] = transactionId
        if let data = data {
            params["data"] = data.toJsonObj()
        }
        return params
    }
    
    public func toJsonString() -> String {
//        do {
//          let data = try JSONSerialization.data(withJSONObject: toJsonObj(), options: JSONSerialization.WritingOptions.prettyPrinted)
//          if let string = String(data: data, encoding: String.Encoding.utf8) {
//            return string
//          }
//        } catch {
//          print(error)
//        }
        return "{\"transactionId\":\"\(transactionId)\",\"data\":\(data?.toJsonString() ?? "")}"
    }
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return true
    }
    
}
