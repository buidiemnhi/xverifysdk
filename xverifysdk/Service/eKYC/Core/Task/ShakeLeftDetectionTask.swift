import MLKitFaceDetection

class ShakeLeftDetectionTask: ShakeDetectionTask {
    override func process(face: Face) -> Bool {
        let yaw = face.headEulerAngleY
        if yaw < -SHAKE_THRESHOLD && !hasShakeToLeft {
            hasShakeToLeft = true
        }
        return hasShakeToLeft
    }
}
