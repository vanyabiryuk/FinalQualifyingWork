//
//  DataProcessing.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 12.05.2022.
//

import Foundation

func newPaddedMatrix(_ data: UnsafeMutableBufferPointer<UInt8>,
                     _ width: Int,
                     _ height: Int,
                     _ padding: Int) -> [[Double]] {
    var doubleDataArray = [[Double]](repeating: [Double](repeating: Double.zero, count: width + 2 * padding),
                                     count: height + 2 * padding)
    
    for row in 0..<height {
        for column in 0..<width {
            let pixelIndex = row * width + column
            doubleDataArray[row + padding][column + padding] = Double(data[pixelIndex])
        }
    }
    
    return doubleDataArray
}

func calculateMagnitude(_ matrix: [[Double]],
                        _ width: Int,
                        _ height: Int,
                        _ xKernel: [[Double]],
                        _ yKernel: [[Double]]) -> [[Double]]? {
    
    let kernelSize = xKernel.count
    
    // TODO: Вывести проблему в консоль
    guard yKernel.count == kernelSize else { return nil }
    guard kernelSize > 0 && kernelSize % 2 == 1 else { return nil }
    
    for kernelRow in xKernel {
        guard kernelRow.count == kernelSize else { return nil }
    }
    
    for kernelRow in yKernel {
        guard kernelRow.count == kernelSize else { return nil }
    }
    
    let padding = kernelSize / 2
    guard matrix.count == height + 2 * padding else { return nil }
    for matrixRow in matrix {
        guard matrixRow.count == width + 2 * padding else { return nil }
    }
    
    var minMagnitude =  1_000_000_000.0
    var maxMagnitude = -1_000_000_000.0
    var magnitude = [[Double]](repeating: [Double](repeating: Double.zero,
                                                   count: width),
                               count: height)
    
    for row in 0..<height {
        for column in 0..<width {
            var gradientX: Double = 0
            var gradientY: Double = 0
            for i in (row)...(row + 2 * padding) {
                for j in (column)...(column + 2 * padding) {
                    gradientX += matrix[i][j] * xKernel[i - row][j - column]
                    gradientY += matrix[i][j] * yKernel[i - row][j - column]
                }
            }
            let cellMagnitude = sqrt(pow(gradientX, 2) + pow(gradientY, 2))
            
            if cellMagnitude > maxMagnitude { maxMagnitude = cellMagnitude }
            if cellMagnitude < minMagnitude { minMagnitude = cellMagnitude }
            
            magnitude[row][column] = cellMagnitude
        }
    }
    
    let magnitudeSpread = maxMagnitude - minMagnitude
    
    for row in 0..<height {
        for column in 0..<width {
            magnitude[row][column] = 255 * (magnitude[row][column] - minMagnitude) / magnitudeSpread
        }
    }
    
    return magnitude
}
