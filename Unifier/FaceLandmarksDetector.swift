//
//  FaceLandmarksDetector.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

public class FaceLandmarksDetector {
    
    /// Edited Image - going to return this to controller to set it
    var editedImage: UIImage?
    
    /// SourceImage
    var sourceImage: UIImage?
    
    /// Bounding Rect
    var boundingRect: CGRect?
    
    func addFaceLandmarksToImage(_ faces: [VNFaceObservation], sourceImage: UIImage, isFaceLinesShown: Bool = false) -> UIImage? {
        
        for index in 0..<faces.count {
            let face = faces[index]
            editedImage = drawOnImage(source: sourceImage, face: face, isFaceLinesShown: isFaceLinesShown)
        }
        
        // End drawing context
        UIGraphicsEndImageContext()
        
        return editedImage
    }
    
    private func drawOnImage(source: UIImage, face: VNFaceObservation, isFaceLinesShown: Bool = false) -> UIImage {
        
        /// Begin image context
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        
        /// context
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        /// Set properties
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let x = face.boundingBox.origin.x * source.size.width
        let y = face.boundingBox.origin.y * source.size.height
        let w = face.boundingBox.size.width * source.size.width
        let h = face.boundingBox.size.height * source.size.height
        
        let faceRect = CGRect(x: x, y: y, width: w, height: h)
        self.boundingRect = faceRect
        self.sourceImage = source
        
        /// Draw bound rect
        if isFaceLinesShown {
            context.saveGState()
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(8.0)
            context.addRect(faceRect)
            context.drawPath(using: .stroke)
            context.restoreGState()
        }
        
        if let faceContour = face.landmarks?.faceContour {
            drawFeature(faceContour, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow)
        }
        
        /// Left Eye
        if let leftEye = face.landmarks?.leftEye {
            drawFeature(leftEye, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow, close: true)
        }
        
        /// Right Eye
        if let rightEye = face.landmarks?.rightEye {
            drawFeature(rightEye, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow, close: true)
        }
        
        /// Reference to store left and right eye points
        var leftEyeCoordinate: CGPoint? = nil
        var rightEyeCoordinate: CGPoint? = nil
        
        /// Left Pupil
        if let leftPupil = face.landmarks?.leftPupil {
            leftEyeCoordinate = leftPupil.pointsInImage(imageSize: CGSize(width: source.size.width, height: source.size.height)).last
            drawFeature(leftPupil, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow, close: true)
        }
        
        /// Right Pupil
        if let rightPupil = face.landmarks?.rightPupil {
            rightEyeCoordinate = rightPupil.pointsInImage(imageSize: CGSize(width: source.size.width, height: source.size.height)).last
            drawFeature(rightPupil, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow, close: true)
        }
        
        /// Third vertex calculation to calculate point on forehead to add image on
        let third = CGPoint.thirdVertexTriangle(leftPoint: leftEyeCoordinate!, rightPoint: rightEyeCoordinate!)
        
        /// Distance between eye coordinates
        let distance = CGPoint.distanceBetweenPoints(leftPoint: leftEyeCoordinate!, rightPoint: rightEyeCoordinate!)
        
        /// vertical distance between forehead point and the horizontal line between eye coordinates
        let perpendicularDistance = (sqrt(3) * distance) / 2
        
        /// Adding Image
        let imageToAttach = UIImage(named: "uinicorn_horn.png") //TODO update
        
        let rotatedImage = imageToAttach?.rotate(radians: CGFloat(truncating: face.yaw ?? 0.0))
        let imageRect = CGRect(x: third.x - w/2, y: third.y - perpendicularDistance/4, width: w, height: h)
        /// If we get rotated image back
        if let image = rotatedImage {
            context.draw((image.cgImage)!, in: imageRect)
        } else {
            if let im = imageToAttach {
                context.draw((im.cgImage)!, in: imageRect)
            }  else {
                return UIImage()
            }
        }
        
        /// Nose
        if let nose = face.landmarks?.nose {
            drawFeature(nose, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow)
        }
        
        /// Nose Crest
        if let noseCrest = face.landmarks?.noseCrest {
            drawFeature(noseCrest, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow)
        }
        
        /// Median Line
        if let medianLine = face.landmarks?.medianLine {
            drawFeature(medianLine, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow)
        }
        
        /// Outer Lips
        if let outerLips = face.landmarks?.outerLips {
            drawFeature(outerLips, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow, close: true)
        }
        
        /// Inner Lips
        if let innerLips = face.landmarks?.innerLips {
            drawFeature(innerLips, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow, close: true)
        }
        
        /// Left Eyebrow
        if let leftEyebrow = face.landmarks?.leftEyebrow {
            drawFeature(leftEyebrow, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow)
        }
        
        /// Right Eyebrow
        if let rightEyebrow = face.landmarks?.rightEyebrow {
            drawFeature(rightEyebrow, context: context, shouldShowFaceLines: isFaceLinesShown, color: .yellow)
        }
        
        
        /// If image available - return
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        
        /// Returning empty image
        return UIImage()
    }
    
}


// MARK: - Draw Feature/Lines Logic
extension FaceLandmarksDetector {
    
    func drawFeature(_ feature: VNFaceLandmarkRegion2D, context: CGContext, shouldShowFaceLines: Bool, color: UIColor, close: Bool = false) {
        
        guard shouldShowFaceLines, let sourceImageToUse = self.editedImage,  let boundingRectToUse = self.boundingRect else {
            return
        }
        
        context.setStrokeColor(color.cgColor)
        context.setFillColor(color.cgColor)
        
        let rectWidth = sourceImageToUse.size.width * boundingRectToUse.size.width
        let rectHeight = sourceImageToUse.size.height * boundingRectToUse.size.height
        
        for point in feature.normalizedPoints {
            /// Draw DEBUG numbers
            let textFontAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            context.saveGState()
            /// Rotate to draw numbers
            context.translateBy(x: 0.0, y: sourceImageToUse.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            let mp = CGPoint(x: boundingRectToUse.origin.x * sourceImageToUse.size.width + point.x * rectWidth, y: sourceImageToUse.size.height - (boundingRectToUse.origin.y * sourceImageToUse.size.height + point.y * rectHeight))
            context.fillEllipse(in: CGRect(origin: CGPoint(x: mp.x-2.0, y: mp.y-2), size: CGSize(width: 4.0, height: 4.0)))
            if let index = feature.normalizedPoints.firstIndex(of: point) {
                String(format: "%d", index).draw(at: mp, withAttributes: textFontAttributes)
            }
            context.restoreGState()
        }
        
        /// Get all points and map them and make lines
        let mappedPoints = feature.normalizedPoints.map { CGPoint(x: boundingRectToUse.origin.x * sourceImageToUse.size.width + $0.x * rectWidth, y: boundingRectToUse.origin.y * sourceImageToUse.size.height + $0.y * rectHeight) }
        context.addLines(between: mappedPoints)
        if close, let first = mappedPoints.first, let lats = mappedPoints.last {
            context.addLines(between: [lats, first])
        }
        context.strokePath()
    }
}
