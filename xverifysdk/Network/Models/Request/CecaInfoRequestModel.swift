//
//  CecaInfoRequestModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaInfoRequestModel: Mappable, ModelProtocol {
    
    public dynamic var version: String = "1.0.0"
    public dynamic var senderId: String = ""
    public dynamic var receiverId: String = ""
    public dynamic var messageType: Int = 0
    public dynamic var sendDate: Int64 = 0
    public dynamic var messageId: String = "1"
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        version <- map["version"]
        senderId <- map["senderId"]
        receiverId <- map["receiverId"]
        messageType <- map["messageType"]
        sendDate <- map["sendDate"]
        messageId <- map["messageId"]
    }
    
    public func toJsonObj () -> [String: Any] {
        var params: [String: Any] = [:]
        params["version"] = version
        params["senderId"] = senderId
        params["receiverId"] = receiverId
        params["messageType"] = messageType
        params["sendDate"] = sendDate
        params["messageId"] = messageId
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
        return "{\"version\":\"\(version)\",\"senderId\":\"\(senderId)\",\"receiverId\":\"\(receiverId)\",\"messageType\":\(messageType),\"sendDate\":\(sendDate),\"messageId\": \"\(messageId)\"}"
    }
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return true
    }
}
