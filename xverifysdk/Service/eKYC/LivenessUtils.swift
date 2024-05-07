//
//  LivenessUtils.swift
//  xverifysdk
//
//  Created by Minh Tri on 17/12/2023.
//

import MLKitFaceDetection
import MLKitVision
import UIKit
import Alamofire


public let EKYCSERVICE = LivenessUtils.shared

public class LivenessUtils {
    
    private var verificationMode: EkycVerificationMode = .verify_liveness_face_matching
    
    private var faceDelegate: EkycLivenessDelegate?
    private var verifyDelegate: EkycVerifyDelegate?
    private var faceResultDelegate: EkycFaceResultDelegate?
    
    private var livenessDetector = LivenessDetector(tasks: [])
    private var stepFace: StepFace = .left
    private var sampleBuffer: CMSampleBuffer?
    private var referenceImagePath: String?
    
    private var mapLiveness: [StepFace : String] = [StepFace : String]()
    // --------------------------------------
    // MARK: Singleton
    // --------------------------------------
    public static let shared = LivenessUtils()
    
    private init() {
        
    }
    
    public func initialize(referenceImagePath: String?, verificationMode: EkycVerificationMode, faceDelegate: EkycLivenessDelegate?, faceResultDelegate: EkycFaceResultDelegate?, verifyDelegate: EkycVerifyDelegate?) {
        self.verificationMode = verificationMode
        self.faceDelegate = faceDelegate
        self.verifyDelegate = verifyDelegate
        self.faceResultDelegate = faceResultDelegate
        self.referenceImagePath = referenceImagePath
        self.stepFace = StepFace.left
        self.mapLiveness.removeAll()
        self.livenessDetector.clearTask()
    }
    
    // --------------------------------------
    // MARK: On-Device Face Detections
    // --------------------------------------
    
    /// LOGIC :  Front face for confirm (Face), Left(ShakeLeft) -> Face -> Right(ShakeRight)
    private func detectorFaceLeft() -> LivenessDetector {
        //first, detect the front face in frame and next to detect left ( 3 side scan face)
        let livenessDetector = LivenessDetector(tasks: [FacingDetectionTask(), ShakeLeftDetectionTask()])
        livenessDetector.setDelegate(delegate: self)
        return livenessDetector
    }
    //detect front face individually (3 side scan face)
    private func detectorFaceFront() -> LivenessDetector {
        let livenessDetector = LivenessDetector(tasks: [FacingDetectionTask()])
        livenessDetector.setDelegate(delegate: self)
        return livenessDetector
    }

    private func detectorFaceRight() -> LivenessDetector {
        //finally, run detect right face individually
        let livenessDetector = LivenessDetector(tasks: [ShakeRightDetectionTask()])
        livenessDetector.setDelegate(delegate: self)
        return livenessDetector
    }
    
    private func detectorFaceSmile() -> LivenessDetector {
        let livenessDetector = LivenessDetector(tasks: [FacingDetectionTask(), SmileDetectionTask()])
        livenessDetector.setDelegate(delegate: self)
        return livenessDetector
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    public func processDetectFaces(sampleBuffer: CMSampleBuffer, width: CGFloat, height: CGFloat) {
        self.sampleBuffer = sampleBuffer
        let image = VisionImage(buffer: sampleBuffer)
        image.orientation = MLKitUtils.imageOrientation(fromDevicePosition: .front)
        
        let options = FaceDetectorOptions()
        options.landmarkMode = .all
        //options.contourMode = .all
        options.classificationMode = .all
        options.performanceMode = .fast
        options.minFaceSize = 0.15
        let faceDetector = FaceDetector.faceDetector(options: options)
        var faces: [Face] = []
        var detectionError: Error?
        do {
            faces = try faceDetector.results(in: image)
        } catch let error {
            detectionError = error
        }
        
        DISPATCH_ASYNC_MAIN {
            if let detectionError = detectionError {
                print("Failed to detect faces with error: \(detectionError.localizedDescription).")
                return
            }
            guard !faces.isEmpty else {
                print("On-Device face detector returned no results.")
                return
            }
            
            let detectionSize = max(width, height)
            
            if self.stepFace == .left {
                if self.livenessDetector.isTaskEmpty() {
                    self.livenessDetector = self.detectorFaceLeft()
                }
                self.livenessDetector.process(faces: faces, detectionSize: Int(detectionSize))
                return
            } else if self.stepFace == .face {
                if self.livenessDetector.isTaskEmpty() {
                    self.livenessDetector = self.detectorFaceFront()
                }
                self.livenessDetector.process(faces: faces, detectionSize: Int(detectionSize))
                return
            } else if self.stepFace == .right {
                if self.livenessDetector.isTaskEmpty() {
                    self.livenessDetector = self.detectorFaceRight()
                }
                self.livenessDetector.process(faces: faces, detectionSize: Int(detectionSize))
                return
            }
        }
    }
    
    public func processDetectFrontFace(sampleBuffer: CMSampleBuffer, width: CGFloat, height: CGFloat) {
        self.sampleBuffer = sampleBuffer
        let image = VisionImage(buffer: sampleBuffer)
        image.orientation = MLKitUtils.imageOrientation(fromDevicePosition: .front)
        
        let options = FaceDetectorOptions()
        options.landmarkMode = .all
        //options.contourMode = .all
        options.classificationMode = .all
        options.performanceMode = .fast
        options.minFaceSize = 0.15
        let faceDetector = FaceDetector.faceDetector(options: options)
        var faces: [Face] = []
        var detectionError: Error?
        do {
            faces = try faceDetector.results(in: image)
        } catch let error {
            detectionError = error
        }
        
        DISPATCH_ASYNC_MAIN {
            if let detectionError = detectionError {
                print("Failed to detect faces with error: \(detectionError.localizedDescription).")
                return
            }
            guard !faces.isEmpty else {
                print("On-Device face detector returned no results.")
                return
            }
            
            let detectionSize = max(width, height)
            self.stepFace = .face
            if self.livenessDetector.isTaskEmpty() {
                self.livenessDetector = self.detectorFaceFront()
            }
            self.livenessDetector.process(faces: faces, detectionSize: Int(detectionSize))
            self.resetAnalysis()
        }
    }
    // --------------------------------------
    // MARK: Private eKYC Verification
    // --------------------------------------
    private func requestVerifyLiveness() {
        verifyDelegate?.onProcess()
        guard let pathFace = mapLiveness[StepFace.face],
              let pathLeft = mapLiveness[StepFace.left],
              let pathRight = mapLiveness[StepFace.right] else {return}
        
        APISERVICE.verifyLiveness(path: "", pathFace: pathFace, pathLeft: pathLeft, pathRight: pathRight) { result in
            switch (result) {
            case .success(let data):
                if data.isValid {
                    self.verifyDelegate?.onVerifyCompleted(ekycVerificationMode: self.verificationMode,
                                                           verifyLiveness: true,
                                                           verifyFaceMatch: false,
                                                           capturedFace: self.mapLiveness[StepFace.face])
                } else {
                    self.verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.verifyLivenessError, message: data.invalidMessage), capturedFace: pathFace, ekycVerificationMode: self.verificationMode, errorCode: .EKYC_FAILED)
                    self.resetAnalysis()
                }
            case .failure(_):
                self.verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.verifyLivenessError, message: "Error"),capturedFace: pathFace, ekycVerificationMode: self.verificationMode, errorCode: .OTHER)
                self.resetAnalysis()
            }
        }
    }
    
    private func requestVerifyFaceMatching() {
        if referenceImagePath == nil {
            guard let pathFace = mapLiveness[StepFace.face] else { return }
            verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.faceMatchingError, message: "Reference image is not found"),capturedFace: pathFace, ekycVerificationMode: self.verificationMode, errorCode: .REFERENCE_NOT_FOUND)
            return
        }
        verifyDelegate?.onProcess()
        performVerifyFaceMatching(verifyLiveness: false)
    }
    
    private func requestVerifyEkyc() {
        if referenceImagePath == nil {
            guard let pathFace = mapLiveness[StepFace.face] else { return }
            verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.faceMatchingError, message: "Reference image is not found"),capturedFace: pathFace, ekycVerificationMode: self.verificationMode, errorCode: .REFERENCE_NOT_FOUND)
            return
        }
        
        guard let pathFace = mapLiveness[StepFace.face],
              let pathLeft = mapLiveness[StepFace.left],
              let pathRight = mapLiveness[StepFace.right] else {return}
        self.verifyDelegate?.onProcess()
        APISERVICE.verifyLiveness(path: "", pathFace: pathFace, pathLeft: pathLeft, pathRight: pathRight) { result in
            switch (result) {
            case .success(let data):
                if data.isValid {
                    self.performVerifyFaceMatching(verifyLiveness: true)
                } else {
                    self.verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.verifyLivenessError, message: data.invalidMessage), capturedFace: pathFace, ekycVerificationMode: self.verificationMode, errorCode: .EKYC_FAILED)
                    self.resetAnalysis()
                }
            case .failure(_):
                self.verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.verifyLivenessError, message: "Error"),capturedFace: pathFace, ekycVerificationMode: self.verificationMode, errorCode: .OTHER)
                self.resetAnalysis()
            }
        }
    }
    
    private func performVerifyFaceMatching(verifyLiveness: Bool) {
        guard let originFacePath = referenceImagePath,
              let capturedFacePath = mapLiveness[StepFace.face] else {return}
        APISERVICE.verifyFaceMatching(path: "", originFacePath: originFacePath, capturedFacePath: capturedFacePath) { result in
            switch (result) {
            case .success(let data):
                self.verifyDelegate?.onVerifyCompleted(ekycVerificationMode: self.verificationMode,
                                                       verifyLiveness: verifyLiveness,
                                                       verifyFaceMatch: Int(data.match) == 1,
                                                       capturedFace: self.mapLiveness[StepFace.face])
            case .failure(let error):
                if let error = error as? NSError {
                    self.verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.verifyLivenessError, message: error.localizedDescription),capturedFace: capturedFacePath, ekycVerificationMode: self.verificationMode, errorCode: .OTHER)
                }
            }
        }
    }
    
    public func performVerifyFrontFaceMatching(originPath: String) {
        guard let imgPath = self.mapLiveness[StepFace.face] else {return}
        APISERVICE.verifyFaceMatching(path: "", originFacePath: originPath, capturedFacePath: imgPath) { result in
            switch (result) {
            case .success(let data):
                self.verifyDelegate?.onVerifyCompleted(ekycVerificationMode: self.verificationMode,
                                                       verifyLiveness: false,
                                                       verifyFaceMatch: Int(data.match) == 1,
                                                       capturedFace: imgPath)
            case .failure(let error):
                if let error = error as? NSError {
                    self.verifyDelegate?.onFailed(error: ErrorUtils.error(ErrorCode.verifyLivenessError, message: error.localizedDescription),capturedFace: imgPath, ekycVerificationMode: self.verificationMode, errorCode: .OTHER)
                }
            }
        }
    }
    
    private func resetAnalysis() {
        stepFace = StepFace.left
        mapLiveness.removeAll()
    }
}

// --------------------------------------
// MARK: LivenessDetectorDelegate
// --------------------------------------
extension LivenessUtils: LivenessDetectorDelegate {
    func onTaskStarted(task: DetectionTask) {
        
    }
    
    func onTaskCompletd(task: DetectionTask, isLastTask: Bool) {
        if task is FacingDetectionTask {
            if stepFace == .left {
                faceDelegate?.onStepLeft?()
            } else if stepFace == .face {
                let fileName = "DETECT_FACE_\(Date().millisecondsSince1970).jpg"
                DISPATCH_ASYNC_MAIN_AFTER(0.5) { [weak self] in
                    guard let self = self else {return}
                    if let image = MLKitUtils.createUIImageWithImageBuffer(self.sampleBuffer) {
                        let path = MLKitUtils.saveFileToLocal(image, fileName: fileName)
                        self.faceResultDelegate?.onFaceCenter(path.absoluteString)
                        self.mapLiveness[StepFace.face] = path.absoluteString
                    }
                    self.faceDelegate?.onPlaySound?()
                    //next step after scan success
                    switch self.verificationMode {
                        // note: if livenessUlti is use to detect 3 side face, process onLeft (next side) delegate
                    case .verify_liveness, .verify_liveness_face_matching:
                        self.faceDelegate?.onStepRight?()
                    case .liveness, .liveness_face_matching:
                        // note: if livenessUlti is use to detect front face, process onFace delegate
                        self.faceDelegate?.onStepCenter?()
                    }
                    self.stepFace = .right
                    self.livenessDetector.clearTask()
                }
            } else if stepFace == .right {
                faceDelegate?.onStepRight?()
            }
        } else if task is ShakeLeftDetectionTask {
            if stepFace == .left {
                let fileName = "DETECT_LEFT_\(Date().millisecondsSince1970).jpg"
                DISPATCH_ASYNC_MAIN_AFTER(0.5) { [weak self] in
                    guard let self = self else {return}
                    if let image = MLKitUtils.createUIImageWithImageBuffer(self.sampleBuffer) {
                        let path = MLKitUtils.saveFileToLocal(image, fileName: fileName)
                        self.faceResultDelegate?.onFaceLeft(path.absoluteString)
                        self.mapLiveness[StepFace.left] = path.absoluteString
                    }
                    self.faceDelegate?.onPlaySound?()
                    self.faceDelegate?.onStepCenter?()
                    self.stepFace = .face
                    self.livenessDetector.clearTask()
                }
            }
        } else if task is ShakeRightDetectionTask {
            if stepFace == .right {
                let fileName = "DETECT_RIGHT_\(Date().millisecondsSince1970).jpg"
                DISPATCH_ASYNC_MAIN_AFTER(0.5) { [weak self] in
                    guard let self = self else {return}
                    if let image = MLKitUtils.createUIImageWithImageBuffer(self.sampleBuffer) {
                        let path = MLKitUtils.saveFileToLocal(image, fileName: fileName)
                        self.faceResultDelegate?.onFaceRight(path.absoluteString)
                        self.mapLiveness[StepFace.right] = path.absoluteString
                    }
                    self.faceDelegate?.onPlaySound?()
                    self.stepFace = .done
                    self.livenessDetector.clearTask()
                    switch self.verificationMode {
                    case .liveness:
                        self.verifyDelegate?.onVerifyCompleted(ekycVerificationMode: self.verificationMode, verifyLiveness: false, verifyFaceMatch: false, capturedFace: self.mapLiveness[StepFace.face])
                    case .liveness_face_matching:
                        self.requestVerifyFaceMatching()
                    case .verify_liveness:
                        self.requestVerifyLiveness()
                    case .verify_liveness_face_matching:
                        self.requestVerifyEkyc()
                    }
                }
            }
        }
    }
    
    func onTaskFailed(task: DetectionTask, code: Int) {
        if code == LivenessDetector.ERROR_MULTI_FACES {
            faceDelegate?.onMultiFace?()
        } else if code == LivenessDetector.ERROR_NO_FACE {
            faceDelegate?.onNoFace?()
        }
    }
}
