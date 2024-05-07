import MLKitFaceDetection

protocol LivenessDetectorDelegate {
    func onTaskStarted(task: DetectionTask)
    func onTaskCompletd(task: DetectionTask, isLastTask: Bool)
    func onTaskFailed(task: DetectionTask, code: Int)
}

class LivenessDetector {
    
    private static var FACE_CACHE_SIZE = 5
    private static var NO_ERROR = -1
    public static var ERROR_NO_FACE = 0
    public static var ERROR_MULTI_FACES = 1
    public static var ERROR_OUT_OF_DETECTION_RECT = 2
    
    private var tasks: [DetectionTask] = []
    private var taskIndex = 0
    private var lastTaskIndex = -1
    private var currentErrorState = NO_ERROR
    private var lastFaces: [Face] = []
    private var delegate: LivenessDetectorDelegate?
    
    init(tasks: [DetectionTask]) {
        self.tasks = tasks
    }
    
    func setDelegate(delegate: LivenessDetectorDelegate?) {
        self.delegate = delegate
    }
    
    private func reset() {
        taskIndex = 0
        lastTaskIndex = -1
        lastFaces.removeAll()
        tasks.removeAll()
    }
    
    func isTaskEmpty() -> Bool {
        return self.tasks.isEmpty
    }
    
    func clearTask() {
        reset()
        tasks.removeAll()
    }
    
    func process(faces: [Face]?, detectionSize: Int) {
        guard let faces = faces else {return}
        
        if taskIndex >= tasks.count {
            return
        }
        let task = tasks[taskIndex]
        if taskIndex != lastTaskIndex {
            lastTaskIndex = taskIndex
            task.start?()
            delegate?.onTaskStarted(task: task)
        }
        
        guard let face = self.filter(task: task, faces: faces, detectionSize: detectionSize) else {return}
        if task.process(face: face) {
            delegate?.onTaskCompletd(task: task, isLastTask: taskIndex == tasks.count - 1)
            taskIndex += 1
        }
    }
    
    private func filter(task: DetectionTask, faces: [Face]?, detectionSize: Int) -> Face? {
        guard let faces = faces else {return nil}
        if faces.count > 1 {
            changeErrorState(task: task, newErrorState: LivenessDetector.ERROR_MULTI_FACES)
            reset()
            return nil
        }
        if faces.isEmpty && lastFaces.isEmpty {
            changeErrorState(task: task, newErrorState: LivenessDetector.ERROR_NO_FACE)
            reset()
            return nil
        }
        
        if let face = faces.first ?? lastFaces.first {
            if !DetectionUtils.isFaceInDetectionRect(face: face, detectionSize: detectionSize) {
                changeErrorState(task: task, newErrorState: LivenessDetector.ERROR_OUT_OF_DETECTION_RECT)
                reset()
                return nil
            }
            lastFaces.insert(face, at: 0)
            if lastFaces.count > LivenessDetector.FACE_CACHE_SIZE {
                _ = lastFaces.last
            }
            changeErrorState(task: task, newErrorState: LivenessDetector.NO_ERROR)
            return face
        }
        
        changeErrorState(task: task, newErrorState: LivenessDetector.ERROR_NO_FACE)
        reset()
        return nil
    }

    private func changeErrorState(task: DetectionTask, newErrorState: Int) {
        if newErrorState != currentErrorState {
            currentErrorState = newErrorState
            if currentErrorState != LivenessDetector.NO_ERROR {
                delegate?.onTaskFailed(task: task, code: currentErrorState)
            }
        }
    }
}
