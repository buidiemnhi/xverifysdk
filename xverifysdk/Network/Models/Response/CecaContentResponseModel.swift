//
//  CecaContentResponseModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaContentResponseModel: Mappable, ModelProtocol {
    
    public dynamic var transactionId: String = ""
    public dynamic var data: CecaDataResponseModel?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        transactionId <- map["transactionId"]
        data <- map["data"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return !stringIsNullOrEmpty(transactionId)
    }
    
}
