//
//  Filter.swift
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/23/22.
//

import Foundation
import SwiftUI

protocol FilterViewModelDelegate: AnyObject {
    func apply(filter: Filter)
}

class FilterViewModel: FilterControlViewDelegate {
    let title: String
    private let type: FilterType
    let controlViewModels: [FilterControlViewModel]
    
    weak var delegate: FilterViewModelDelegate?
    
    init(type: FilterType, delegate: FilterViewModelDelegate? = nil) {
        title = type.title
        self.type = type
        controlViewModels = type.controls.map { FilterControlViewModel(control: $0) }
        self.delegate = delegate
    }
    
    func toFilter() -> Filter {
        Filter(type: type, controls: controlViewModels.map { $0.toControl() })
    }
    
    func controlValueDidChange() {
        delegate?.apply(filter: toFilter())
    }
}




