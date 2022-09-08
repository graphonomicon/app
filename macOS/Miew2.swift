import MetalKit

private let bufferSize = 32_768

final class Miew2: MTKView {
    private var time = TimeInterval()
    private var count = Int()
    private let queue: MTLCommandQueue
    private let state: MTLRenderPipelineState
    private let glowMesh: MTKMesh
    private let constants: MTLBuffer
    private let depth: MTLDepthStencilState
    private let semaphore = DispatchSemaphore(value: 3)
    private let sampler: MTLSamplerState
    private let glowTexture: MTLTexture
    
    required init(coder: NSCoder) { fatalError() }
    init?(device: MTLDevice) {
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let textureLoader = MTKTextureLoader(device: device)
        
        let scatter = MDLPhysicallyPlausibleScatteringFunction()
        scatter.metallic.floatValue = 0
        scatter.clearcoatGloss.floatValue = 1
        
        let options: [MTKTextureLoader.Option : Any] = [
            .textureUsage : MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode : MTLStorageMode.private.rawValue]
        
        let glowPlane = MDLMesh(planeWithExtent: SIMD3<Float>(1.05, 1.05, 0),
                              segments: SIMD2<UInt32>(128, 128),
                              geometryType: .triangles,
                              allocator: bufferAllocator)
        
        (glowPlane.submeshes?.firstObject as! MDLSubmesh).material = .init(name: "", scatteringFunction: scatter)
        
        guard
            let library = device.makeDefaultLibrary(),
            let constants = device.makeBuffer(length: bufferSize * 3, options: .storageModeShared),
            let vertex = library.makeFunction(name: "vertex_main"),
            let fragment = library.makeFunction(name: "fragment_main"),
            let glowMesh = try? MTKMesh(mesh: glowPlane, device: device),
            let glowTexture = try? textureLoader.newTexture(name: "Sphere", scaleFactor: 1, bundle: nil, options: options)
        else { return nil }
        
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline.depthAttachmentPixelFormat = .depth32Float
        pipeline.vertexFunction = vertex
        pipeline.fragmentFunction = fragment
        pipeline.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(glowMesh.vertexDescriptor)
        
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
        self.glowMesh = glowMesh
        self.constants = constants
        self.depth = depth
        self.sampler = sampler
        self.glowTexture = glowTexture
        
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
            let glowSubmesh = glowMesh.submeshes.first,
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
        encoder.setFragmentBuffer(constants, offset: index, index: 0)
        
        var glowTransform = simd_float4x4(lookAt: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 0, 0), up: SIMD3<Float>(0, 1, 0))
        
        index += MemoryLayout<simd_float4x4>.size
        pointer = constants.contents().advanced(by: index)
        pointer.copyMemory(from: &glowTransform, byteCount: MemoryLayout<simd_float4x4>.size)
        
        encoder.setVertexBuffer(constants, offset: index, index: 1)
        encoder.setVertexBuffer(glowMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        encoder.setFragmentTexture(glowTexture, index: 0)
        encoder.setFragmentSamplerState(sampler, index: 0)
        
        encoder.drawIndexedPrimitives(type: glowSubmesh.primitiveType,
                                      indexCount: glowSubmesh.indexCount,
                                      indexType: glowSubmesh.indexType,
                                      indexBuffer: glowSubmesh.indexBuffer.buffer,
                                      indexBufferOffset: glowSubmesh.indexBuffer.offset)
        
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
