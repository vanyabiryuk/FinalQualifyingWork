//
//  DataProcessing.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 12.05.2022.
//

import Foundation

func create2DArray(data: UnsafeMutableBufferPointer<UInt8>,
                   padding: Int,
                   columns: Int,
                   rows: Int) -> [[Double]] {
    
    var newArray = [[Double]](repeating: [Double](repeating: Double.zero, count: columns + 2 * padding),
                              count: rows + 2 * padding)
    
    for row in 0..<rows {
        for column in 0..<columns {
            let pixelIndex = row * columns + column
            newArray[row + padding][column + padding] = Double(data[pixelIndex])
        }
    }
    
    return newArray
}

func validateConvolusionKernel(kernel: [[Double]],
                               padding: Int,
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
    
    guard padding == kernelSize / 2 else {
        print("\(issueText) Kernel is not applicable for the array.")
        print("Padding: \(padding);")
        print("Expected padding: \(kernelSize / 2).")
        return false
    }
    
    return true
}

func validateConvolusionArray(array: [[Double]],
                              columns: Int,
                              rows: Int,
                              padding: Int,
                              issueText: String) -> Bool {
    let expectedHeight = rows + 2 * padding
    let expectedWidth = columns + 2 * padding
    
    guard array.count == expectedHeight else {
        print("\(issueText) Height of array is not equal to height of convolved array with padding.")
        print("Height of array: \(array.count);")
        print("Expected height: \(expectedHeight).")
        return false
    }
    
    for row in 0..<array.count {
        guard array[row].count == expectedWidth else {
            print("\(issueText) Width of array is not equal to width of convolved array with padding.")
            print("Width of array: \(array[row].count);")
            print("Expected width: \(expectedWidth);")
            print("Issue occured on row no. \(row).")
            return false
        }
    }
    
    return true
}

func applyConvolution(array: [[Double]],
                      columns: Int,
                      rows: Int,
                      kernel: [[Double]]) -> [[Double]]? {
    
    let functionName = "applyConvolution(array:columns:rows:kernel:)"
    let issueText = "Issue in \(functionName) function."
    
    let kernelSize = kernel.count
    let padding = kernelSize / 2
    
    guard validateConvolusionKernel(kernel: kernel,
                                    padding: padding,
                                    issueText: issueText) else { return nil }
    
    guard validateConvolusionArray(array: array,
                                   columns: columns,
                                   rows: rows,
                                   padding: padding,
                                   issueText: issueText) else { return nil }
    
    var convolvedArray = [[Double]](repeating: [Double](repeating: Double.zero, count: columns),
                                    count: rows)
    
    for row in 0..<rows {
        for column in 0..<columns {
            var arrayValue = 0.0
            
            for i in (row)..<(row + kernelSize) {
                let kernelRow = i - row
                for j in (column)..<(column + kernelSize) {
                    let kernelColumn = j - column
                    arrayValue += array[i][j] * kernel[kernelRow][kernelColumn]
                }
            }
            
            convolvedArray[row][column] = arrayValue
        }
    }
    
    return convolvedArray
}

func getMagnitudeOdd(array: [[Double]],
                     columns: Int,
                     rows: Int,
                     xKernel: [[Double]],
                     yKernel: [[Double]]) -> [[Double]]? {
    
    let functionName = "getMagnitudeOdd(array:columns:rows:xKernel:yKernel)"
    let issueText = "Issue in \(functionName) function."
    
    let kernelSize = xKernel.count
    let padding = kernelSize / 2
    
    guard validateConvolusionKernel(kernel: xKernel,
                                    padding: padding,
                                    issueText: issueText) else { return nil }
    
    guard validateConvolusionKernel(kernel: yKernel,
                                    padding: padding,
                                    issueText: issueText) else { return nil }
    
    guard validateConvolusionArray(array: array,
                                   columns: columns,
                                   rows: rows,
                                   padding: padding,
                                   issueText: issueText) else { return nil }
    
    var minMagnitude =  1_000_000_000.0
    var maxMagnitude = -1_000_000_000.0
    
    var magnitude = [[Double]](repeating: [Double](repeating: Double.zero, count: columns),
                               count: rows)
    for row in 0..<rows {
        for column in 0..<columns {
            var xGradient = 0.0
            var yGradient = 0.0
            
            for i in (row)..<(row + kernelSize) {
                let kernelRow = i - row
                for j in (column)..<(column + kernelSize) {
                    let kernelColumn = j - column
                    
                    xGradient += array[i][j] * xKernel[kernelRow][kernelColumn]
                    yGradient += array[i][j] * yKernel[kernelRow][kernelColumn]
                }
            }
            
            let cellMagnitude = sqrt(pow(xGradient, 2) + pow(yGradient, 2))
            
            if cellMagnitude > maxMagnitude { maxMagnitude = cellMagnitude }
            if cellMagnitude < minMagnitude { minMagnitude = cellMagnitude }
            
            magnitude[row][column] = cellMagnitude
        }
    }
    
    let magnitudeSpread = maxMagnitude - minMagnitude
    for row in 0..<rows {
        for column in 0..<columns {
            magnitude[row][column] = 255 * (magnitude[row][column] - minMagnitude) / magnitudeSpread
        }
    }
    
    return magnitude
}

func getRobertsCrossMagnitude(array: [[Double]],
                              columns: Int,
                              rows: Int) -> [[Double]]? {
    let functionName = "getRobertsCrossMagnitude(array:columns:rows:)"
    let issueText = "Issue in \(functionName) function."
    
    guard validateConvolusionArray(array: array,
                                   columns: columns,
                                   rows: rows,
                                   padding: 1,
                                   issueText: issueText) else { return nil }
    
    var minMagnitude =  1_000_000_000.0
    var maxMagnitude = -1_000_000_000.0
    
    var magnitude = [[Double]](repeating: [Double](repeating: Double.zero, count: columns),
                               count: rows)
    for row in 1...rows {
        for column in 1...columns {
            let xGradient = array[row][column] - array[row + 1][column + 1]
            let yGradient = array[row][column + 1] - array[row + 1][column]
            
            let cellMagnitude = sqrt(pow(xGradient, 2) + pow(yGradient, 2))
            
            if cellMagnitude > maxMagnitude { maxMagnitude = cellMagnitude }
            if cellMagnitude < minMagnitude { minMagnitude = cellMagnitude }
            
            magnitude[row - 1][column - 1] = cellMagnitude
        }
    }
    
    let magnitudeSpread = maxMagnitude - minMagnitude
    for row in 0..<rows {
        for column in 0..<columns {
            magnitude[row][column] = 255 * (magnitude[row][column] - minMagnitude) / magnitudeSpread
        }
    }
    
    return magnitude
}
