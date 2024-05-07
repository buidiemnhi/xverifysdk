
import Foundation

public struct EidVerifyModel: Codable {
    public let transactionCode: String
    public let isValidIdCard: Bool
    public var responds: String?
    public let signature: String
    public let detailMessage: String
    
    enum CodingKeys: String, CodingKey {
        case transactionCode = "transaction_code"
        case isValidIdCard = "is_valid_id_card"
        case responds = "_responds"
        case signature = "signature"
        case detailMessage = "detail_message"
    }
}
