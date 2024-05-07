//
//  ErrorUtils.swift
//  eidos
//
//  Created by Tony Kieu on 25/08/2023.
//

import UIKit

@objc public enum ErrorCode: Int {
    
    case invalidUrl             = 900
    case invalidResponse        = 1000
    case objectParsing          = 1001
    case invalidObject          = 1002
    case loginError             = 1003
    case verifyLivenessError    = 1004
    case faceMatchingError      = 1005

    var errorMessage: String {
        LOCALIZED("error_code_\(rawValue)")
    }

}

let kGeneralErrorDomain: String = "verifysdk"
let kErrorCodeKey: String = "errorcode"
let kErrorMessage: String = "errormessage"
let kErrorDomainKey: String = "errordomain"

public class ErrorUtils: NSObject {
    
    public class func error(_ code: ErrorCode) -> NSError {
        error(code, message: code.errorMessage, shouldLog: true)
    }

    public class func error(_ code: ErrorCode, message: String?) -> NSError {
        error(code, message: message, shouldLog: true)
    }

    public class func error(_ code: ErrorCode, message: String?, shouldLog: Bool) -> NSError {
        let result: [String: Any] = [
            kErrorCodeKey: code,
            kErrorMessage: message ?? code.errorMessage,
            kErrorDomainKey: kGeneralErrorDomain
        ]
        return error(result, shouldLog: shouldLog)
    }

    public class func error(_ result: [String: String]) -> NSError {
        error(result, shouldLog: true)
    }

    public class func error(_ result: [String: Any], shouldLog: Bool) -> NSError {
        let code: ErrorCode = (result[kErrorCodeKey] as? ErrorCode)!
        let message: String? = result[kErrorMessage] as? String
        if shouldLog {
            Log.debug(String(format: "error message=%@ code=%ld", message ?? "", code.rawValue))
        }
        var userInfo: [String: String] = [:]

        if !stringIsNullOrEmpty(message) {
            userInfo[NSLocalizedDescriptionKey] = message
        }
        let errorDomain: String = result[kGeneralErrorDomain] as? String ?? kGeneralErrorDomain
        return NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
    }

    public class func error(_ customCode: Int, message: String?) -> NSError {
        Log.debug(String(format: "error message=%@ code=%ld", message ?? "", customCode))
        var userInfo: [String: String] = [:]
        if !stringIsNullOrEmpty(message) {
            userInfo[NSLocalizedDescriptionKey] = message
        }
        return NSError(domain: kGeneralErrorDomain, code: customCode, userInfo: userInfo)
    }

}
