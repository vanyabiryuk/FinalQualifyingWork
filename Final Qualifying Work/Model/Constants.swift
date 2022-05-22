//
//  Constants.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 11.05.2022.
//

import Foundation
import UIKit

struct K {
    static let imageSelectionToResultSegue = "GoToResult"
    static let imageSelectionToSettingsSegue = "GoToSettings"
    
    // MARK: Kernels of Sobel's method
    
    static let sobelXKernel: [[Double]] = [[ -1,  0,  1],
                                           [ -2,  0,  2],
                                           [ -1,  0,  1]]
    
    static let sobelYKernel: [[Double]] = [[  1,  2,  1],
                                           [  0,  0,  0],
                                           [ -1, -2, -1]]
    
    // MARK: Kernels of Scharr's method
    
    static let scharrXKernel: [[Double]] = [[ -3,   0,   3],
                                            [-10,   0,  10],
                                            [ -3,   0,   3]]
    
    static let scharrYKernel: [[Double]] = [[  3,  10,   3],
                                            [  0,   0,   0],
                                            [ -3, -10,  -3]]
    
    // MARK: Kernles of Prewitt's method
    
    static let prewittXKernel: [[Double]] = [[-1,  0,  1],
                                             [-1,  0,  1],
                                             [-1,  0,  1]]
    
    static let prewittYKernel: [[Double]] = [[ 1,  1,  1],
                                             [ 0,  0,  0],
                                             [-1, -1, -1]]
    
    // MARK: Canny operator's constants
    
    static var gaussian5x5: [[Double]] {
        get {
            var matrix: [[Double]] = [[ 2,  4,  5,  4,  2],
                                      [ 4,  9, 12,  9,  4],
                                      [ 5, 12, 15, 12,  5],
                                      [ 4,  9, 12,  9,  4],
                                      [ 2,  4,  5,  4,  2]]
            for i in 0...4 {
                for j in 0...4 {
                    matrix[i][j] /= 159.0
                }
            }
            
            return matrix
        }
    }
    
    static let tan22_5deg = 0.41421356237
    static let tan67_5deg = 2.41421356237
}
