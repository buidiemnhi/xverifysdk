
import Foundation

struct ErrorModel: Codable {
    let code: String
    let message: String?
    
    private enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
    }
}
