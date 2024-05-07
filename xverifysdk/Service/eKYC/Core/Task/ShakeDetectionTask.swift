import MLKitFaceDetection

class ShakeDetectionTask: DetectionTask {
    
    internal final var SHAKE_THRESHOLD:CGFloat = 18.0
    
    internal var hasShakeToLeft = false
    internal var hasShakeToRight = false
    
    init() {
        
    }
    
    func start() {
        hasShakeToLeft = false
        hasShakeToRight = false
    }
    
    func process(face: Face) -> Bool {
        let yaw = face.headEulerAngleY
        if yaw > SHAKE_THRESHOLD && !hasShakeToLeft {
            hasShakeToLeft = true
        } else if yaw < -SHAKE_THRESHOLD && !hasShakeToRight {
            hasShakeToRight = true
        }
        return hasShakeToLeft || hasShakeToRight
    }
    
    func isShakeToLeft() -> Bool {
        return hasShakeToLeft
    }
    
    func isShakeToRight() -> Bool {
        return hasShakeToRight
    }
    
    
}
