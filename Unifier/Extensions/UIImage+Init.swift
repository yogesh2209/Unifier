//
//  UIImage+Init.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit
import CoreMedia

extension UIImage {
    
    convenience init?(sampleBuffer: CMSampleBuffer) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        let quartzImage = context.makeImage()
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        
        if let quartz = quartzImage {
            self.init(cgImage: quartz, scale: 1.0, orientation: .right)
            //self.init(cgImage: quartz)
        } else {
            return nil
        }
    }
}
