
import Foundation
import Security


public let EIDFACADE = EidFacade.shared

public class EidFacade {
    
    private let eidReader = EidReader(masterListURL: URL(string: ApiService.EID_HOSTNAME)) // required for extract certificate
        
    // --------------------------------------
    // MARK: Singleton
    // --------------------------------------

    public class var shared: EidFacade {
        struct Static {
            static let instance = EidFacade()
        }
        return Static.instance
    }

    private init() {
        eidReader.passiveAuthenticationUsesOpenSSL = false
    }
    
    // --------------------------------------
    // MARK: MRZ
    // --------------------------------------
        
    /// Builds the MRZ key
    /// - Parameter eidNumber: Last 9 digit of the ID
    /// - Parameter dateOfBirth: Date of birth in the format yymmdd
    /// - Parameter dateOfExpiry: Date of expiry in the format yymmdd
    public func generateMRZKey(eidNumber: String, dateOfBirth: String, dateOfExpiry: String ) -> String {
        return Common.getMRZKey(eidNumber: eidNumber, dateOfBirth: dateOfBirth, dateOfExpiry: dateOfExpiry)
    }
        
    // --------------------------------------
    // MARK: NFC
    // --------------------------------------
    
    /// Performs the NFC reading process with the MRZ key (9 last digits + DOB + DOE)
    /// - Parameter mrzKey: Machine Readable Zone Key
    /// - Parameter completionHandler: Success callback
    /// - Parameter errorHandler: Error callback
    public func readChipNfc(mrzKey: String,
                            completionHandler: @escaping (_ eid: NfcEidModel) -> Void,
                            errorHandler: @escaping (_ error: Error) -> Void) -> Void {
        let customMessageHandler : (NfcViewDisplayMessage) -> String? = { (displayMessage) in
            switch displayMessage {
                case .requestPresentEid:
                    return LOCALIZED("put_iphone_near_chip")
                default:
                    return nil
            }
        }
        Task {
            do {
                let eid = try await eidReader.readEid( mrzKey: mrzKey, customDisplayMessage:customMessageHandler)
                completionHandler(eid)
            } catch {
                DispatchQueue.main.async {
                    errorHandler(error)
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: VERIFY
    // --------------------------------------
    
    /// Verifies the eid ds_cert with RAR through the gateway platform.
    /// - Parameter eid: Nfc Object Model that contains the SOD
    /// - Parameter code: Customer code
    /// - Parameter completionHandler: Success callback
    /// - Parameter errorHandler: Error callback
    public func verifyEid(eid: NfcEidModel, 
                          code: String = "",
                          path: String = "",
                          completionHandler: @escaping (_ eid: EidVerifyModel) -> Void,
                          errorHandler: @escaping (_ error: Error) -> Void) -> Void {
        var dsCert: String
        if let dsData = eid.documentSigningCertificate {
            dsCert = Data(dsData.certToPEM().utf8).base64EncodedString()
        } else {
            dsCert = ""
        }
        let idCard = eid.dg13?.eidNumber ?? ""
        let deviceType = "mobile"
        let province = extractVietnameseProvince(eid.dg13?.placeOfOrigin ?? "") ?? ""
        APISERVICE.verifyEid(path: path, idCard: idCard, dsCert: dsCert, deviceType: deviceType, province: province, code: code) { result in
            switch (result) {
                case .success(let eidVerify):
                    completionHandler(eidVerify)
                case .failure(let error):
                    errorHandler(error)
            }
        }
    }
    
    /// Verifies the responds signature to certify that the responds is from RAR.
    /// - Parameter plainText: the respond in text from RAR
    /// - Parameter signature: the signature in text from RAR
    /// - Parameter publicKey: the security public key from RAR
    /// - Returns: True if the responds is valid, otherwise False
    public func verifyRsaSignature(plainText: String, signature: String, publicKey: SecKey) -> Bool {
        guard let plainData = plainText.data(using: .utf8) else {
            return false
        }
        guard let signatureData = Data(base64Encoded: signature) else {
            Log.error("Invalid Base64 signature string")
            return false
        }
        
        var error: Unmanaged<CFError>?
        let algorithm = SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256
        
        let verificationStatus = SecKeyVerifySignature(
            publicKey,
            algorithm,
            plainData as CFData,
            signatureData as CFData,
            &error
        )
        
        return verificationStatus
    }
    
    /// Verifies the responds signature to certify that the responds is from RAR.
    /// - Parameter plainText: the respond in text from RAR
    /// - Parameter signature: the signature in text from RAR
    /// - Returns: True if the responds is valid, otherwise False
    public func verifyRsaSignature(publicKeyUrl: URL, plainText: String, signature: String) -> Bool {
        guard let publicKey = Common.retrievePublicKey(publicKeyUrl) else {
            return false
        }
        return verifyRsaSignature(plainText: plainText, signature: signature, publicKey: publicKey)
    }
    
    
    /// Set terminate time interval when the NFC hardware is hanging
    /// - Parameter timeInterval: the time interval nfc session will be terminated
    /// - Default value `timeInterval`: 45.0
    /// - Note: Since Apple doesn't provide the API for setting NFC timeout, carefully consider set the `timeInterval` long enough for the NFC session could read NFC tags
    public func setTerminateWhenHangingTimeInterval(timeInterval: Double) {
        self.eidReader.terminateSessionWhenHangingTime = timeInterval
    }

}
