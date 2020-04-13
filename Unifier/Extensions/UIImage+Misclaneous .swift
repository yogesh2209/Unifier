//
//  UIImage+Misclaneous .swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit

extension UIImage {
    
    func hasAlpha() -> Bool {
        if let cgImage = self.cgImage {
            let alpha = cgImage.alphaInfo
            return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
        }
        return false
    }
    
    func flipped() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, !self.hasAlpha(), self.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width, y: 0.0)
        context.scaleBy(x: -1.0, y: 1.0)
        let rect = CGRect(origin: .zero, size: self.size)
        self.draw(in: rect)
        let retVal = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return retVal
    }
    
    func imageWithAspectFit(size:CGSize) -> UIImage? {
        let aspectFitSize = self.getAspectFitSize(destination: size)
        let resizedImage = self.resize(size: aspectFitSize)
        return resizedImage
    }
    
    private func getAspectFitSize(destination dst:CGSize) -> CGSize {
        var result = CGSize.zero
        var scaleRatio = CGPoint()
        
        if (dst.width != 0) {scaleRatio.x = self.size.width / dst.width}
        if (dst.height != 0) {scaleRatio.y = self.size.height / dst.height}
        let scaleFactor = max(scaleRatio.x, scaleRatio.y)
        
        result.width  = scaleRatio.x * dst.width / scaleFactor
        result.height = scaleRatio.y * dst.height / scaleFactor
        return result
    }
    
    func resize(size:CGSize) -> UIImage? {
        let imageRect = CGRect(origin: .zero, size: size);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0);
        self.draw(in: imageRect)
        let scaled = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaled
    }
    
}
