import MLKitFaceDetection

class FacingDetectionTask: DetectionTask {
    
    private static var FACING_CAMERA_KEEP_TIME:Int64 = 1500
    private var startTime:Int64 = 0
    
    init() {
        
    }
    
    func start() {
        startTime = Int64((NSDate().timeIntervalSince1970 * 1000.0).rounded())
    }
    
    func process(face: Face) -> Bool {
        if !DetectionUtils.isFacing(face: face) {
            startTime = Int64((NSDate().timeIntervalSince1970 * 1000.0).rounded())
            return false
        }
        return Int64((NSDate().timeIntervalSince1970 * 1000.0).rounded()) - startTime >= FacingDetectionTask.FACING_CAMERA_KEEP_TIME
    }
    
    
}
