import MLKitFaceDetection

@objc protocol DetectionTask {
    @objc optional func start()
    @objc func process(face: Face) -> Bool
}
