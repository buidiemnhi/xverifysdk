import UIKit

public class RestResponse: NSObject {
	var result: Any?
	var isSuccess: Bool = false
	var headerStatusCode: Int = 0
	var allHeaderFields: [AnyHashable: Any]?
	var statusMessage: String?

	// --------------------------------------
	// MARK: Class
	// --------------------------------------

	public class func build(_ result: Any?, isSuccess: Bool = true, statusCode: Int = 200, allHeaderFields: [AnyHashable: Any]? = nil, statusMessage: String? = nil)
		-> RestResponse {
		let restResponse: RestResponse = RestResponse()
		restResponse.result = result
		restResponse.isSuccess = isSuccess
		restResponse.headerStatusCode = statusCode
		restResponse.allHeaderFields = allHeaderFields
		restResponse.statusMessage = statusMessage
		return restResponse
	}

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

	public override init() {
		super.init()
	}
}
