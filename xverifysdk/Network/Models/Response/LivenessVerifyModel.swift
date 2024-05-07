//
//  LivenessVerifyModel.swift
//  xverifysdk
//
//  Created by Minh Tri on 01/12/2023.
//

import Foundation

public struct LivenessVerifyModel: Codable {
    public let transactionCode: String
    public let invalidCode: Int
    public let invalidMessage: String
    public var matching_mid_left: String
    public let matching_mid_right: String
    public let isValid: Bool
    
    enum CodingKeys: String, CodingKey {
        case invalidCode = "invalid_code"
        case invalidMessage = "invalid_message"
        case matching_mid_left = "matching_mid_left"
        case matching_mid_right = "matching_mid_right"
        case isValid = "is_valid"
        case transactionCode = "transaction_code"
    }
}
