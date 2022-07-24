//
//  FilterControlView.swift
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/24/22.
//

import SwiftUI

protocol FilterControlViewDelegate: AnyObject {
    func controlValueDidChange()
}

class FilterControlViewModel: ObservableObject, Identifiable {
    var id: String { controlName }
    @Published var value: Float
    let initialValue: Float
    let minimumTitle: String
    let maximumTitle: String
    let controlName: String
    let valueRange: ClosedRange<Float>
    private let valueProcessor: (Float) -> (Float)
    
    init(control: FilterControl) {
        value = control.value
        initialValue = control.value
        valueRange = control.domain
        minimumTitle = String(format: "%.2f", control.domain.lowerBound)
        maximumTitle = String(format: "%.2f", control.domain.upperBound)
        controlName = control.name
        valueProcessor = control.valueProcessor
    }
    
    func toControl() -> FilterControl {
        FilterControl(name: controlName, domain: valueRange, value: valueProcessor(value))
    }
    
    func reset() {
        value = initialValue
    }
}

struct FilterControlView: View {
    @ObservedObject var viewModel: FilterControlViewModel
    weak var delegate: FilterControlViewDelegate?
    
    var body: some View {
        Slider(value: $viewModel.value, in: viewModel.valueRange) {
            Text(viewModel.controlName)
        } minimumValueLabel: {
            Text(viewModel.minimumTitle)
        } maximumValueLabel: {
            Text(viewModel.maximumTitle)
        }
        .onChange(of: viewModel.value) { newValue in
            delegate?.controlValueDidChange()
        }
    }
}
