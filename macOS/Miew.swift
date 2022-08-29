import MetalKit

final class Miew: MTKView {
    private let queue: MTLCommandQueue
    private let state: MTLRenderPipelineState
    private let mesh: MTKMesh
    
    required init(coder: NSCoder) { fatalError() }
    init?(device: MTLDevice) {
        guard
            let library = device.makeDefaultLibrary(),
            let vertex = library.makeFunction(name: "vertex_main"),
            let fragment = library.makeFunction(name: "fragment_main"),
            let mesh = try? MTKMesh(mesh: .init(sphereWithExtent: .init(x: 0.75, y: 0.75, z: 0.75),
                                                segments: [100, 100],
                                                inwardNormals: false,
                                                geometryType: .triangles,
                                                allocator: MTKMeshBufferAllocator(device: device)),
                                    device: device)
        else { return nil }
        
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline.vertexFunction = vertex
        pipeline.fragmentFunction = fragment
        pipeline.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
        guard
            let queue = device.makeCommandQueue(),
            let state = try? device.makeRenderPipelineState(descriptor: pipeline)
        else { return nil }

        self.queue = queue
        self.state = state
        self.mesh = mesh
        
        super.init(frame: .init(origin: .init(x: 0, y: 24), size: .init(width: 800, height: 800)), device: device)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard
            let buffer = queue.makeCommandBuffer(),
            let pass = currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: pass),
            let submesh = mesh.submeshes.first,
            let drawable = currentDrawable
        else { return }
        encoder.setRenderPipelineState(state)
        encoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: submesh.indexCount,
                                      indexType: submesh.indexType,
                                      indexBuffer: submesh.indexBuffer.buffer,
                                      indexBufferOffset: 0)
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }
}
