//
//  UIUtilities.swift
//  xverifysdk
//
//  Created by Minh Tri on 09/12/2023.
//

import AVFoundation
import CoreVideo
import UIKit

/// Defines UI-related utilitiy methods for vision detection.
class MLKitUtils {
    
    static func imageOrientation(fromDevicePosition devicePosition: AVCaptureDevice.Position = .back) -> UIImage.Orientation {
        var deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .faceDown || deviceOrientation == .faceUp || deviceOrientation == .unknown {
            deviceOrientation = currentUIOrientation()
        }
        switch deviceOrientation {
        case .portrait:
            return devicePosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return devicePosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return devicePosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return devicePosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            fatalError()
        }
    }
    
    static func currentUIOrientation() -> UIDeviceOrientation {
        let deviceOrientation = { () -> UIDeviceOrientation in
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                return .landscapeRight
            case .landscapeRight:
                return .landscapeLeft
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .portrait, .unknown:
                return .portrait
            @unknown default:
                fatalError()
            }
        }
        guard Thread.isMainThread else {
          var currentOrientation: UIDeviceOrientation = .portrait
          DispatchQueue.main.sync {
            currentOrientation = deviceOrientation()
          }
          return currentOrientation
        }
        return deviceOrientation()
    }
    
    static func rotateImage(image: UIImage) -> UIImage {
        if (image.imageOrientation == UIImage.Orientation.up) {
            return image
        }
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return copy!
    }
    
    static func createUIImage(from imageBuffer: CVImageBuffer, orientation: UIImage.Orientation) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }
    
    static func createUIImageWithImageBuffer(_ sampleBuffer: CMSampleBuffer?) -> UIImage? {
        guard let sampleBuffer = sampleBuffer,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let orientation: UIImage.Orientation = .leftMirrored
        if let image = createUIImage(from: imageBuffer, orientation: orientation) {
            return rotateImage(image: image)
        }
        
        return nil
    }
    
    static func saveFileToLocal(_ image: UIImage, fileName: String) -> URL {
        let directoryPath =  try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let urlString: NSURL = directoryPath.appendingPathComponent(fileName) as NSURL
        print("Image path : \(urlString)")
        if !FileManager.default.fileExists(atPath: urlString.path!) {
            do {
                try image.jpegData(compressionQuality: 1.0)!.write(to: urlString as URL)
                    print ("Image Added Successfully")
            } catch {
                    print ("Image Not added")
            }
        }
        return urlString as URL
    }
}
