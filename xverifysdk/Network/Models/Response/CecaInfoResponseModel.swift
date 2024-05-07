//
//  CecaInfoResponseModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaInfoResponseModel: Mappable, ModelProtocol {
    
    public dynamic var referenceMessageId: String = ""
    public dynamic var responseCode: Int = 0
    public dynamic var responseMessage: String = ""
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        referenceMessageId <- map["referenceMessageId"]
        responseCode <- map["responseCode"]
        responseMessage <- map["responseMessage"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return responseCode == 0
    }
    
}
