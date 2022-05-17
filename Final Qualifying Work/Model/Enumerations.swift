//
//  Enumerations.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 17.05.2022.
//

import Foundation

enum Filter: String, CaseIterable {
    case original  = "Original Image"
    case grayscale = "Grayscale Image"
    case sobel     = "Sobel Operator"
    case scharr    = "Scharr Operator"
    case prewitt   = "Prewitt Operator"
    case canny     = "Canny Edge Detector"
    case roberts   = "Roberts Cross Operator"
}

enum Direction {
    case east
    case north_east
    case north
    case north_west
}
