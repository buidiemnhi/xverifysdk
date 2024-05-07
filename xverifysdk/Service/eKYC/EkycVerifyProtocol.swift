//
//  EkycVerifyProtocol.swift
//  xverifysdk
//
//  Created by Minh Tri on 17/12/2023.
//

public enum EkycVerifyError {
    case EKYC_FAILED
    case REFERENCE_NOT_FOUND
    case OTHER
}

public protocol EkycVerifyDelegate {
    func onProcess()
    func onFailed(error: NSError, capturedFace: String,  ekycVerificationMode: EkycVerificationMode, errorCode: EkycVerifyError)
    func onVerifyCompleted(ekycVerificationMode: EkycVerificationMode, verifyLiveness: Bool, verifyFaceMatch: Bool, capturedFace: String?)
}
