import UIKit

public class RestCallback: NSObject {
	public typealias RestResponseBlock = (RestResponse) -> Void
	var result: RestResponseBlock?

	// --------------------------------------
	// MARK: Class
	// --------------------------------------

	public class func callbackWithResult(_ result: RestResponseBlock?) -> RestCallback {
		let restCallback: RestCallback = RestCallback()
		restCallback.result = result
		return restCallback
	}

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

	public override init() {
		super.init()
	}
}
