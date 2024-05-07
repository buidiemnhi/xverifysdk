//
//  CecaDataResponseModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaDataResponseModel: Mappable, ModelProtocol {
    
    public dynamic var verifyData: CecaVerifyDataResponseModel?
    public dynamic var timestamp: CecaTimestampResponseModel?
    public dynamic var providerSignature: String = ""
        
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        verifyData <- map["verifyData"]
        timestamp <- map["timestamp"]
        providerSignature <- map["ProviderSignature"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return !stringIsNullOrEmpty(providerSignature)
    }
    
}
