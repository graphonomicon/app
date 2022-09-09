import MetalKit

private let bufferSize = 32_768

final class Miew2: MTKView {
    private weak var glow: Node?
    private var time = TimeInterval()
    private var count = Int()
    private var nodes: [Node]
    private let queue: MTLCommandQueue
    private let state: MTLRenderPipelineState
    private let constants: MTLBuffer
    private let depth: MTLDepthStencilState
    private let semaphore = DispatchSemaphore(value: 3)
    private let sampler: MTLSamplerState
    
    required init(coder: NSCoder) { fatalError() }
    init?(device: MTLDevice) {
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let textureLoader = MTKTextureLoader(device: device)
        
        let scatter = MDLPhysicallyPlausibleScatteringFunction()
        scatter.metallic.floatValue = 0
        scatter.clearcoatGloss.floatValue = 1
        
        let textureOptions: [MTKTextureLoader.Option : Any] = [
            .textureUsage : MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode : MTLStorageMode.private.rawValue]
        
        guard
            let glow = device.glow(bufferAllocator: bufferAllocator,
                                   textureLoader: textureLoader,
                                   textureOptions: textureOptions),
            let library = device.makeDefaultLibrary(),
            let constants = device.makeBuffer(length: bufferSize * 3, options: .storageModeShared),
            let vertex = library.makeFunction(name: "vertex_main"),
            let fragment = library.makeFunction(name: "fragment_main")
        else { return nil }
        
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline.depthAttachmentPixelFormat = .depth32Float
        pipeline.vertexFunction = vertex
        pipeline.fragmentFunction = fragment
        pipeline.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(glow.mesh.vertexDescriptor)
        
        let depth = MTLDepthStencilDescriptor()
        depth.isDepthWriteEnabled = true
        depth.depthCompareFunction = .less
        
        let samplerDescriptor = MTLSamplerDescriptor()
                samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.mipFilter = .nearest
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        
        guard
            let queue = device.makeCommandQueue(),
            let state = try? device.makeRenderPipelineState(descriptor: pipeline),
            let depth = device.makeDepthStencilState(descriptor: depth),
            let sampler = device.makeSamplerState(descriptor: samplerDescriptor)
        else { return nil }
        
        self.queue = queue
        self.state = state
        self.constants = constants
        self.depth = depth
        self.sampler = sampler
        self.glow = glow
        nodes = [glow]
        
        super.init(frame: .init(origin: .zero,
                                size: .init(width: 800, height: 800)),
                   device: device)
        depthStencilPixelFormat = .depth32Float
        clearColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard
            let buffer = queue.makeCommandBuffer(),
            let pass = currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: pass),
            let drawable = currentDrawable
        else { return }
        
        semaphore.wait()
        time += 1 / .init(preferredFramesPerSecond)
        
        encoder.setRenderPipelineState(state)
        encoder.setCullMode(.back)
        encoder.setDepthStencilState(depth)
        
        var frame = simd_float4x4(perspectiveProjectionFoVY: .pi / 3,
                                                     aspectRatio: 1,
                                                     near: 0.01,
                                                     far: 100)
        
        var index = (count % 3) * bufferSize
        var pointer = constants.contents().advanced(by: index)
        pointer.copyMemory(from: &frame, byteCount: MemoryLayout<simd_float4x4>.size)
        encoder.setVertexBuffer(constants, offset: index, index: 2)
        index += MemoryLayout<simd_float4x4>.size
        
        glow?.transform = frame.inverse
        
        nodes
            .forEach { node in
                guard let submesh = node.mesh.submeshes.first else { return }
                
                var transform = node.worldTransform
                pointer = constants.contents().advanced(by: index)
                pointer.copyMemory(from: &transform, byteCount: MemoryLayout<simd_float4x4>.size)
                encoder.setVertexBuffer(constants, offset: index, index: 1)
                index += MemoryLayout<simd_float4x4>.size
                
                encoder.setVertexBuffer(node.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
                encoder.setFragmentTexture(node.texture, index: 0)
                encoder.setFragmentSamplerState(sampler, index: 0)
                
                encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                              indexCount: submesh.indexCount,
                                              indexType: submesh.indexType,
                                              indexBuffer: submesh.indexBuffer.buffer,
                                              indexBufferOffset: submesh.indexBuffer.offset)
            }

        encoder.endEncoding()
        buffer.present(drawable)
        
        buffer
            .addCompletedHandler { [weak self] _ in
                self?.semaphore.signal()
            }
        
        buffer.commit()
        count += 1
    }
}
