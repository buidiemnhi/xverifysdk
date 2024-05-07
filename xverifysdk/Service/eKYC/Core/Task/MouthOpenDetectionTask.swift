import MLKitFaceDetection

class MouthOpenDetectionTask: DetectionTask {
    func process(face: Face) -> Bool {
        return DetectionUtils.isFacing(face: face) && DetectionUtils.isMouthOpen(face: face)
    }
}
