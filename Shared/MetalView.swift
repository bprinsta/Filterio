//
//  MetalView.swift
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/23/22.
//

import SwiftUI
import MetalKit

struct MetalView: View {
    @State private var renderer: Renderer?
    @State private var metalView: MTKView = MTKView()

    @State private var selectedImage = DefaultImages.nature
    
    @State private var selectedFilterType: FilterType = .brightness
    @State private var selectedFilterViewModel = FilterViewModel(type: .brightness)
    
    var image: NSImage {
        print(NSImage(byReferencing: selectedImage.url).size)
        return NSImage(byReferencing: selectedImage.url)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0){
            Spacer(minLength: 0)
            
            // TODO: resize / scale / resample metal view based on size of the window
            MetalViewRepresentable(
                renderer: renderer,
                metalView: $metalView)
                .onAppear {
                    renderer = Renderer(metalView: metalView, filter: selectedFilterViewModel.toFilter(), imageURL: selectedImage.url)
                    selectedFilterViewModel.delegate = renderer
                }
                .frame(width: selectedImage.width, height: selectedImage.height, alignment: .topLeading)
                .padding()
            
            Spacer(minLength: 0)
            
            Divider()
            
            controlPanel
                .frame(width: 250)
                .padding()
        }
        .toolbar {
            Button {
                print("supposedly add image")
            } label: {
                Image(systemName: "plus")
            }
            
            Button {
                print("supposedly share image")
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .onChange(of: selectedFilterType) { newValue in
            // TODO: fix bug of apply being called twice when changing filter for the first time
            selectedFilterViewModel = FilterViewModel(type: newValue, delegate: renderer)
            renderer?.apply(filter: selectedFilterViewModel.toFilter())
        }
        .onChange(of: selectedImage) { _ in
            renderer?.updateImage(url: selectedImage.url)
        }
    }
    
    var controlPanel: some View {
        Form {
            imagePicker
            filterPicker
            filterControls
            resetButton
        }
    }
    
    var imagePicker: some View {
        Picker("Image", selection: $selectedImage) {
            ForEach(DefaultImages.allCases, id: \.self) {
                Text($0.name)
            }
        }
        .pickerStyle(.menu)
    }
    
    var filterPicker: some View {
        Picker("Filter", selection: $selectedFilterType) {
            ForEach(FilterType.allCases, id: \.self) {
                Text($0.title)
            }
        }
        .pickerStyle(.menu)
    }
    
    var filterControls: some View {
        ForEach(selectedFilterViewModel.controlViewModels) { viewModel in
            FilterControlView(viewModel: viewModel, delegate: selectedFilterViewModel)
        }
    }
    
    @ViewBuilder
    var resetButton: some View {
        if !selectedFilterViewModel.controlViewModels.isEmpty {
            Button(role: .destructive) {
                selectedFilterViewModel.reset()
            } label: {
                Text("Reset")
            }
        } else {
            EmptyView()
        }
    }
}

struct MetalView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MetalView()
      Text("Metal View")
    }
  }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
    let renderer: Renderer?
    @Binding var metalView: MTKView
    
#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        configureMetalView(metalView)
        return metalView
    }
    
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        configureMetalView(metalView)
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        updateMetalView()
    }
#endif
    
    func configureMetalView(_ metalView: MTKView) {
        metalView.preferredFramesPerSecond = 60
        metalView.framebufferOnly = false
        metalView.drawableSize = metalView.frame.size
        metalView.enableSetNeedsDisplay = true
        metalView.autoResizeDrawable = true
        metalView.isPaused = false
        metalView.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    func updateMetalView() {}
}
