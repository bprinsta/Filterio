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
    var pipelineState: MTLComputePipelineState!
    
    var image: MTLTexture!
    
    init(metalView: MTKView) {
        metalView.framebufferOnly = false

        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
                  fatalError("GPU not available")
              }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        let textureLoader = MTKTextureLoader(device: device)
        let url = Bundle.main.url(forResource: "nature", withExtension: "jpg")!

        do {
            pipelineState = try Renderer.buildComputePipelineWith(device: device, metalKitView: metalView)
            image = try textureLoader.newTexture(URL: url, options: [:])

        } catch {
            fatalError("Unable to compile render pipeline state: \(error)")
        }
        
        super.init()
        metalView.clearColor = MTLClearColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        metalView.delegate = self
    }
    
    /// Create custom rendering pipeline, which loads shaders using `device`, out puts to the format of `metalKitView`
    static func buildComputePipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLComputePipelineState {
        let pipelineDescriptor = MTLComputePipelineDescriptor()
        
        // Create shader function library
        Self.library = device.makeDefaultLibrary()
        
        pipelineDescriptor.computeFunction = library.makeFunction(name: "compute")
        
        return try device.makeComputePipelineState(descriptor: pipelineDescriptor, options: [], reflection: nil)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let drawable = view.currentDrawable else {
            return
        }
        
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(image, index: 0)
        commandEncoder.setTexture(drawable.texture, index: 1)
        
        var width = pipelineState.threadExecutionWidth
        var height = pipelineState.maxTotalThreadsPerThreadgroup / width
        
        let threadsPerGroup = MTLSizeMake(width, height, 1)
        width = Int(view.drawableSize.width)
        height = Int(view.drawableSize.height)
        
        let threadsPerGrid = MTLSizeMake(width, height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
}
