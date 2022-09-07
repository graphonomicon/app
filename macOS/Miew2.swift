import MetalKit

private let bufferSize = 32_768

final class Miew2: MTKView {
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
            let sphereMesh = try? MTKMesh(mesh:
                    .init(sphereWithExtent: .init(x: 1, y: 1, z: 1),
                          segments: [128, 128],
                          inwardNormals: false,
                          geometryType: .triangles,
                          allocator: bufferAllocator),
                                          device: device)
        else { return nil }
        
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline.depthAttachmentPixelFormat = .depth32Float
        pipeline.vertexFunction = vertex
        pipeline.fragmentFunction = fragment
        pipeline.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(sphereMesh.vertexDescriptor)
        
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
    }
}
