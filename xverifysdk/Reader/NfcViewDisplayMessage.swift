import Foundation

@available(iOS 13, macOS 10.15, *)
public enum NfcViewDisplayMessage {
    case requestPresentEid
    case authenticatingWithPassport(Int)
    case readingDataGroupProgress(DataGroupId, Int)
    case error(NfcEIdReaderError)
    case successfulRead
}

@available(iOS 13, macOS 10.15, *)
extension NfcViewDisplayMessage {
    public var description: String {
        switch self {
            case .requestPresentEid:
                return LOCALIZED("put_iphone_near_chip")
            case .authenticatingWithPassport(let progress):
                let progressString = handleProgress(percentualProgress: progress)
                return LOCALIZED("login_to_eid") + "\n\(progressString)"
            case .readingDataGroupProgress(let dataGroup, let progress):
                let progressString = handleProgress(percentualProgress: progress)
                return LOCALIZED("read") + " \(dataGroup).....\n\n\(progressString)"
            case .error(let tagError):
                switch tagError {
                    case NfcEIdReaderError.TagNotValid:
                        return LOCALIZED("tag_not_valid")
                    case NfcEIdReaderError.MoreThanOneTagFound:
                        return LOCALIZED("tag_more_than_one")
                    case NfcEIdReaderError.ConnectionError:
                        return LOCALIZED("tag_connection_error")
                    case NfcEIdReaderError.InvalidMRZKey:
                        return LOCALIZED("tag_mrz_not_valid")
                    case NfcEIdReaderError.ResponseError(let description, let sw1, let sw2):
                        return LOCALIZED("tag_error") + " \(description) - (0x\(sw1), 0x\(sw2)"
                    default:
                        return LOCALIZED("tag_error_try_again")
                }
            case .successfulRead:
                return LOCALIZED("tag_success")
        }
    }
    
    func handleProgress(percentualProgress: Int) -> String {
        let p = (percentualProgress/20)
        let full = String(repeating: "🟢 ", count: p)
        let empty = String(repeating: "⚪️ ", count: 5-p)
        return "\(full)\(empty)"
    }
}
