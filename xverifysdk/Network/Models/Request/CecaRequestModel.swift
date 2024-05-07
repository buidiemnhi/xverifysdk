//
//  CecaRequestModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaRequestModel: Mappable, ModelProtocol {
    
    public dynamic var info: CecaInfoRequestModel?
    public dynamic var content: CecaContentRequestModel?
    public dynamic var signature: String = ""
    public dynamic var code: String = ""
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        info <- map["info"]
        content <- map["content"]
        signature <- map["signature"]
        code <- map["code"]
    }
    
    public func toJsonObj () -> [String: Any] {
        var params: [String: Any] = [:]
        if let info = info {
            params["info"] = info.toJsonObj()
        }
        
        if let content = content {
            params["content"] = content.toJsonObj()
        }
        
        params["signature"] = signature

        return params
    }
    
    public func toJsonString() -> String {
        do {
          let data = try JSONSerialization.data(withJSONObject: toJsonObj(), options: JSONSerialization.WritingOptions.prettyPrinted)
          if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
          }
        } catch {
          print(error)
        }
        return ""
    }
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return true
    }
    
}
