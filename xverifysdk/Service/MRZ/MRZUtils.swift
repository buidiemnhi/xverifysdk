//
//  MRZUtils.swift
//  xverifysdk
//
//  Created by Minh Tri on 18/11/2023.
//

import UIKit
import MLKitVision
import MLKitTextRecognition

public class MRZUtils {
    
    static let patternLine1 = "[0-9IDVNM]{5}(?<documentNumber>[0-9ILDSOG]{9})(?<checkDigitDocumentNumber>[0-9ILDSOG]{1})(?<fullDocumentNumber>[0-9ILDSOG]{12})[A-Z<]{2}[0-9]{1}"
    static let patternLine2 = "(?<dateOfBirth>[0-9ILDSOG]{6})(?<checkDigitDateOfBirth>[0-9ILDSOG]{1})(?<sex>[FM<]){1}(?<expirationDate>[0-9ILDSOG]{6})(?<checkDigitExpiration>[0-9ILDSOG]{1})(?<nationality>[A-Z<]{3}).+[0-9]{1}"
    static let patternLine3 = "[-]\\w+[A-Z][<]{1}[A-Z<]\\w+[A-Z<]{1}.+[-]"
    static let patternNumber = "[0-9]"

    // --------------------------------------
    // MARK: Initialize
    // --------------------------------------
    
    private init() {
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    public static func processMRZ(sampleBuffer: CMSampleBuffer, timeRequired: Int, callback: @escaping (_ data: MRZInfo?) -> Void) {
        guard let results = recognizeTextOnDevice(sampleBuffer: sampleBuffer) else {
            callback(nil)
            return
        }
        
        textProcessing(data: results) { data in
            if let data = data {
                callback(data)
            } else {
                callback(nil)
            }
        }
        
    }
    
    public static func processMRZ(image: UIImage, timeRequired: Int, callback: @escaping (_ data: MRZInfo?) -> Void) {
        DISPATCH_ASYNC_BG {
            guard let results = recognizeTextOnDevice(image: image) else {
                callback(nil)
                return
            }
            textProcessing(data: results) { data in
                if let data = data {
                    DISPATCH_ASYNC_MAIN {
                        callback(data)
                    }
                } else {
                    callback(nil)
                }
            }
        }
    }
    
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    private static func recognizeTextOnDevice(sampleBuffer: CMSampleBuffer) -> Text? {
        
        let image = VisionImage(buffer: sampleBuffer)
        image.orientation = MLKitUtils.imageOrientation(fromDevicePosition: .back)
        
        let options = TextRecognizerOptions()
        var recognizedText: Text?
        var detectionError: Error?
        do {
            recognizedText = try TextRecognizer.textRecognizer(options: options).results(in: image)
        } catch let error {
            detectionError = error
        }
        
        DISPATCH_ASYNC_MAIN {
            if let detectionError = detectionError {
              print("Failed to recognize text with error: \(detectionError.localizedDescription).")
              return
            }
            
            guard let recognizedText = recognizedText else {
                print("Text recognition returned no results.")
                return
            }
        }
        return recognizedText
    }
    
    private static func recognizeTextOnDevice(image: UIImage) -> Text? {
        let image = VisionImage(image: image)
        image.orientation = MLKitUtils.imageOrientation(fromDevicePosition: .back)
        
        let options = TextRecognizerOptions()
        var recognizedText: Text?
        var detectionError: Error?
        do {
            recognizedText = try TextRecognizer.textRecognizer(options: options).results(in: image)
        } catch let error {
            detectionError = error
        }
        
        DISPATCH_ASYNC_MAIN {
            if let detectionError = detectionError {
              print("Failed to recognize text with error: \(detectionError.localizedDescription).")
              return
            }
            
            guard let _ = recognizedText else {
                print("Text recognition returned no results.")
                return
            }
        }
        return recognizedText
    }

    private static func createMRZTD(issuingState: String, documentNumber: String, dateOfBirth: String, gender: String, dateOfExpiry: String, nationality: String) -> MRZInfo {
        return MRZInfo.createTD1MRZInfo(
            documentCode: "I",
            issuingState: issuingState,
            documentNumber: documentNumber,
            dateOfBirth: dateOfBirth,
            gender: gender,
            dateOfExpiry: dateOfExpiry,
            nationality: nationality)
    }

    private static func cleanDate(date: String) -> String {
        var tempDate = date
        tempDate = tempDate.replacingOccurrences(of: "I", with: "1")
        tempDate = tempDate.replacingOccurrences(of: "L", with: "1")
        tempDate = tempDate.replacingOccurrences(of: "D", with: "0")
        tempDate = tempDate.replacingOccurrences(of: "O", with: "0")
        tempDate = tempDate.replacingOccurrences(of: "S", with: "5")
        tempDate = tempDate.replacingOccurrences(of: "G", with: "6")
        return tempDate
    }
    
    private static func textProcessing(data:Text, callback: @escaping (_ data: MRZInfo?) -> Void) {
        var fullRead = ""
        for block in data.blocks {
            var temp = ""
            for line in block.lines {
                temp += line.text + "-"
            }
            temp = temp.replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: " ", with: "")
            fullRead += "\(temp)-"
        }
        fullRead = fullRead.uppercased()
        let matcherLineIeIDTypeLine1 = fullRead.matchingStrings(regex: patternLine1)
        let matcherLineIeIDTypeLine2 = fullRead.matchingStrings(regex: patternLine2)
        let matcherLineIeIDTypeLine3 = fullRead.matchingStrings(regex: patternLine3)
        
        if matcherLineIeIDTypeLine1.count > 0 && matcherLineIeIDTypeLine2.count > 0 && matcherLineIeIDTypeLine3.count > 0 {
            let line1 = matcherLineIeIDTypeLine1[0]
            let line2 = matcherLineIeIDTypeLine2[0]
            let line3 = matcherLineIeIDTypeLine3[0]
            
            let documentNumber = cleanDate(date: line1[1])
            //let checkDigitDocumentNumber = cleanDate(date: line1[1])
            //let fullDocumentNumber = cleanDate(date: line1[3])
            let dateOfBirthDay = cleanDate(date: line2[1])
            //let checkDigitDateOfBirth = cleanDate(date: line2[2])
            let sex = line2[3]
            let dateOfExpiry = cleanDate(date: line2[4])
            //let checkDigitExpiration = cleanDate(date:line2[5])
            let nationality = line2[6]
     
            var line3Temp = line3[0].replacingOccurrences(of: "«", with: "<")
            let cleanLine3 = line3Temp.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            let splitName = cleanLine3.split(separator: "<")
            
            var nameIsSuccess = false
            var firstName = ""
            var lastName = ""
            print(splitName)
            if splitName.count > 2 {
                nameIsSuccess = true
                firstName = String(splitName[2])
                lastName = String(splitName[0])
            }
            
            if lastName.matchingStrings(regex: patternNumber).count > 0 || firstName.matchingStrings(regex: patternNumber).count > 0 {
                nameIsSuccess = false
            }

            var gender = ""
            if sex == "M" {
                gender = "Male"
            } else if sex == "F" {
                gender = "Female"
            }
            print("Lastname \(lastName) Firstname \(firstName)")
            let mrzInfo = createMRZTD(
                issuingState: nationality,
                documentNumber: documentNumber,
                dateOfBirth: dateOfBirthDay,
                gender: gender,
                dateOfExpiry: dateOfExpiry,
                nationality: nationality
            )
            callback(mrzInfo)
        } else { // No Success
            callback(nil)
        }
    }
}
