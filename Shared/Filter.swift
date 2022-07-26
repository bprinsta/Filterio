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
    case vignette
    case grayscale
    case saturation
    case rgbToGbr
    case pixelated
    
    var title: String {
        switch self {
        case .brightness: return "Brightness"
        case .contrast: return "Contrast"
        case .gamma: return "Gamma"
        case .vignette: return "Vignette"
        case .grayscale: return "Grayscale"
        case .saturation: return "Saturation"
        case .rgbToGbr: return "RGB to GBR"
        case .pixelated: return "Pixelated"
        }
    }
    
    var controls: [FilterControl] {
        switch self {
        case .brightness: return [FilterControl(name: "brightness", domain: -1...1, value: 0)]
        case .contrast: return [FilterControl(name: "contrast", domain: -1...1, value: 0)]
        case .gamma: return [FilterControl(name: "γ", domain: -1...1, value: 0, valueProcessor: { exp($0) })]
        case .vignette: return [FilterControl(name: "inner radius", domain: 0...1, value: 1), FilterControl(name: "outer radius", domain: 0...1, value: 1)]
        case .grayscale: return []
        case .saturation: return [FilterControl(name: "saturation", domain: -1...1, value: 0)]
        case .rgbToGbr: return []
        case .pixelated: return []
        }
    }
    
    var shaderName: String {
        switch self {
        case .brightness: return "brightness"
        case .contrast: return "contrast"
        case .gamma: return "gamma"
        case .vignette: return "vignette"
        case .grayscale: return "grayscale"
        case .saturation: return "saturation"
        case .rgbToGbr: return "rgb_to_gbr"
        case .pixelated: return "pixelate"
        }
    }
}
