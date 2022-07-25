//
//  Image.swift
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/25/22.
//

import Foundation

enum DefaultImages: CaseIterable, Equatable {
    case nature
    case beach
    case yellowstone
    
    var url: URL {
        switch self {
        case .nature: return Bundle.main.url(forResource: "nature", withExtension: "jpg")!
        case .beach: return Bundle.main.url(forResource: "beach", withExtension: "jpg")!
        case .yellowstone: return Bundle.main.url(forResource: "yellowstone", withExtension: "jpg")!
        }
    }
    
    var width: CGFloat {
        switch self {
        case .nature, .yellowstone: return 800.0
        case .beach: return 750.0
        }
    }
    
    var height: CGFloat {
        return 500.0
    }
    
    var name: String {
        url.lastPathComponent
    }
}
