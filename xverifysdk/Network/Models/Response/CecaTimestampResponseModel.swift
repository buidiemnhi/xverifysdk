//
//  CecaTimestampResponseModel.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import ObjectMapper

public class CecaTimestampResponseModel: Mappable, ModelProtocol {
    
    public dynamic var algorithm: String = ""
    public dynamic var timestamp: Date?
    public dynamic var timestampToken: String = ""
    public dynamic var transactionId: String = ""
    
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDateISO8601UTC)
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        algorithm <- map["algorithm"]
        timestamp <- (map["timestamp"], DateFormatterTransform(dateFormatter: _dateFormatter))
        timestampToken <- map["timestampToken"]
        transactionId <- map["transactionId"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public func isValid() -> Bool {
        return !stringIsNullOrEmpty(transactionId)
    }
}
