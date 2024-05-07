import MLKitFaceDetection

class ShakeRightDetectionTask: ShakeDetectionTask {
    override func process(face: Face) -> Bool {
        let yaw = face.headEulerAngleY
        if yaw > SHAKE_THRESHOLD && !hasShakeToRight {
            hasShakeToRight = true
        }
        return hasShakeToRight
    }
}
