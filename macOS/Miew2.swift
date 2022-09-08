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
        
        let options: [MTKTextureLoader.Option : Any] = [
            .textureUsage : MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode : MTLStorageMode.private.rawValue]
        
        guard
            let library = device.makeDefaultLibrary(),
            let constants = device.makeBuffer(length: bufferSize * 3, options: .storageModeShared),
            let vertex = library.makeFunction(name: "vertex_main"),
            let fragment = library.makeFunction(name: "fragment_main"),
            let glowMesh = try? MTKMesh(mesh:
                    .init(planeWithExtent: SIMD3<Float>(1.05, 1.05, 0.0),
                          segments: SIMD2<UInt32>(1, 1),
                          geometryType: .triangles,
                          allocator: bufferAllocator),
                                        device: device),
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
}
