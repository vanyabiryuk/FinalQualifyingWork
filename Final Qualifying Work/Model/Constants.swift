//
//  Constants.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 11.05.2022.
//

import Foundation

struct K {
    static let imageSelectionToResultSegue = "GoToResult"
    static let sobelXKernel: [[Double]] = [[ 1,  0, -1],
                                           [ 2,  0, -2],
                                           [ 1,  0, -1]]
    
    static let sobelYKernel: [[Double]] = [[ 1,  2,  1],
                                           [ 0,  0,  0],
                                           [-1, -2, -1]]
}
