//
//  DataProcessing.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 12.05.2022.
//

import Foundation
import UIKit

func create2DArray(data: UnsafeMutableBufferPointer<UInt8>,
                   width: Int,
                   height: Int) -> [[Double]] {
    
    var arr = [[Double]](repeating: [Double](repeating: 0, count: width),
                         count: height)
    
    for r in 0..<height {
        for c in 0..<width {
            let pixel = r * width + c
            arr[r][c] = Double(data[pixel])
        }
    }
    
    return arr
}

func validateConvolusionKernel(kernel: [[Double]],
                               issueText: String) -> Bool {
    let kernelSize = kernel.count
    
    guard kernelSize > 0 else {
        print("\(issueText) Kernel size is less than or equal to 0.")
        print("Kernel size: \(kernelSize)")
        return false
    }
    
    guard kernelSize % 2 == 1 else {
        print("\(issueText) Kernel size is an even number.")
        print("Kernel size: \(kernelSize).")
        return false
    }
    
    for row in 0..<kernelSize {
        guard kernel[row].count == kernelSize else {
            print("\(issueText) Width of one of kernel's rows is not equal to kernel's height.")
            print("Kernel's height: \(kernel.count);")
            print("Kernel's width on row no. \(row): \(kernel[row].count).")
            return false
        }
    }
    
    return true
}

func validateConvolusionArray(array: [[Double]],
                              width: Int,
                              height: Int,
                              issueText: String) -> Bool {
    
    guard array.count == height else {
        print("\(issueText) Height of array is not equal to height of convolved array with padding.")
        print("Height of array: \(array.count);")
        print("Expected height: \(height).")
        return false
    }
    
    for row in 0..<array.count {
        guard array[row].count == width else {
            print("\(issueText) Width of array is not equal to width of convolved array with padding.")
            print("Width of array: \(array[row].count);")
            print("Expected width: \(width);")
            print("Issue occured on row no. \(row).")
            return false
        }
    }
    
    return true
}

func cropArray(array: [[Double]],
               width: Int,
               height: Int,
               cropping: Int) -> [[Double]] {
    var result = [[Double]](repeating: [Double](repeating: 0.0, count: width - 2 * cropping),
                            count: height - 2 * cropping)
    
    for row in 0..<(result.count) {
        for column in 0..<(result[row].count) {
            result[row][column] = array[row + cropping][column + cropping]
        }
    }
    
    return result
}

func applyConvolution(array: [[Double]],
                      width: Int,
                      height: Int,
                      kernel: [[Double]]) -> [[Double]]? {
    
    let functionName = "applyConvolution(array:columns:rows:kernel:)"
    let issueText = "Issue in \(functionName) function."
    
    guard validateConvolusionKernel(kernel: kernel,
                                    issueText: issueText) else { return nil }
    
    guard validateConvolusionArray(array: array,
                                   width: width,
                                   height: height,
                                   issueText: issueText) else { return nil }
    
    let kernelSize = kernel.count
    let cropping = kernelSize / 2
    let resultWidth = width - 2 * cropping
    let resultHeight = height - 2 * cropping
    
    var result = [[Double]](repeating: [Double](repeating: 0.0, count: resultWidth),
                            count: resultHeight)
    
    for row in 0..<resultHeight {
        for column in 0..<resultWidth {
            var arrayValue = 0.0
            
            for i in 0..<kernelSize {
                let r = row + i
                for j in 0..<kernelSize {
                    let c = column + j
                    arrayValue += array[r][c] * kernel[i][j]
                }
            }
            
            result[row][column] = arrayValue
        }
    }
    
    return result
}

func getMagnitudeOdd(array: [[Double]],
                     width: Int,
                     height: Int,
                     xKernel: [[Double]],
                     yKernel: [[Double]]) -> [[Double]]? {
    
    let functionName = "getMagnitudeOdd(array:columns:rows:xKernel:yKernel)"
    let issueText = "Issue in \(functionName) function."
    
    guard validateConvolusionKernel(kernel: xKernel,
                                    issueText: issueText) else { return nil }
    
    guard validateConvolusionKernel(kernel: yKernel,
                                    issueText: issueText) else { return nil }
    
    guard validateConvolusionArray(array: array,
                                   width: width,
                                   height: height,
                                   issueText: issueText) else { return nil }
    
    let kernelSize = xKernel.count
    let cropping = kernelSize / 2
    let resultWidth = width - 2 * cropping
    let resultHeight = height - 2 * cropping
    
    var minMagnitude =  1_000_000_000.0
    var maxMagnitude = -1_000_000_000.0
    
    var result = [[Double]](repeating: [Double](repeating: 0.0, count: resultWidth),
                            count: resultHeight)
    for row in 0..<resultHeight {
        for column in 0..<resultWidth {
            var x = 0.0
            var y = 0.0
            
            for i in 0..<kernelSize {
                let r = row + i
                for j in 0..<kernelSize {
                    let c = column + j
                    
                    x += array[r][c] * xKernel[i][j]
                    y += array[r][c] * yKernel[i][j]
                }
            }
            
            let magnitude = sqrt(pow(x, 2) + pow(y, 2))
            
            if magnitude > maxMagnitude { maxMagnitude = magnitude }
            if magnitude < minMagnitude { minMagnitude = magnitude }
            
            result[row][column] = magnitude
        }
    }
    
    let magnitudeSpread = maxMagnitude - minMagnitude
    for row in 0..<resultHeight {
        for column in 0..<resultWidth {
            result[row][column] = 255 * (result[row][column] - minMagnitude) / magnitudeSpread
        }
    }
    
    return result
}

func getRobertsCrossMagnitude(array: [[Double]],
                              width: Int,
                              height: Int) -> [[Double]]? {
    
    let functionName = "getRobertsCrossMagnitude(array:columns:rows:)"
    let issueText = "Issue in \(functionName) function."
    
    guard validateConvolusionArray(array: array,
                                   width: width,
                                   height: height,
                                   issueText: issueText) else { return nil }
    
    let resultWidth = width - 1
    let resultHeight = height - 1
    
    var minMagnitude =  1_000_000_000.0
    var maxMagnitude = -1_000_000_000.0
    
    var result = [[Double]](repeating: [Double](repeating: 0.0, count: resultWidth),
                            count: resultHeight)
    
    for row in 0..<resultHeight {
        for column in 0..<resultWidth {
            let a = array[row][column] - array[row + 1][column + 1]
            let b = array[row][column + 1] - array[row + 1][column]
            
            let magnitude = sqrt(pow(a, 2) + pow(b, 2))
            if magnitude > maxMagnitude { maxMagnitude = magnitude }
            if magnitude < minMagnitude { minMagnitude = magnitude }
            
            result[row][column] = magnitude
        }
    }
    
    let magnitudeSpread = maxMagnitude - minMagnitude
    for row in 0..<resultHeight {
        for column in 0..<resultWidth {
            result[row][column] = 255 * (result[row][column] - minMagnitude) / magnitudeSpread
        }
    }
    
    return result
}

func getCannyMagnitude(array: [[Double]],
                       width: Int,
                       height: Int) -> [[Double]]? {
    let gaussian = K.gaussian5x5
    
    guard var smoothArray = applyConvolution(array: array,
                                             width: width,
                                             height: height,
                                             kernel: gaussian) else { return nil }
    
    let smoothWidth = smoothArray[0].count
    let smoothHeight = smoothArray.count
    
    guard var sobelGradientX = applyConvolution(array: smoothArray,
                                                width: smoothWidth,
                                                height: smoothHeight,
                                                kernel: K.sobelXKernel) else { return nil }
    
    guard var sobelGradientY = applyConvolution(array: smoothArray,
                                                width: smoothWidth,
                                                height: smoothHeight,
                                                kernel: K.sobelYKernel) else { return nil }
    
    smoothArray.removeAll()
    
    var minMagnitude =  1_000_000_000.0
    var maxMagnitude = -1_000_000_000.0
    
    let sobelWidth = sobelGradientX[0].count
    let sobelHeight = sobelGradientX.count
    
    var magnitude = [[Double]](repeating: [Double](repeating: 0.0, count: sobelWidth),
                               count: sobelHeight)
    var direction = [[Direction]](repeating: [Direction](repeating: .east, count: sobelWidth),
                                  count: sobelHeight)
    
    for row in 0..<sobelHeight {
        for column in 0..<sobelWidth {
            var x = sobelGradientX[row][column]
            var y = sobelGradientY[row][column]
            
            let cellMagnitude = sqrt(pow(x, 2) + pow(y, 2))
            
            if cellMagnitude > maxMagnitude { maxMagnitude = cellMagnitude }
            if cellMagnitude < minMagnitude { minMagnitude = cellMagnitude }
            
            magnitude[row][column] = cellMagnitude
            
            if y < 0 {
                x *= -1.0
                y *= -1.0
            }
            
            if y > K.tan67_5deg * abs(x) {
                direction[row][column] = .north
            } else if y < K.tan22_5deg * abs(x) {
                direction[row][column] = .east
            } else if x >= 0 {
                direction[row][column] = .north_east
            } else {
                direction[row][column] = .north_west
            }
        }
    }
    
    sobelGradientX.removeAll()
    sobelGradientY.removeAll()
    
    let magnitudeSpread = maxMagnitude - minMagnitude
    for row in 0..<sobelHeight {
        for column in 0..<sobelWidth {
            magnitude[row][column] = 255 * (magnitude[row][column] - minMagnitude) / magnitudeSpread
        }
    }
    
    var suppressMagnitude = [[Double]](repeating: [Double](repeating: 0.0, count: sobelWidth),
                                       count: sobelHeight)
    
    for row in 1..<(sobelHeight - 1) {
        for column in 1..<(sobelWidth - 1) {
            let i = magnitude[row][column]
            var j: Double
            var k: Double
            
            let dir = direction[row][column]
            
            switch dir {
            case .east:
                j = magnitude[row    ][column - 1]
                k = magnitude[row    ][column + 1]
            case .north_east:
                j = magnitude[row - 1][column + 1]
                k = magnitude[row + 1][column - 1]
            case .north:
                j = magnitude[row - 1][column    ]
                k = magnitude[row + 1][column    ]
            case .north_west:
                j = magnitude[row - 1][column - 1]
                k = magnitude[row + 1][column + 1]
            }
            
            if i > j && i > k {
                suppressMagnitude[row][column] = magnitude[row][column]
            } else {
                suppressMagnitude[row][column] = 0.0
            }
        }
    }
    
    let resultWidth = sobelWidth - 2
    let resultHeight = sobelHeight - 2
    
    var result = [[Double]](repeating: [Double](repeating: 0.0, count: resultWidth),
                            count: resultHeight)
    
    let lowerThreshold =  32.0
    let upperThreshold =  63.0
    
    for row in 0..<resultHeight {
        for column in 0..<resultWidth {
            let i = row + 1
            let j = column + 1
            
            let cellMagnitude = suppressMagnitude[i][j]
            if cellMagnitude > upperThreshold {
                result[row][column] = 255
            } else if cellMagnitude < lowerThreshold {
                result[row][column] = 0
            } else {
                if suppressMagnitude[i - 1][j - 1]  > upperThreshold ||
                    suppressMagnitude[i - 1][j    ] > upperThreshold ||
                    suppressMagnitude[i - 1][j + 1] > upperThreshold ||
                    suppressMagnitude[i    ][j - 1] > upperThreshold ||
                    suppressMagnitude[i    ][j + 1] > upperThreshold ||
                    suppressMagnitude[i + 1][j - 1] > upperThreshold ||
                    suppressMagnitude[i + 1][j    ] > upperThreshold ||
                    suppressMagnitude[i + 1][j + 1] > upperThreshold {
                    result[row][column] = 255
                } else {
                    result[row][column] = 0
                }
            }
        }
    }
    
    return result
}
