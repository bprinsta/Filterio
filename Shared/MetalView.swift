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
    
    var body: some View {
        VStack {
            MetalViewRepresentable(
                renderer: renderer,
                metalView: $metalView)
                .onAppear {
                    renderer = Renderer(metalView: metalView)
                }
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
typealias MyMetalView = NSView
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
typealias MyMetalView = UIView
#endif

struct MetalViewRepresentable: ViewRepresentable {
    let renderer: Renderer?
    @Binding var metalView: MTKView
    
#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        metalView
    }
    
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        updateMetalView()
    }
#endif
    
    func makeMetalView(_ metalView: MyMetalView) {}
    
    func updateMetalView() {}
}
