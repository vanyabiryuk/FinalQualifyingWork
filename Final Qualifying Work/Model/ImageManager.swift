//
//  ImageManager.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 11.05.2022.
//

import Foundation
import UIKit

enum Filter: String, CaseIterable {
    case original  = "Original Image"
    case grayscale = "Grayscale Image"
    case sobel     = "Sobel Operator"
    case scharr    = "Scharr Operator"
    case prewitt   = "Prewitt Operator"
    case canny     = "Canny Edge Detector"
    case roberts   = "Roberts Cross Operator"
}

class ImageManager {
    var imageDictionary = [Filter: UIImage?]()
    
    func getImage(with filter: Filter) -> UIImage? {
        if let image = imageDictionary[filter] { return image }
        return applyAlgorithm(with: filter)
    }
    
    func createGrayscaleImage() {
        guard let originalImage = imageDictionary[.original] ?? nil else {
            print("Couldn't create grayscale image: original image was not provided.")
            return
        }
        
        guard let originalCGImage = originalImage.cgImage else {
            print("Couldn't create grayscale image: original image's cgImage proverty is nil.")
            return
        }
        
        let width = originalCGImage.width
        let height = originalCGImage.height
        let space = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue
        
        guard let cgContext = CGContext(data: nil,
                                        width: width,
                                        height: height,
                                        bitsPerComponent: 8,
                                        bytesPerRow: 0,
                                        space: space,
                                        bitmapInfo: bitmapInfo) else {
            print("Couldn't create grayscale image: CGContext is nil")
            return
        }
        
        let drawRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        cgContext.draw(originalCGImage, in: drawRectangle)
        
        guard let grayscaleCGImage = cgContext.makeImage() else {
            print("Couldn't create grayscale image: grayscale CGImage is nil.")
            return
        }
        
        imageDictionary[.grayscale] = UIImage(cgImage: grayscaleCGImage,
                                              scale: 1.0,
                                              orientation: originalImage.imageOrientation)
    }
    
    func grayscaleImageCGContext() -> CGContext? {
        guard let gsImage = imageDictionary[.grayscale] ?? nil else {
            print("Couldn't create grayscale image CGContext: grayscale image is nil.")
            return nil
        }
        
        guard let gsCGImage = gsImage.cgImage else {
            print("Couldn't create grayscale image CGContext: grayscale CGImage is nil.")
            return nil
        }
        
        let width = gsCGImage.width
        let height = gsCGImage.height
        let bytesPerRow = width
        let space = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue
        
        let data = UnsafeMutableRawPointer.allocate(byteCount: height * bytesPerRow, alignment: 1)
        
        guard let cgContext = CGContext(data: data,
                                        width: width,
                                        height: height,
                                        bitsPerComponent: 8,
                                        bytesPerRow: bytesPerRow,
                                        space: space,
                                        bitmapInfo: bitmapInfo) else {
            print("Couldn't create grayscale image CGContext: CGContext is nil.")
            return nil
        }
        
        let drawRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        cgContext.draw(gsCGImage, in: drawRectangle)
        
        return cgContext
    }
    
    func applyAlgorithm(with filter: Filter) -> UIImage? {
        
        guard let grayscaleImageCGContext = grayscaleImageCGContext() else { return nil }
        let width = grayscaleImageCGContext.width
        let height = grayscaleImageCGContext.height
        
        guard let dataUMRP = grayscaleImageCGContext.data else { return nil }
        
        let dataUMP = dataUMRP.bindMemory(to: UInt8.self, capacity: width * height)
        let pixelData = UnsafeMutableBufferPointer<UInt8>(start: dataUMP, count: width * height)
        defer {
            pixelData.deallocate()
        }
        
        
        let brightness = create2DArray(data: pixelData,
                                       padding: 1,
                                       columns: width,
                                       rows: height)
        
        var magnitude: [[Double]]?
        
        switch filter {
        case .sobel:
            magnitude = getMagnitudeOdd(array: brightness,
                                        columns: width,
                                        rows: height,
                                        xKernel: K.sobelXKernel,
                                        yKernel: K.sobelYKernel)
        case .scharr:
            magnitude = getMagnitudeOdd(array: brightness,
                                        columns: width,
                                        rows: height,
                                        xKernel: K.scharrXKernel,
                                        yKernel: K.scharrYKernel)
        case .prewitt:
            magnitude = getMagnitudeOdd(array: brightness,
                                        columns: width,
                                        rows: height,
                                        xKernel: K.prewittXKernel,
                                        yKernel: K.prewittYKernel)
        case .roberts:
            magnitude = getRobertsCrossMagnitude(array: brightness,
                                                 columns: width,
                                                 rows: height)
        default:
            break
        }
        
        guard let safeMagnitude = magnitude else { return nil }
        
        for row in 0..<height {
            for column in 0..<width {
                pixelData[row * width + column] = UInt8(safeMagnitude[row][column])
            }
        }
        
        let space = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue
        
        guard let cgContext = CGContext(data: pixelData.baseAddress,
                                        width: width,
                                        height: height,
                                        bitsPerComponent: 8,
                                        bytesPerRow: width,
                                        space: space,
                                        bitmapInfo: bitmapInfo) else { return nil }
        
        guard let cgImage = cgContext.makeImage() else { return nil }
        guard let originalImage = imageDictionary[.original] ?? nil else { return nil }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: originalImage.imageOrientation)
    }
}
