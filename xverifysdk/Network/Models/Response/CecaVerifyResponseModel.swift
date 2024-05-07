//
//  CecaVerifyResponseModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaVerifyResponseModel: Mappable, ModelProtocol {
    
    public dynamic var info: CecaInfoResponseModel?
    public dynamic var content: CecaContentResponseModel?
    public dynamic var signature: String = ""
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        info <- map["info"]
        content <- map["content"]
        signature <- map["signature"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return info != nil && content != nil && !stringIsNullOrEmpty(signature)
    }
    
}
