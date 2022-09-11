import MetalKit

final class Node {
    weak var parent: Node?
    var transform = matrix_identity_float4x4
    let mesh: MTKMesh
    let texture: MTLTexture
    
    class func sphere(device: MTLDevice,
                      bufferAllocator: MTKMeshBufferAllocator,
                      textureLoader: MTKTextureLoader,
                      textureOptions: [MTKTextureLoader.Option : Any]) -> Self? {
        
        let sphere = MDLMesh.init(sphereWithExtent: .init(x: 1, y: 1, z: 1),
                                  segments: [128, 128],
                                  inwardNormals: false,
                                  geometryType: .triangles,
                                  allocator: bufferAllocator)
        
        guard
            let mesh = try? MTKMesh(mesh: sphere, device: device),
            let texture = try? textureLoader.newTexture(name: "Sphere", scaleFactor: 1, bundle: nil, options: textureOptions)
        else { return nil }
        
        return .init(mesh: mesh, texture: texture)
    }
    
    class func glow(device: MTLDevice,
                    bufferAllocator: MTKMeshBufferAllocator,
                    textureLoader: MTKTextureLoader,
                    textureOptions: [MTKTextureLoader.Option : Any]) -> Self? {
        
        let plane = MDLMesh(planeWithExtent: SIMD3<Float>(1.13, 1.13, 0),
                            segments: SIMD2<UInt32>(1, 1),
                            geometryType: .triangles,
                            allocator: bufferAllocator)
        
        guard
            let mesh = try? MTKMesh(mesh: plane, device: device),
            let texture = try? textureLoader.newTexture(name: "Glow", scaleFactor: 1, bundle: nil, options: textureOptions)
        else { return nil }
        
        return .init(mesh: mesh, texture: texture)
    }
    
    var worldTransform: simd_float4x4 {
        parent
            .map {
                $0.worldTransform * transform
            } ?? transform
    }
    
    init(mesh: MTKMesh, texture: MTLTexture) {
        self.mesh = mesh
        self.texture = texture
    }
}
