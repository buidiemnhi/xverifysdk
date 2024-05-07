

class Common {
    
    class func getMRZKey(eidNumber: String, dateOfBirth: String, dateOfExpiry: String ) -> String {
        
        // Pad fields if necessary
        let eidNr = pad(eidNumber, fieldLength:9)
        let dob = pad(dateOfBirth, fieldLength:6)
        let exp = pad(dateOfExpiry, fieldLength:6)
        
        // Calculate checksums
        let eirNrChksum = calcCheckSum(eidNr)
        let dateOfBirthChksum = calcCheckSum(dob)
        let expiryDateChksum = calcCheckSum(exp)
        
        let mrzKey = "\(eidNr)\(eirNrChksum)\(dob)\(dateOfBirthChksum)\(exp)\(expiryDateChksum)"
        
        return mrzKey
    }
    
    class func pad( _ value : String, fieldLength:Int ) -> String {
        let paddedValue = (value + String(repeating: "<", count: fieldLength)).prefix(fieldLength)
        return String(paddedValue)
    }
    
    class func calcCheckSum( _ checkString : String ) -> Int {
        let characterDict  = ["0" : "0", "1" : "1", "2" : "2", "3" : "3", "4" : "4", "5" : "5", "6" : "6", "7" : "7", "8" : "8", "9" : "9", "<" : "0", " " : "0", "A" : "10", "B" : "11", "C" : "12", "D" : "13", "E" : "14", "F" : "15", "G" : "16", "H" : "17", "I" : "18", "J" : "19", "K" : "20", "L" : "21", "M" : "22", "N" : "23", "O" : "24", "P" : "25", "Q" : "26", "R" : "27", "S" : "28","T" : "29", "U" : "30", "V" : "31", "W" : "32", "X" : "33", "Y" : "34", "Z" : "35"]
        
        var sum = 0
        var m = 0
        let multipliers : [Int] = [7, 3, 1]
        for c in checkString {
            guard let lookup = characterDict["\(c)"],
                  let number = Int(lookup) else { return 0 }
            let product = number * multipliers[m]
            sum += product
            m = (m+1) % 3
        }
        
        return (sum % 10)
    }
    
    class func retrievePublicKey(_ url: URL) -> SecKey? {
        guard let pemString = try? String(contentsOf: url) else {
            Log.error("Failed to read PEM file")
            return nil
        }

        let keyBase64 = pemString.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
                                         .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
                                         .replacingOccurrences(of: "\n", with: "")
                                         .replacingOccurrences(of: "\r", with: "")

        guard let data = Data(base64Encoded: keyBase64) else {
            Log.error("Failed to decode base64 key data")
            return nil
        }

        let keyDict: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: 2048),
            kSecReturnPersistentRef: false
        ]        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(data as CFData, keyDict as CFDictionary, &error) else {
            print("Failed to create key, \(error.debugDescription)")
            return nil
        }
        
        return secKey
    }
}
