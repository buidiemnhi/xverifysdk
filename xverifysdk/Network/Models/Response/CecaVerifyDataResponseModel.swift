//
//  CecaVerifyDataResponseModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaVerifyDataResponseModel: Mappable, ModelProtocol {
    
    public dynamic var cecaTransactionCode: String = ""
    public dynamic var isVerified: Bool = false
    public dynamic var idCardNumber: String = ""
    public dynamic var dsCert: String = ""
    public dynamic var timestamp: Date?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        cecaTransactionCode <- map["cecaTransactionCode"]
        isVerified <- map["daisVerifiedta"]
        idCardNumber <- map["idCardNumber"]
        dsCert <- map["dsCert"]
        timestamp <- map["timestamp"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return !stringIsNullOrEmpty(cecaTransactionCode)
    }
    
}
