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
    var textureLoader: MTKTextureLoader
    var filterPipelines: [FilterType: MTLComputePipelineState]
    
    var selectedFilter: Filter
    
    var image: MTLTexture!
    
    init(metalView: MTKView, filter: Filter, imageURL: URL) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
                  fatalError("GPU not available")
              }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        selectedFilter = filter
        
        textureLoader = MTKTextureLoader(device: device)

        do {
            filterPipelines = [FilterType: MTLComputePipelineState]()
            for type in FilterType.allCases {
                filterPipelines[type] = try Renderer.buildComputePipelineWithFunction(name: type.shaderName, with: device, metalKitView: metalView)
            }
            image = try textureLoader.newTexture(URL: imageURL, options: [:])
        } catch {
            fatalError("Unable to compile render pipeline state: \(error)")
        }
        
        super.init()
        apply(filter: selectedFilter)
        metalView.clearColor = MTLClearColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        metalView.delegate = self
    }
    
    /// Switch the currently active pipeline state to use a given filter
    func apply(filter: Filter) {
        selectedFilter = filter
        pipelineState = filterPipelines[filter.type]
    }
    
    func updateImage(url: URL) {
        do {
            image = try textureLoader.newTexture(URL: url, options: [:])
        } catch {
            fatalError("Unable to switch image: \(error)")
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
        
        // TODO: Refactor allow multiple pipelines to be applied simultaneously, with stack-like behavior
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
            var value = control.value
            commandEncoder.setBytes(&value, length: MemoryLayout<Float>.stride, index: 10 + index)
        }
    }
}

extension Renderer: FilterViewModelDelegate {}
