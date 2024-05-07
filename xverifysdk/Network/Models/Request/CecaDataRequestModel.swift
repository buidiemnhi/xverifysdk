//
//  CecaDataRequestModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaDataRequestModel: Mappable, ModelProtocol {
    
    public dynamic var code: String = ""
    public dynamic var cecaTransactionCode: String = ""
    public dynamic var dsCert: String = ""
    public dynamic var idCardNumber: String = ""
    public dynamic var deviceType: String = ""
    public dynamic var province: String = ""
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        code <- map["code"]
        cecaTransactionCode <- map["ma_toan_trinh"]
        dsCert <- map["dsCert"]
        idCardNumber <- map["idCardNumber"]
        deviceType <- map["deviceType"]
        province <- map["province"]
    }
    
    public func toJsonObj () -> [String: Any] {
        var params: [String: Any] = [:]
        params["code"] = code
        params["ma_toan_trinh"] = cecaTransactionCode
        params["dsCert"] = dsCert
        params["idCardNumber"] = idCardNumber
        params["deviceType"] = deviceType
        params["province"] = province
        return params
    }
    
    public func toJsonString() -> String {
        return "{\"code\":\"\(code)\",\"ma_toan_trinh\":\"\(cecaTransactionCode)\",\"dsCert\":\"\(dsCert)\",\"idCardNumber\":\"\(idCardNumber)\",\"deviceType\":\"\(deviceType)\",\"province\": \"\(province)\"}"
    }
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return !stringIsNullOrEmpty(cecaTransactionCode)
    }
    
}
