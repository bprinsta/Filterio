//
//  Filter.swift
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/23/22.
//

import Foundation
import SwiftUI

class Filter: ObservableObject, Hashable {
    
    // MARK: Helper Types
    
    enum FilterType: CaseIterable {
        case brightness
        case contrast
        case grayscale
        case rgbToGbr
        case pixelated
        
        var title: String {
            switch self {
            case .brightness: return "Brightness"
            case .contrast: return "Contrast"
            case .grayscale: return "Grayscale"
            case .rgbToGbr: return "RGB to GBR"
            case .pixelated: return "Pixelated"
            }
        }
        
        var controls: [Control] {
            switch self {
            case .brightness: return [Control(name: "Ratio", range: -1...1, initialValue: 0)]
            case .contrast: return [Control(name: "Ratio", range: -1...1, initialValue: 0)]
            case .grayscale: return []
            case .rgbToGbr: return []
            case .pixelated: return []
            }
        }
    }
    
    class Control: Identifiable, Hashable, ObservableObject {
        var id: String { name }
        let name: String
        var range: ClosedRange<Float>
        @Published var value: Float
        
        init(name: String, range: ClosedRange<Float>, initialValue: Float) {
            self.name = name
            self.range = range
            self.value = initialValue
        }
        
        static func == (lhs: Control, rhs: Control) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
    }
    
    // MARK: Properties
    
    static let allTypes = FilterType.allCases.map { Filter(type: $0) }
    
    let type: FilterType
    
    @Published var controls: [Control]
    
    init(type: FilterType) {
        self.type = type
        self.controls = type.controls
    }
        
    static func == (lhs: Filter, rhs: Filter) -> Bool { lhs.type == rhs.type }
    
    func hash(into hasher: inout Hasher) { hasher.combine(type) }
}




