//
//  MRZInfo.swift
//  xverifysdk
//
//  Created by Minh Tri on 18/11/2023.
//

import Foundation

public class MRZInfo {
    
    public var documentType: DocTypeEnum
    public var documentCode: String
    public var issuingState: String
    public var nationality: String
    public var documentNumber: String
    public var dateOfBirth: String
    public var gender: String
    public var dateOfExpiry: String
    
    private init(documentType: DocTypeEnum,
                 documentCode: String,
                 issuingState: String,
                 documentNumber: String,
                 dateOfBirth: String,
                 gender: String,
                 dateOfExpiry: String,
                 nationality: String) {
        self.documentType = documentType
        self.documentCode = documentCode
        self.issuingState = issuingState
        self.documentNumber = documentNumber
        self.nationality = nationality
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.dateOfExpiry = dateOfExpiry
    }

    public static func createTD1MRZInfo(documentCode: String,
                         issuingState: String,
                         documentNumber: String,
                         dateOfBirth: String,
                         gender: String,
                         dateOfExpiry: String,
                         nationality: String) -> MRZInfo {
        return MRZInfo(documentType: .TD1,
                       documentCode: documentCode,
                       issuingState: issuingState,
                       documentNumber: documentNumber,
                       dateOfBirth: dateOfBirth,
                       gender: gender,
                       dateOfExpiry: dateOfExpiry,
                       nationality: nationality)
    }
}
