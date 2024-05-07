import MLKitFaceDetection

class SmileDetectionTask : DetectionTask {
    
    init() {
        
    }
    
    func process(face: Face) -> Bool {
        let isSmile = (face.hasSmilingProbability ? face.smilingProbability : 0) > 0.67
        return isSmile && DetectionUtils.isFacing(face: face)
    }
}
