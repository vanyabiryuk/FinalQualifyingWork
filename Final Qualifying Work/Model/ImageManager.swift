//
//  ImageManager.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 11.05.2022.
//

import Foundation
import UIKit

class ImageManager {
    var imageDictionary = [Filter: UIImage?]()
    var timeDictionary = [Filter: UInt64]()
    
    func getImage(with filter: Filter) -> UIImage? {
        if let image = imageDictionary[filter] { return image }
        let results = applyAlgorithm(with: filter) ?? (nil, 0)
        imageDictionary[filter] = results.image
        timeDictionary[filter] = results.time / 1_000_000
        return results.image
    }
    
    func getTime(of filter: Filter) -> UInt64 {
        return timeDictionary[filter] ?? 0
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
        timeDictionary[.original] = 0
        timeDictionary[.grayscale] = 0
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
    
    func applyAlgorithm(with filter: Filter) -> (image: UIImage?, time: UInt64)? {
        let begin = DispatchTime.now()
        guard let grayscaleImageCGContext = grayscaleImageCGContext() else { return nil }
        let width = grayscaleImageCGContext.width
        let height = grayscaleImageCGContext.height
        
        guard let dataUMRP = grayscaleImageCGContext.data else { return nil }
        
        let dataUMP = dataUMRP.bindMemory(to: UInt8.self, capacity: width * height)
        let pixelData = UnsafeMutableBufferPointer<UInt8>(start: dataUMP, count: width * height)
        defer {
            pixelData.deallocate()
        }
        
        // TODO: create separately for different methods
        
        let unsafeBrightness: [[Double]]?
        
        switch filter {
        case .sobel, .scharr, .prewitt, .roberts:
            unsafeBrightness = create2DArray(data: pixelData,
                                             width: width,
                                             height: height)
        case .canny:
            unsafeBrightness = create2DArray(data: pixelData,
                                             width: width,
                                             height: height)
        default:
            unsafeBrightness = nil
        }
        
        guard let brightness = unsafeBrightness else { return nil }
        
        let unsafeMagnitude: [[Double]]?
        
        switch filter {
        case .sobel:
            unsafeMagnitude = getMagnitudeOdd(array: brightness,
                                              width: width,
                                              height: height,
                                              xKernel: K.sobelXKernel,
                                              yKernel: K.sobelYKernel)
        case .scharr:
            unsafeMagnitude = getMagnitudeOdd(array: brightness,
                                              width: width,
                                              height: height,
                                              xKernel: K.scharrXKernel,
                                              yKernel: K.scharrYKernel)
        case .prewitt:
            unsafeMagnitude = getMagnitudeOdd(array: brightness,
                                              width: width,
                                              height: height,
                                              xKernel: K.prewittXKernel,
                                              yKernel: K.prewittYKernel)
        case .roberts:
            unsafeMagnitude = getRobertsCrossMagnitude(array: brightness,
                                                       width: width,
                                                       height: height)
        case .canny:
            unsafeMagnitude = getCannyMagnitude(array: brightness,
                                                width: width,
                                                height: height)
        default:
            unsafeMagnitude = nil
        }
        
        guard let magnitude = unsafeMagnitude else { return nil }
        
        let magnitudeHeight = magnitude.count
        let magnitudeWidth = magnitude[0].count
        
        let newPixelData = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: magnitudeWidth * magnitudeHeight)
        defer {
            newPixelData.deallocate()
        }
        
        for row in 0..<magnitudeHeight {
            for column in 0..<magnitudeWidth {
                newPixelData[row * magnitudeWidth + column] = UInt8(magnitude[row][column])
            }
        }
        
        let space = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue
        
        guard let cgContext = CGContext(data: newPixelData.baseAddress,
                                        width: magnitudeWidth,
                                        height: magnitudeHeight,
                                        bitsPerComponent: 8,
                                        bytesPerRow: magnitudeWidth,
                                        space: space,
                                        bitmapInfo: bitmapInfo) else { return nil }
        
        guard let cgImage = cgContext.makeImage() else { return nil }
        guard let originalImage = imageDictionary[.original] ?? nil else { return nil }
        
        let newImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: originalImage.imageOrientation)
        let end = DispatchTime.now()
        let time = end.uptimeNanoseconds - begin.uptimeNanoseconds
        return (image: newImage, time: time)
    }
}
