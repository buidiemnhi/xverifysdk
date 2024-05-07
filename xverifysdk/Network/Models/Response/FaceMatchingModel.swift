//
//  LivenessVerifyModel.swift
//  xverifysdk
//
//  Created by Minh Tri on 01/12/2023.
//

import Foundation

public struct FaceMatchingModel: Codable {
    public let transactionCode: String
    public let invalidCode: Int
    public let invalidMessage: String
    public let isMatch: Bool
    public let matching: String
    public let match: String
    
    enum CodingKeys: String, CodingKey {
        case invalidCode = "invalid_code"
        case invalidMessage = "invalid_message"
        case isMatch = "is_matching"
        case matching = "matching"
        case match = "match"
        case transactionCode = "transaction_code"
    }
}
