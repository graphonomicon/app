import MetalKit

extension MTLDevice {
    func glow(bufferAllocator: MTKMeshBufferAllocator,
              textureLoader: MTKTextureLoader,
              textureOptions: [MTKTextureLoader.Option : Any]) -> Node? {
        
        let plane = MDLMesh(planeWithExtent: SIMD3<Float>(1.05, 1.05, 0),
                            segments: SIMD2<UInt32>(1, 1),
                            geometryType: .triangles,
                            allocator: bufferAllocator)
        
        guard
            let mesh = try? MTKMesh(mesh: plane, device: self),
            let texture = try? textureLoader.newTexture(name: "Glow", scaleFactor: 1, bundle: nil, options: textureOptions)
        else { return nil }
        
        return .init(mesh: mesh, texture: texture)
    }
}
