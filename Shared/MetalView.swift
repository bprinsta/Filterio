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
    @State private var image: NSImage
    
    @State private var selectedFilterType: FilterType = .brightness
    @State private var selectedFilterViewModel: FilterViewModel
    
    init() {
        let image = NSImage(byReferencing: Bundle.main.url(forResource: "nature", withExtension: "jpg")!)
        self.image = image
        selectedFilterViewModel = FilterViewModel(type: .brightness)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0){
            Spacer(minLength: 0)
            
            MetalViewRepresentable(
                renderer: renderer,
                metalView: $metalView)
                .onAppear {
                    renderer = Renderer(metalView: metalView, filter: selectedFilterViewModel.toFilter())
                    selectedFilterViewModel.delegate = renderer
                }
                .frame(width: image.size.width / 2, height: image.size.height / 2, alignment: .topLeading)
                .padding()
            
            Spacer(minLength: 0)
            
            Divider()
            
            filterController
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
    }
    
    var filterController: some View {
        VStack(alignment: .leading, spacing:  16) {
            Form(content: {
                Section {
                    Picker("Filter", selection: $selectedFilterType) {
                        ForEach(FilterType.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                ForEach(selectedFilterViewModel.controlViewModels) { viewModel in
                    FilterControlView(viewModel: viewModel, delegate: selectedFilterViewModel)
                }
            })
            
            if !selectedFilterViewModel.controlViewModels.isEmpty {
                Button(role: .destructive) {
                    selectedFilterViewModel.reset()
                } label: {
                    Text("Reset")
                }
            }
            
            Spacer()
            
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
    }
    
    func updateMetalView() {}
}
