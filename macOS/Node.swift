import MetalKit

final class Node {
    weak var parent: Node?
    var transform = matrix_identity_float4x4
    let mesh: MTKMesh
    let texture: MTLTexture
    
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
