import MetalKit

final class Miew: MTKView {
    private var time = TimeInterval()
    private var count = Int()
    private let queue: MTLCommandQueue
    private let state: MTLRenderPipelineState
    private let mesh: MTKMesh
    private let constants: MTLBuffer
    private let semaphore = DispatchSemaphore(value: 3)
    
    required init(coder: NSCoder) { fatalError() }
    init?(device: MTLDevice) {
        guard
            let library = device.makeDefaultLibrary(),
            let constants = device.makeBuffer(length: MemoryLayout<SIMD2<Float>>.size * 16 * 3),
            let vertex = library.makeFunction(name: "vertex_main"),
            let fragment = library.makeFunction(name: "fragment_main"),
            let mesh = try? MTKMesh(mesh: .init(sphereWithExtent: .init(x: 0.4, y: 0.4, z: 0.4),
                                                segments: [100, 100],
                                                inwardNormals: false,
                                                geometryType: .triangles,
                                                allocator: MTKMeshBufferAllocator(device: device)),
                                    device: device)
        else { return nil }
        
        mesh.vertexDescriptor.attributes.removeObject(at: 2)
        
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
        self.constants = constants
        
        
        super.init(frame: .init(origin: .zero, size: .init(width: 800, height: 800)), device: device)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        semaphore.wait()
        tick()
        
        guard
            let buffer = queue.makeCommandBuffer(),
            let pass = currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: pass),
            let submesh = mesh.submeshes.first,
            let drawable = currentDrawable
        else { return }
        
        encoder.setRenderPipelineState(state)
        encoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
//        encoder.setTriangleFillMode(.fill)

//        var x: float4x4 = .init()
//        var xx = simd_float4x4()
//        var y = MDLMatrix4x4Array()
//        y.f
////        x[0][0] = 8
////        encoder.setVertexBuffer(x, offset: 0, index: 2)
//
//        encoder.setVertexBytes(&x,
//                               length: MemoryLayout<Float>.stride,
//                               index: 2)
//
//
//
//        print(points[0])
        
//        buffer.makeBlitCommandEncoder()
//        // 3
//        let bufferPointer = uniformBuffer.contents()
//        // 4
//        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * 16)
//        // 5
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        
        encoder.setVertexBuffer(constants, offset: (count % 3) * MemoryLayout<SIMD2<Float>>.size * 16, index: 1)
        
        encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                      indexCount: submesh.indexCount,
                                      indexType: submesh.indexType,
                                      indexBuffer: submesh.indexBuffer.buffer,
                                      indexBufferOffset: submesh.indexBuffer.offset)
        encoder.endEncoding()
        buffer.present(drawable)
        
        buffer
            .addCompletedHandler { [weak self] _ in
                self?.count += 1
                self?.semaphore.signal()
            }
        
        buffer.commit()
    }
    
    private func tick() {
        time += 1.0 / .init(preferredFramesPerSecond)
        let t = Float(time)
        let pulseRate: Float = 1.5
        let scaleFactor = 1.0 + 0.5 * cos(pulseRate * t)
        let scale = SIMD2<Float>(scaleFactor, scaleFactor)
        let scaleMatrix = simd_float4x4(scale2D: scale)
        
        let rotationRate: Float = 2.5
        let rotationAngle = rotationRate * t
        let rotationMatrix = simd_float4x4(rotateZ: rotationAngle)
        
        let orbitalRadius: Float = 200
        let translation = orbitalRadius * SIMD2<Float>(cos(t), sin(t))
        let translationMatrix = simd_float4x4(translate2D: translation)
        
        let modelMatrix = translationMatrix * rotationMatrix * scaleMatrix
        
        let aspectRatio = Float(drawableSize.width / drawableSize.height)
        let canvasWidth: Float = 800
        let canvasHeight = canvasWidth / aspectRatio
        let projectionMatrix = simd_float4x4(orthographicProjectionWithLeft: -canvasWidth / 2,
                                             top: canvasHeight / 2,
                                             right: canvasWidth / 2,
                                             bottom: -canvasHeight / 2,
                                             near: 0.0,
                                             far: 1.0)
        
        var transformMatrix = projectionMatrix * modelMatrix
        let contents = constants.contents().advanced(by: (count % 3) * MemoryLayout<SIMD2<Float>>.size * 16)
        contents.copyMemory(from: &transformMatrix, byteCount: MemoryLayout<SIMD2<Float>>.size)
    }
}



extension simd_float4x4 {
    init(scale2D s: SIMD2<Float>) {
        self.init(SIMD4<Float>(s.x,   0, 0, 0),
                  SIMD4<Float>(  0, s.y, 0, 0),
                  SIMD4<Float>(  0,   0, 1, 0),
                  SIMD4<Float>(  0,   0, 0, 1))
    }
    
    init(rotateZ zRadians: Float) {
        let s = sin(zRadians)
        let c = cos(zRadians)
        self.init(SIMD4<Float>( c, s, 0, 0),
                  SIMD4<Float>(-s, c, 0, 0),
                  SIMD4<Float>( 0, 0, 1, 0),
                  SIMD4<Float>( 0, 0, 0, 1))
    }
    init(translate2D t: SIMD2<Float>) {
        self.init(SIMD4<Float>(  1,   0, 0, 0),
                  SIMD4<Float>(  0,   1, 0, 0),
                  SIMD4<Float>(  0,   0, 1, 0),
                  SIMD4<Float>(t.x, t.y, 0, 1))
    }
    
    
    init(orthographicProjectionWithLeft left: Float, top: Float,
             right: Float, bottom: Float, near: Float, far: Float)
        {
            let sx = 2 / (right - left)
            let sy = 2 / (top - bottom)
            let sz = 1 / (near - far)
            let tx = (left + right) / (left - right)
            let ty = (top + bottom) / (bottom - top)
            let tz = near / (near - far)
            self.init(SIMD4<Float>(sx,  0,  0, 0),
                      SIMD4<Float>( 0, sy,  0, 0),
                      SIMD4<Float>( 0,  0, sz, 0),
                      SIMD4<Float>(tx, ty, tz, 1))
        }
}
