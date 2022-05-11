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
    case canny     = "Canny Edge Detector"
    case prewitt   = "Prewitt Operator"
    case roberts   = "Roberts Cross Operator"
}

class ImageManager {
    var imageDictionary = [Filter: UIImage?]()
    
    func getImage(for filter: Filter) -> UIImage? {
        if let image = imageDictionary[filter] { return image }
        
        switch filter {
        case .sobel:
            print(filter.rawValue)
        case .scharr:
            print(filter.rawValue)
        case .canny:
            print(filter.rawValue)
        case .prewitt:
            print(filter.rawValue)
        case .roberts:
            print(filter.rawValue)
        default:
            print(filter.rawValue)
        }
        
        return nil
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
}
