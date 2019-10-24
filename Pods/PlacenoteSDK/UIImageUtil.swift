//
//  UIImageUtil.swift
//  PlacenoteSDK
//
//  Created by Yan Ma on 2019-09-17.
//

import Foundation
import VideoToolbox
import Accelerate

/// Extensions to UIImage to provide extra utilities to UIImage
extension UIImage {
  /**
   Constructor that converts a CVPixelBuffer to a UIImage
  
   - Parameter pixelBuffer: a pixel buffer to be converted into a UIImage
   */
  public convenience init?(pixelBuffer: CVPixelBuffer) {
    var cgImage: CGImage?
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &cgImage)
    
    if let cgImage = cgImage {
      self.init(cgImage: cgImage)
    } else {
      return nil
    }
  }
  
  /**
   Resize a UIImage to the size given by the parameter
  
   - Parameter size: target size for the resize operation
   */
  func resize(size:CGSize) -> UIImage? {
    let cgImage = self.cgImage!
    var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
    var sourceBuffer = vImage_Buffer()
    defer {
      free(sourceBuffer.data)
    }
    var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
    guard error == kvImageNoError else { return nil }
    // create a destination buffer
    let scale = self.scale
    let destWidth = Int(size.width)
    let destHeight = Int(size.height)
    let bytesPerPixel = self.cgImage!.bitsPerPixel/8
    let destBytesPerRow = destWidth * bytesPerPixel
    let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
    defer {
      destData.deallocate()
    }
    var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
    // scale the image
    error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
    guard error == kvImageNoError else { return nil }
    // create a CGImage from vImage_Buffer
    var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
    guard error == kvImageNoError else { return nil }
    // create a UIImage
    let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation) }
    destCGImage = nil
    return resizedImage
  }
  
  /**
   Rotate a UIImage by the angle given by the radians parameter
  
   - Parameter radians: amount of radians to rotate the image
   */
  func rotate(radians: CGFloat) -> UIImage {
    let rotatedSize = CGRect(origin: .zero, size: size)
      .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
      .integral.size
    UIGraphicsBeginImageContext(rotatedSize)
    if let context = UIGraphicsGetCurrentContext() {
      let origin = CGPoint(x: rotatedSize.width / 2.0,
                           y: rotatedSize.height / 2.0)
      context.translateBy(x: origin.x, y: origin.y)
      context.rotate(by: radians)
      draw(in: CGRect(x: -origin.y, y: -origin.x,
                      width: size.width, height: size.height))
      let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return rotatedImage ?? self
    }
    
    return self
  }
}
