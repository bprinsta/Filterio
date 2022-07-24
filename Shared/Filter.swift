//
//  Filter.swift
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/24/22.
//

import Foundation

struct Filter {
    let type: FilterType
    let controls: [FilterControl]
}

struct FilterControl {
    let name: String
    let domain: ClosedRange<Float>
    var value: Float
    
    // processing to convert input value to appropriate value needed in kernel. We use this closure to perform computations that would be needlessly repeated on the gpu
    var valueProcessor: (Float) -> (Float) = { $0 }
}

enum FilterType: CaseIterable {
    case brightness
    case contrast
    case gamma
    case grayscale
    case rgbToGbr
    case pixelated
    
    var title: String {
        switch self {
        case .brightness: return "Brightness"
        case .contrast: return "Contrast"
        case .gamma: return "Gamma"
        case .grayscale: return "Grayscale"
        case .rgbToGbr: return "RGB to GBR"
        case .pixelated: return "Pixelated"
        }
    }
    
    var controls: [FilterControl] {
        switch self {
        case .brightness: return [FilterControl(name: "Ratio", domain: -1...1, value: 0)]
        case .contrast: return [FilterControl(name: "Ratio", domain: -1...1, value: 0)]
        case .gamma: return [FilterControl(name: "γ", domain: -1...1, value: 0, valueProcessor: { exp($0) })]
        case .grayscale: return []
        case .rgbToGbr: return []
        case .pixelated: return []
        }
    }
}
