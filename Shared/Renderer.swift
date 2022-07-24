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
    
    var brightnessPipeline: MTLComputePipelineState!
    var rgbToGbrPipeline: MTLComputePipelineState!
    var grayscalePipeline: MTLComputePipelineState!
    var pixelatePipeline: MTLComputePipelineState!
    
    var selectedFilter: Filter
    
    var image: MTLTexture!
    
    init(metalView: MTKView, filter: Filter) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
                  fatalError("GPU not available")
              }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        selectedFilter = filter
        
        let textureLoader = MTKTextureLoader(device: device)
        let url = Bundle.main.url(forResource: "nature", withExtension: "jpg")!
        let nsImage = NSImage(byReferencing: url)
        print(nsImage.size.width)
        print(nsImage.size.height)

        do {
            rgbToGbrPipeline = try Renderer.buildComputePipelineWithFunction(name: "rgb_to_gbr", with: device, metalKitView: metalView)
            brightnessPipeline = try Renderer.buildComputePipelineWithFunction(name: "brightness", with: device, metalKitView: metalView)
            grayscalePipeline = try Renderer.buildComputePipelineWithFunction(name: "grayscale", with: device, metalKitView: metalView)
            pixelatePipeline = try Renderer.buildComputePipelineWithFunction(name: "pixelate", with: device, metalKitView: metalView)
            image = try textureLoader.newTexture(URL: url, options: [:])
        } catch {
            fatalError("Unable to compile render pipeline state: \(error)")
        }
        
        pipelineState = brightnessPipeline
        
        super.init()
        metalView.clearColor = MTLClearColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        metalView.delegate = self
    }
    
    /// Switch the currently active pipeline state to use a given filter
    func apply(filter: Filter) {
        selectedFilter = filter
        switch filter.type {
        case .brightness: pipelineState = brightnessPipeline
        case .rgbToGbr: pipelineState = rgbToGbrPipeline
        case .grayscale: pipelineState = grayscalePipeline
        case .pixelated: pipelineState = pixelatePipeline
        }
    }
    
    /// Create custom rendering pipeline, which loads shaders using `device`, out puts to the format of `metalKitView`
    static func buildComputePipelineWithFunction(name: String, with device: MTLDevice, metalKitView: MTKView) throws -> MTLComputePipelineState {
        let pipelineDescriptor = MTLComputePipelineDescriptor()
        Self.library = device.makeDefaultLibrary()
        pipelineDescriptor.computeFunction = library.makeFunction(name: name)
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
        
        setFilterInputs(commandEncoder: commandEncoder)
        
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
    
    func setFilterInputs(commandEncoder: MTLComputeCommandEncoder) {
        for (index, control) in selectedFilter.controls.enumerated() {
            commandEncoder.setBytes(&control.value, length: MemoryLayout<Float>.stride, index: 10 + index)
        }
    }
}
