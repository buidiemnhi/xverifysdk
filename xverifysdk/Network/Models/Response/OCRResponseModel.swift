//
//  OCRResponseModel.swift
//  xverifysdk
//
//  Created by Huynh Minh Hieu on 18/03/2024.
//

import Foundation
public enum CardType: String, CaseIterable, Codable {
    
    case FRONT_ID_CARD_9    = "9_id_card_front"
    case BACK_ID_CARD_9     = "9_id_card_back"
    case FRONT_ID_CARD_12   = "12_id_card_front"
    case BACK_ID_CARD_12    = "12_id_card_back"
    case FRONT_CHIP_ID_CARD = "chip_id_card_front"
    case BACK_CHIP_ID_CARD  = "chip_id_card_back"
    case PASSPORT           = "passport"
    case UNKNOWN            = "unknown"
}


public struct OCRResponseModel: Codable {
    public let transactionCode: String
    public let name: String
    public let surName: String
    public let givenName: String
    public let personNumber: String
    public let dueDate: String
    public let gender: String
    public let address: String
    public let issuedDate: String
    public let nationality: String
    public let dateOfBirth: String
    public let frontType: CardType
    public let frontValid: Bool
    public let backType: CardType
    public let backValid: Bool
    public let identificationSign: String
    public let issuedAt: String
    public let passportNumber: String
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transactionCode = try container.decode(String.self, forKey: .transactionCode)
        self.name = try container.decode(String.self, forKey: .name)
        self.personNumber = try container.decode(String.self, forKey: .personNumber)
        self.dueDate = try container.decode(String.self, forKey: .dueDate)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.address = try container.decode(String.self, forKey: .address)
        self.issuedDate = try container.decode(String.self, forKey: .issuedDate)
        self.nationality = try container.decode(String.self, forKey: .nationality)
        self.dateOfBirth = try container.decode(String.self, forKey: .dateOfBirth)
        
        //in case api response return the type is empty string error decoded type, frontType will be assigned as UNKNOWN
        if let frontType = try? container.decode(CardType.self, forKey: .frontType) {
            self.frontType = frontType
        } else {
            self.frontType = .UNKNOWN
        }
        
        self.frontValid = try container.decode(Bool.self, forKey: .frontValid)
        
        //in case api response return the type is empty string or error decoded type, backType will be assigned as UNKNOWN
        if let backType = try? container.decode(CardType.self, forKey: .backType) {
            self.backType = backType
        } else {
            self.backType = .UNKNOWN
        }
        
        self.backValid = try container.decode(Bool.self, forKey: .backValid)
        
        self.identificationSign = try container.decodeIfPresent(String.self, forKey: .identificationSign) ?? ""
        
        self.passportNumber = try container.decodeIfPresent(String.self, forKey: .passportNumber) ?? ""
        
        
        self.issuedAt = try container.decodeIfPresent(String.self, forKey: .issuedAt) ?? ""
        self.surName = try container.decode(String.self, forKey: .surName)
        self.givenName = try container.decode(String.self, forKey: .givenName)
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionCode = "transaction_code"
        case name = "name"
        case personNumber = "person_number"
        case dueDate = "due_date"
        case gender = "gender"
        case address = "address"
        case issuedDate = "issued_date"
        case nationality = "nationality"
        case dateOfBirth = "date_of_birth"
        case frontType = "front_type"
        case frontValid = "front_valid"
        case backType = "back_type"
        case backValid = "back_valid"
        case identificationSign = "identification_sign"
        case issuedAt = "issued_at"
        case surName = "sur_name"
        case givenName = "given_name"
        case passportNumber = "passport_number"
    }
    
    public func getFrontType() -> CardType {
        return self.frontType
    }
    
    public func getBackType() -> CardType {
        return self.backType
    }
}
