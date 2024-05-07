import Foundation

#if !os(macOS)
import UIKit
import CoreNFC

@available(iOS 13, *)
public class EidReader : NSObject {
    private typealias NFCCheckedContinuation = CheckedContinuation<NfcEidModel, Error>
    private var nfcContinuation: NFCCheckedContinuation?

    private var eid : NfcEidModel = NfcEidModel()
    
    private var readerSession: NFCTagReaderSession?
    private var currentlyReadingDataGroup : DataGroupId?
    
    private var dataGroupsToRead : [DataGroupId] = []
    private var readAllDatagroups = false
    private var skipSecureElements = true
    private var skipCA = false
    private var skipPACE = false

    private var bacHandler : BACHandler?
    private var caHandler : ChipAuthenticationHandler?
    private var paceHandler : PACEHandler?
    private var mrzKey : String = ""
    private var dataAmountToReadOverride : Int? = nil
    
    private var scanCompletedHandler: ((NfcEidModel?, NfcEIdReaderError?)->())!
    private var nfcViewDisplayMessageHandler: ((NfcViewDisplayMessage) -> String?)?
    private var masterListURL : URL?
    private var shouldNotReportNextReaderSessionInvalidationErrorUserCanceled : Bool = false

    // By default, Passive Authentication uses the new RFS5652 method to verify the SOD, but can be switched to use
    // the previous OpenSSL CMS verification if necessary
    public var passiveAuthenticationUsesOpenSSL : Bool = false
    public var terminateSessionWhenHangingTime: Double = 45.0

    public init(masterListURL: URL? = nil ) {
        super.init()
        self.masterListURL = masterListURL
    }
    
    public func setMasterListURL( _ masterListURL : URL ) {
        self.masterListURL = masterListURL
    }
    
    // This function allows you to override the amount of data the TagReader tries to read from the NFC
    // chip. NOTE - this really shouldn't be used for production but is useful for testing as different
    // passports support different data amounts.
    // It appears that the most reliable is 0xA0 (160 chars) but some will support arbitary reads (0xFF or 256)
    public func overrideNFCDataAmountToRead( amount: Int ) {
        dataAmountToReadOverride = amount
    }
    
    public func readEid( mrzKey : String, tags : [DataGroupId] = [], skipSecureElements : Bool = true, skipCA : Bool = false, skipPACE : Bool = false, customDisplayMessage : ((NfcViewDisplayMessage) -> String?)? = nil) async throws -> NfcEidModel {
        
        self.eid = NfcEidModel()
        self.mrzKey = mrzKey
        self.skipCA = skipCA
        self.skipPACE = skipPACE
        
        self.dataGroupsToRead.removeAll()
        self.dataGroupsToRead.append( contentsOf:tags)
        self.nfcViewDisplayMessageHandler = customDisplayMessage
        self.skipSecureElements = skipSecureElements
        self.currentlyReadingDataGroup = nil
        self.bacHandler = nil
        self.caHandler = nil
        self.paceHandler = nil
        
        // If no tags specified, read all
        if self.dataGroupsToRead.count == 0 {
            // Start off with .COM, will always read (and .SOD but we'll add that after), and then add the others from the COM
            self.dataGroupsToRead.append(contentsOf:[.COM, .SOD] )
            self.readAllDatagroups = true
        } else {
            // We are reading specific datagroups
            self.readAllDatagroups = false
        }
        
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NfcEIdReaderError.NFCNotSupported
        }
        
        if NFCTagReaderSession.readingAvailable {
            readerSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
            
            self.updateReaderSessionMessage( alertMessage: NfcViewDisplayMessage.requestPresentEid )
            readerSession?.begin()
        }
        
        return try await withCheckedThrowingContinuation({ (continuation: NFCCheckedContinuation) in
            self.nfcContinuation = continuation
        })
    }
}

@available(iOS 13, *)
extension EidReader : NFCTagReaderSessionDelegate {
    // MARK: - NFCTagReaderSessionDelegate
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // If necessary, you may perform additional operations on session start.
        // At this point RF polling is enabled.
        
        // Deativce session after `terminateSessionWhenHangingTime`seconds if the NFCHardware is hanging, avoid unrelease session
        DISPATCH_ASYNC_BG_AFTER(terminateSessionWhenHangingTime) { [weak self] in
            guard let self = self else { return }
            // If the task and session already released, return
            if self.nfcContinuation == nil { return }
            let error = NfcEIdReaderError.ConnectionError
            self.readerSession?.invalidate(errorMessage: error.localizedDescription)
            self.nfcContinuation?.resume(throwing: error)
            self.nfcContinuation = nil
            print("=== DEATIVE ===")
        }
        Log.debug( "tagReaderSessionDidBecomeActive" )
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        // If necessary, you may handle the error. Note session is no longer valid.
        // You must create a new session to restart RF polling.
        Log.debug( "tagReaderSession:didInvalidateWithError - \(error.localizedDescription)" )
        self.readerSession?.invalidate()
        self.readerSession = nil

        if let readerError = error as? NFCReaderError, readerError.code == NFCReaderError.readerSessionInvalidationErrorUserCanceled
            && self.shouldNotReportNextReaderSessionInvalidationErrorUserCanceled {
            
            self.shouldNotReportNextReaderSessionInvalidationErrorUserCanceled = false
        } else {
            var userError = NfcEIdReaderError.UnexpectedError
            if let readerError = error as? NFCReaderError {
                Log.error( "tagReaderSession:didInvalidateWithError - Got NFCReaderError - \(readerError.localizedDescription)" )
                switch (readerError.code) {
                case NFCReaderError.readerSessionInvalidationErrorUserCanceled:
                    Log.error( "     - User cancelled session" )
                    userError = NfcEIdReaderError.UserCanceled
                default:
                    Log.error( "     - some other error - \(readerError.localizedDescription)" )
                    userError = NfcEIdReaderError.UnexpectedError
                }
            } else {
                Log.error( "tagReaderSession:didInvalidateWithError - Received error - \(error.localizedDescription)" )
            }
            nfcContinuation?.resume(throwing: userError)
            nfcContinuation = nil
        }
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Log.debug( "tagReaderSession:didDetect - \(tags[0])" )
        if tags.count > 1 {
            Log.debug( "tagReaderSession:more than 1 tag detected! - \(tags)" )

            let errorMessage = NfcViewDisplayMessage.error(.MoreThanOneTagFound)
            self.invalidateSession(errorMessage: errorMessage, error: NfcEIdReaderError.MoreThanOneTagFound)
            return
        }

        let tag = tags.first!
        var eIdTag: NFCISO7816Tag
        switch tags.first! {
        case let .iso7816(tag):
            eIdTag = tag
        default:
            Log.debug( "tagReaderSession:invalid tag detected!!!" )

            let errorMessage = NfcViewDisplayMessage.error(NfcEIdReaderError.TagNotValid)
            self.invalidateSession(errorMessage:errorMessage, error: NfcEIdReaderError.TagNotValid)
            return
        }
        
        Task { [eIdTag] in
            do {
                try await session.connect(to: tag)
                
                Log.debug( "tagReaderSession:connected to tag - starting authentication" )
                self.updateReaderSessionMessage( alertMessage: NfcViewDisplayMessage.authenticatingWithPassport(0) )
                
                let tagReader = TagReader(tag:eIdTag)
                
                if let newAmount = self.dataAmountToReadOverride {
                    tagReader.overrideDataAmountToRead(newAmount: newAmount)
                }
                
                tagReader.progress = { [unowned self] (progress) in
                    if let dgId = self.currentlyReadingDataGroup {
                        self.updateReaderSessionMessage( alertMessage: NfcViewDisplayMessage.readingDataGroupProgress(dgId, progress) )
                    } else {
                        self.updateReaderSessionMessage( alertMessage: NfcViewDisplayMessage.authenticatingWithPassport(progress) )
                    }
                }
                
                let passportModel = try await self.startReading( tagReader : tagReader)
                nfcContinuation?.resume(returning: passportModel)
                nfcContinuation = nil

                
            } catch let error as NfcEIdReaderError {
                let errorMessage = NfcViewDisplayMessage.error(error)
                self.invalidateSession(errorMessage: errorMessage, error: error)
            } catch let error {

                nfcContinuation?.resume(throwing: error)
                nfcContinuation = nil
                Log.debug( "tagReaderSession:failed to connect to tag - \(error.localizedDescription)" )
                let errorMessage = NfcViewDisplayMessage.error(NfcEIdReaderError.ConnectionError)
                self.invalidateSession(errorMessage: errorMessage, error: NfcEIdReaderError.ConnectionError)
            }
        }
    }
    
    func updateReaderSessionMessage(alertMessage: NfcViewDisplayMessage ) {
        self.readerSession?.alertMessage = self.nfcViewDisplayMessageHandler?(alertMessage) ?? alertMessage.description
    }
}

@available(iOS 13, *)
extension EidReader {
    
    func startReading(tagReader : TagReader) async throws -> NfcEidModel {

        if !skipPACE {
            do {
                let data = try await tagReader.readCardAccess()
                Log.debug( "Read CardAccess - data \(binToHexRep(data))" )
                let cardAccess = try CardAccess(data)
                eid.cardAccess = cardAccess
                Log.info( "Starting Password Authenticated Connection Establishment (PACE)" )
                let paceHandler = try PACEHandler( cardAccess: cardAccess, tagReader: tagReader )
                try await paceHandler.doPACE(mrzKey: mrzKey )
                eid.PACEStatus = .success
                Log.debug( "PACE Succeeded" )
            } catch let error as NfcEIdReaderError {
                if error.value == "Security status not satisfied" {
                    eid.PACEStatus = .present
                } else {
                    Log.error( "PACE Failed - falling back to BAC" + "\(error)" )
                }
            }
            
            _ = try await tagReader.selectPassportApplication()
        }
        
        // If either PACE isn't supported, we failed whilst doing PACE or we didn't even attempt it, then fall back to BAC
        if eid.PACEStatus != .success {
            try await doBACAuthentication(tagReader : tagReader)
        }
        
        // Now to read the datagroups
        try await readDataGroups(tagReader: tagReader)
        
        self.updateReaderSessionMessage(alertMessage: NfcViewDisplayMessage.successfulRead)

        try await doActiveAuthenticationIfNeccessary(tagReader : tagReader)
        self.shouldNotReportNextReaderSessionInvalidationErrorUserCanceled = true
        self.readerSession?.invalidate()

        // If we have a masterlist url set then use that and verify the passport now
        self.eid.verifyPassiveAuthentication(masterListURL: self.masterListURL, useCMSVerification: self.passiveAuthenticationUsesOpenSSL)

        return self.eid
    }
    
    
    func doActiveAuthenticationIfNeccessary( tagReader : TagReader) async throws {
        guard self.eid.activeAuthenticationSupported else {
            return
        }
        
        Log.info( "Performing Active Authentication" )
        
        let challenge = generateRandomUInt8Array(8)
        Log.debug( "Generated Active Authentication challange - \(binToHexRep(challenge))")
        let response = try await tagReader.doInternalAuthentication(challenge: challenge)
        self.eid.verifyActiveAuthentication( challenge:challenge, signature:response.data )
    }
    

    func doBACAuthentication(tagReader : TagReader) async throws {
        self.currentlyReadingDataGroup = nil
        
        Log.info( "Starting Basic Access Control (BAC)" )
        
        self.eid.BACStatus = .failed

        self.bacHandler = BACHandler( tagReader: tagReader )
        try await bacHandler?.performBACAndGetSessionKeys( mrzKey: mrzKey )
        Log.info( "Basic Access Control (BAC) - SUCCESS!" )

        self.eid.BACStatus = .success
    }

    func readDataGroups( tagReader: TagReader ) async throws {
        
        // Read COM
        var DGsToRead = [DataGroupId]()

        self.updateReaderSessionMessage( alertMessage: NfcViewDisplayMessage.readingDataGroupProgress(.COM, 0) )
        if let com = try await readDataGroup(tagReader:tagReader, dgId:.COM) as? COM {
            self.eid.addDataGroup( .COM, dataGroup:com )
        
            // SOD and COM shouldn't be present in the DG list but just in case (worst case here we read the sod twice)
            DGsToRead = [.SOD] + com.dataGroupsPresent.map { DataGroupId.getIDFromName(name:$0) }
            DGsToRead.removeAll { $0 == .COM }
        }
        
        if DGsToRead.contains( .DG14 ) {
            DGsToRead.removeAll { $0 == .DG14 }
            
            if !skipCA {
                // Do Chip Authentication
                if let dg14 = try await readDataGroup(tagReader:tagReader, dgId:.DG14) as? DataGroup14 {
                    self.eid.addDataGroup( .DG14, dataGroup:dg14 )
                    let caHandler = ChipAuthenticationHandler(dg14: dg14, tagReader: tagReader)
                     
                    if caHandler.isChipAuthenticationSupported {
                        do {
                            // Do Chip authentication and then continue reading datagroups
                            try await caHandler.doChipAuthentication()
                            self.eid.chipAuthenticationStatus = .success
                        } catch {
                            Log.info( "Chip Authentication failed - re-establishing BAC")
                            self.eid.chipAuthenticationStatus = .failed
                            
                            // Failed Chip Auth, need to re-establish BAC
                            try await doBACAuthentication(tagReader: tagReader)
                        }
                    }
                }
            }
        }

        // If we are skipping secure elements then remove .DG3 and .DG4
        if self.skipSecureElements {
            DGsToRead = DGsToRead.filter { $0 != .DG3 && $0 != .DG4 }
        }

        if self.readAllDatagroups != true {
            DGsToRead = DGsToRead.filter { dataGroupsToRead.contains($0) }
        }
        for dgId in DGsToRead {
            self.updateReaderSessionMessage( alertMessage: NfcViewDisplayMessage.readingDataGroupProgress(dgId, 0) )
            if let dg = try await readDataGroup(tagReader:tagReader, dgId:dgId) {
                self.eid.addDataGroup( dgId, dataGroup:dg )
            }
        }
    }
    
    func readDataGroup( tagReader : TagReader, dgId : DataGroupId ) async throws -> DataGroup?  {

        self.currentlyReadingDataGroup = dgId
        Log.info( "Reading tag - \(dgId)" )
        var readAttempts = 0
        
        self.updateReaderSessionMessage( alertMessage: NfcViewDisplayMessage.readingDataGroupProgress(dgId, 0) )

        repeat {
            do {
                let response = try await tagReader.readDataGroup(dataGroup:dgId)
                let dg = try DataGroupParser().parseDG(data: response)
                return dg
            } catch let error as NfcEIdReaderError {
                Log.error( "TagError reading tag - \(error)" )

                // OK we had an error - depending on what happened, we may want to try to re-read this
                // E.g. we failed to read the last Datagroup because its protected and we can't
                let errMsg = error.value
                Log.error( "ERROR - \(errMsg)" )
                
                var redoBAC = false
                if errMsg == "Session invalidated" || errMsg == "Class not supported" || errMsg == "Tag connection lost"  {
                    // Check if we have done Chip Authentication, if so, set it to nil and try to redo BAC
                    if self.caHandler != nil {
                        self.caHandler = nil
                        redoBAC = true
                    } else {
                        // Can't go any more!
                        throw error
                    }
                } else if errMsg == "Security status not satisfied" || errMsg == "File not found" {
                    // Can't read this element as we aren't allowed - remove it and return out so we re-do BAC
                    self.dataGroupsToRead.removeFirst()
                    redoBAC = true
                } else if errMsg == "SM data objects incorrect" || errMsg == "Class not supported" {
                    // Can't read this element security objects now invalid - and return out so we re-do BAC
                    redoBAC = true
                } else if errMsg.hasPrefix( "Wrong length" ) || errMsg.hasPrefix( "End of file" ) {  // Should now handle errors 0x6C xx, and 0x67 0x00
                    // OK passport can't handle max length so drop it down
                    tagReader.reduceDataReadingAmount()
                    redoBAC = true
                }
                
                if redoBAC {
                    // Redo BAC and try again
                    try await doBACAuthentication(tagReader : tagReader)
                } else {
                    // Some other error lets have another try
                }
            }
            readAttempts += 1
        } while ( readAttempts < 2 )
        
        return nil
    }

    func invalidateSession(errorMessage: NfcViewDisplayMessage, error: NfcEIdReaderError) {
        // Mark the next 'invalid session' error as not reportable (we're about to cause it by invalidating the
        // session). The real error is reported back with the call to the completed handler
        self.shouldNotReportNextReaderSessionInvalidationErrorUserCanceled = true
        self.readerSession?.invalidate(errorMessage: self.nfcViewDisplayMessageHandler?(errorMessage) ?? errorMessage.description)
        nfcContinuation?.resume(throwing: error)
        nfcContinuation = nil
    }
}
#endif
