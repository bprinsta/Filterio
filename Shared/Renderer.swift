//
//  Renderer.swift
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/23/22.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var pipelineState: MTLRenderPipelineState!
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
                  fatalError("GPU not available")
              }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        do {
            pipelineState = try Renderer.buildRenderPipelineWith(device: device, metalKitView: metalView)
        } catch {
            fatalError("Unable to compile render pipeline state: \(error)")
        }
        
        super.init()
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
    }
    
    /// Create custom rendering pipeline, which loads shaders using `device`, out puts to the format of `metalKitView`
    static func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        // Create shader function library
        Self.library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        
    }
    
    
}
