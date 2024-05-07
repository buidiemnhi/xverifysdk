import MLKitFaceDetection
import MLKitVision
import UIKit

class DetectionUtils {
    
    class func isFacing(face: Face) -> Bool {
        return face.headEulerAngleZ < 7.78 && face.headEulerAngleZ > -7.78
        && face.headEulerAngleY < 11.8 && face.headEulerAngleY > -11.8
        && face.headEulerAngleX < 19.8 && face.headEulerAngleX > -19.8
    }
    
    class func isMouthOpen(face: Face) -> Bool {
        guard let left = face.landmark(ofType: .mouthLeft)?.position else { return false }
        guard let right = face.landmark(ofType: .mouthRight)?.position else { return false }
        guard let bottom = face.landmark(ofType: .mouthBottom)?.position else { return false }
        
        // Square of lengths be a2, b2, c2
        let a2 = lengthSquare(a: right, b: bottom)
        let b2 = lengthSquare(a: left, b: bottom)
        let c2 = lengthSquare(a: left, b: right)
        
        // Length of sides be a, b, c
        let a = sqrt(a2)
        let b = sqrt(b2)
        
        // From Cosine law
        let gamma = acos((a2 + b2 - c2) / (2 * a * b))
        
        // Converting to degrees
        let gammaDeg = gamma * 180 / CGFloat.pi
        return gammaDeg < 115.0
    }
    
    class func isFaceInDetectionRect(face: Face, detectionSize: Int) -> Bool {
        let frame = face.frame
        let fx = frame.midX
        let fy = frame.midY
        let gridSize = CGFloat(detectionSize / 8)
        if fx < gridSize * 2 || fx > gridSize * 6 || fy < gridSize * 2 || fy > gridSize * 6 {
            print("face center point is out of rect: (\(fx), \(fy))")
            return false
        }
        let fw = frame.width
        let fh = frame.height
        if fw < gridSize * 3 || fw > gridSize * 6 || fh < gridSize * 3 || fh > gridSize * 6 {
            print("unexpected face size: (\(fx), \(fy))")
            return false
        }
        return true
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    class func lengthSquare(a: VisionPoint, b: VisionPoint) -> CGFloat {
        let x = a.x - b.x
        let y = a.y - b.y
        return x * x + y * y
    }
}


