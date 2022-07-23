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
    @State private var metalView = MTKView()
        
    @State private var selectedFilter = Filter(type: .inverted)
    
    var body: some View {
        VStack(alignment: .leading, spacing:  16) {
            HStack {
                Button("Upload", role: nil) {
                    print("supposedly upload image")
                }
                
                Button("Export", role: nil) {
                    print("supposedly export image")
                }
            }
            
            MetalViewRepresentable(
                renderer: renderer,
                metalView: $metalView)
                .onAppear {
                    renderer = Renderer(metalView: metalView)
                }
                .frame(width: 800, height: 500, alignment: .center)
            
            Form(content: {
                Section {
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(Filter.allTypes, id: \.self) {
                            Text($0.type.title)
                        }
                    }.pickerStyle(.menu)
                }
                
                ForEach($selectedFilter.controls) { $control in
                    Slider(value: $control.value, in: control.range) {
                        Text("\(control.name)")
                    } minimumValueLabel: {
                        Text(String(format: "%.2f", control.range.lowerBound))
                    } maximumValueLabel: {
                        Text(String(format: "%.2f", control.range.upperBound))
                    } onEditingChanged: { editing in
                        print(control.value)
                    }
                }
            })
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
    }
    
    func updateMetalView() {}
}
