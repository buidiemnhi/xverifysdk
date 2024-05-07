//
//  CecaUtils.swift
//  xverifysdk
//
//  Created by Minh Tri on 02/12/2023.
//

import CryptoKit
import Foundation

public class CecaUtils {
    
    public class func generateMessageId(senderId: String) -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "").uppercased()
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyMM"
        let date = df.string(from: Date())
        return "\(senderId)\(date)\(uuid)"
    }
    
    
    public class func generateSignature(secretKey: String, request: CecaRequestModel) -> String {
        // Convert info to string (A)
        guard let info = request.info, let content = request.content else { return ""}
        let infoStr = info.toJsonString().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        //let hashedInfo = SHA256.hash(data: Data(infoStr.utf8)).compactMap { String(format: "%02x", $0) }.joined().uppercased()
        let hashedInfo = infoStr.sha256().uppercased()
        print("info = \(infoStr) hashedInfo = \(hashedInfo)")
        
        // Convert content to hash (B)
        let contentStr = content.toJsonString().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        //let hashedContent = SHA256.hash(data: Data(contentStr.utf8)).compactMap { String(format: "%02x", $0) }.joined().uppercased()
        let hashedContent = contentStr.sha256().uppercased()
        print("content = \(contentStr) hashedContent = \(hashedInfo)")
        
        // Combine the hash
        let combined = "\(hashedInfo).\(hashedContent)"
        let signature = HMAC<SHA256>.authenticationCode(for: Data(combined.utf8), using: SymmetricKey(data: Data(secretKey.utf8))).compactMap { String(format: "%02x", $0) }.joined().uppercased()
        print("combined = \(combined) signature = \(signature)")
        
        return signature
    }
    
    public class func getProvince(address: String?) -> String? {
        let strs = address?.split(separator: ",")
        if let strs = strs {
            if let str = strs.last?.lowercased().replacingOccurrences(of: "\\s", with: "", options: .regularExpression) {
                return normalizeVietnamese(str)?.replacingOccurrences(of: "tp.", with: "")
            }
            return nil
        }
        return nil
    }

    public class func normalizeVietnamese(_ str: String) -> String? {
        var str = str
        str = str.replacingOccurrences(of: "à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ", with: "a", options: .regularExpression)
        str = str.replacingOccurrences(of: "è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ", with: "e", options: .regularExpression)
        str = str.replacingOccurrences(of: "ì|í|ị|ỉ|ĩ", with: "i", options: .regularExpression)
        str = str.replacingOccurrences(of: "ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ", with: "o", options: .regularExpression)
        str = str.replacingOccurrences(of: "ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ", with: "u", options: .regularExpression)
        str = str.replacingOccurrences(of: "ỳ|ý|ỵ|ỷ|ỹ", with: "y", options: .regularExpression)
        str = str.replacingOccurrences(of: "đ", with: "d", options: .regularExpression)
        str = str.replacingOccurrences(of: "À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ", with: "A", options: .regularExpression)
        str = str.replacingOccurrences(of: "È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ", with: "E", options: .regularExpression)
        str = str.replacingOccurrences(of: "Ì|Í|Ị|Ỉ|Ĩ", with: "I", options: .regularExpression)
        str = str.replacingOccurrences(of: "Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ", with: "O", options: .regularExpression)
        str = str.replacingOccurrences(of: "Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ", with: "U", options: .regularExpression)
        str = str.replacingOccurrences(of: "Ỳ|Ý|Ỵ|Ỷ|Ỹ", with: "Y", options: .regularExpression)
        str = str.replacingOccurrences(of: "Đ", with: "D", options: .regularExpression)
        return str
    }





}
