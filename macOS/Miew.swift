import MetalKit

private let bufferSize = 32_768

final class Miew: MTKView {
    private var time = TimeInterval()
    private var count = Int()
    private let queue: MTLCommandQueue
    private let state: MTLRenderPipelineState
    private let sphereMesh: MTKMesh
    private let glowMesh: MTKMesh
    private let constants: MTLBuffer
    private let depth: MTLDepthStencilState
    private let semaphore = DispatchSemaphore(value: 3)
    private let sampler: MTLSamplerState
    private let sphereTexture: MTLTexture
    private let glowTexture: MTLTexture
    
    required init(coder: NSCoder) { fatalError() }
    init?(device: MTLDevice) {
        guard
            let library = device.makeDefaultLibrary(),
            let constants = device.makeBuffer(length: bufferSize * 3, options: .storageModeShared),
            let vertex = library.makeFunction(name: "vertex_main"),
            let fragment = library.makeFunction(name: "fragment_main")
            
        else { return nil }
        
        let scatter = MDLPhysicallyPlausibleScatteringFunction()
        scatter.metallic.floatValue = 0
        scatter.clearcoatGloss.floatValue = 1
        
        let mm = MDLMesh.init(sphereWithExtent: .init(x: 1, y: 1, z: 1),
                              segments: [128, 128],
                              inwardNormals: false,
                              geometryType: .triangles,
                              allocator: MTKMeshBufferAllocator(device: device))
        (mm.submeshes?.firstObject as! MDLSubmesh).material = .init(name: "", scatteringFunction: scatter)
        
        
        let sphereMesh = try! MTKMesh(mesh: mm, device: device)
        
//        print(mesh.vertexDescriptor.attributes)
//        mesh.vertexDescriptor.attributes.removeObject(at: 2)
        
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline.depthAttachmentPixelFormat = .depth32Float
        pipeline.vertexFunction = vertex
        pipeline.fragmentFunction = fragment
        pipeline.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(sphereMesh.vertexDescriptor)
        
        let depth = MTLDepthStencilDescriptor()
        depth.isDepthWriteEnabled = true
        depth.depthCompareFunction = .less
        
        guard
            let queue = device.makeCommandQueue(),
            let state = try? device.makeRenderPipelineState(descriptor: pipeline),
            let depth = device.makeDepthStencilState(descriptor: depth)
        else { return nil }

        self.queue = queue
        self.state = state
        self.sphereMesh = sphereMesh
        self.constants = constants
        self.depth = depth
        
        let samplerDescriptor = MTLSamplerDescriptor()
                samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.mipFilter = .nearest
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
                sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        let textureLoader = MTKTextureLoader(device: device)
        
        let options: [MTKTextureLoader.Option : Any] = [
            .textureUsage : MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode : MTLStorageMode.private.rawValue,
//            .origin: MTKTextureLoader.Origin.topLeft.rawValue
        ]
        
//        texture = try! textureLoader.newTexture(cgImage: Self.image, options: options)
        sphereTexture = try! textureLoader.newTexture(name: "Sphere", scaleFactor: 1, bundle: nil, options: options)
        
        
        
        let mdlPlane = MDLMesh(planeWithExtent: SIMD3<Float>(1.05, 1.05, 0.0),
                                       segments: SIMD2<UInt32>(1, 1),
                                       geometryType: .triangles,
                                       allocator: bufferAllocator)
                mdlPlane.vertexDescriptor = mdlVertexDescriptor
                let mtkPlane = try! MTKMesh(mesh: mdlPlane, device: device)

                let atmosphereTextureURL = Bundle.main.url(forResource: "atmosphere", withExtension: "png")!
                let atmosphereTexture = try? textureLoader.newTexture(URL: atmosphereTextureURL, options: textureOptions)
                atmosphereNode = Node(mesh: mtkPlane)
                atmosphereNode.texture = atmosphereTexture
        
        
        
        
        
        
        super.init(frame: .init(origin: .zero, size: .init(width: 800, height: 800)), device: device)
        depthStencilPixelFormat = .depth32Float
        clearColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        
//        let textureDescriptor = MTLTextureDescriptor()
//        textureDescriptor.pixelFormat = MTLPixelFormat.bgra8Unorm
//        textureDescriptor.width = 128
//        textureDescriptor.height = 128
//        textureDescriptor.usage = .shaderRead
//        textureDescriptor.storageMode = .private
//
//
//        let texture = device.makeTexture(descriptor: textureDescriptor)!
        
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        semaphore.wait()
//        tick()
        
        
        time += (1.0 / Double(preferredFramesPerSecond))
        let t = Float(time)
        
        
        
        guard
            let buffer = queue.makeCommandBuffer(),
            let pass = currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: pass),
            let submesh = sphereMesh.submeshes.first,
            let drawable = currentDrawable
        else { return }
        
        
        
        
        encoder.setRenderPipelineState(state)
        encoder.setCullMode(.back)
        encoder.setDepthStencilState(depth)
        
        
        
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
        
//        encoder.setVertexBuffer(constants, offset: (count % 3) * MemoryLayout<simd_float4x4>.size * 256, index: 1)
        
        
        
        
        let cameraPosition = SIMD3<Float>(0, 0, 5)
        let viewMatrix = simd_float4x4(translate: -cameraPosition)
        
        let xAxis = SIMD3<Float>(1, 0, 0)
        let yAxis = SIMD3<Float>(0, 1, 0)
        
        let rotate = simd_float4x4(rotateAbout: yAxis, byAngle: t)
        
        let modelMatrix = rotate * matrix_identity_float4x4

                let aspectRatio = Float(drawableSize.width / drawableSize.height)
                let canvasWidth: Float = 5.0
                let canvasHeight = canvasWidth / aspectRatio
        
        // vertex
        encoder.setVertexBuffer(sphereMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        var projectionMatrix = simd_float4x4(perspectiveProjectionFoVY: .pi / 3,
                                                     aspectRatio: aspectRatio,
                                                     near: 0.01,
                                                     far: 100)
        var index = (count % 3) * bufferSize
        var pointer = constants.contents().advanced(by: index)
        pointer.copyMemory(from: &projectionMatrix, byteCount: MemoryLayout<simd_float4x4>.size)
        
        // frame
        encoder.setVertexBuffer(constants, offset: index, index: 2)
        
        
        
        // frame
        encoder.setFragmentBuffer(constants, offset: index, index: 0)
        
        
        
        
        index += MemoryLayout<simd_float4x4>.size
        
        var transform = viewMatrix * modelMatrix
        
        
        
        
        
        
        
        pointer = constants.contents().advanced(by: index)
        pointer.copyMemory(from: &transform, byteCount: MemoryLayout<simd_float4x4>.size)
        
        
        // node
        encoder.setVertexBuffer(constants, offset: index, index: 1)
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        encoder.setFragmentTexture(sphereTexture, index: 0)
        encoder.setFragmentSamplerState(sampler, index: 0)
        
        encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                      indexCount: submesh.indexCount,
                                      indexType: submesh.indexType,
                                      indexBuffer: submesh.indexBuffer.buffer,
                                      indexBufferOffset: submesh.indexBuffer.offset)
        encoder.endEncoding()
        buffer.present(drawable)
        
        buffer
            .addCompletedHandler { [weak self] _ in
                self?.semaphore.signal()
            }
        
        
        
        
        buffer.commit()
        count += 1
    }
    
    private func tick() {
        time += (1.0 / Double(preferredFramesPerSecond))
        let t = Float(time)
        
//        time += 1.0 / .init(preferredFramesPerSecond)
//        let t = Float(time)
//        let pulseRate: Float = 1.5
//        let scaleFactor = 1.0 + 0.5 * cos(pulseRate * t)
//        let scale = SIMD2<Float>(scaleFactor, scaleFactor)
//        let scaleMatrix = simd_float4x4(scale2D: scale)
//
//        let rotationRate: Float = 2.5
//        let rotationAngle = rotationRate * t
//        let rotationMatrix = simd_float4x4(rotateZ: rotationAngle)
//
//        let orbitalRadius: Float = 200
//        let translation = orbitalRadius * SIMD2<Float>(cos(t), sin(t))
//        let translationMatrix = simd_float4x4(translate2D: translation)
//
//        let modelMatrix = translationMatrix * rotationMatrix * scaleMatrix
//
////        let aspectRatio = Float(drawableSize.width / drawableSize.height)
////        let canvasWidth: Float = 800
////        let canvasHeight = canvasWidth / aspectRatio
////        let projectionMatrix = simd_float4x4(orthographicProjectionWithLeft: -canvasWidth / 2,
////                                             top: canvasHeight / 2,
////                                             right: canvasWidth / 2,
////                                             bottom: -canvasHeight / 2,
////                                             near: 0.0,
////                                             far: 1.0)
//
//        let aspectRatio = Float(drawableSize.width / drawableSize.height)
//        let canvasWidth: Float = 5.0
//        let canvasHeight = canvasWidth / aspectRatio
//        let projectionMatrix =
//        simd_float4x4(orthographicProjectionWithLeft: -canvasWidth / 2,
//                      top: canvasHeight / 2,
//                      right: canvasWidth / 2,
//                      bottom: -canvasHeight / 2,
//                      near: -1,
//                      far: 1)
//
//        var transformMatrix = projectionMatrix// * modelMatrix
//        let contents = constants.contents().advanced(by: (count % 3) * MemoryLayout<simd_float4x4>.size * 256)
//        contents.copyMemory(from: &transformMatrix, byteCount: MemoryLayout<simd_float4x4>.size)
        
        
        let cameraPosition = SIMD3<Float>(0, 0, 5)
        let viewMatrix = simd_float4x4(translate: -cameraPosition)
        
        let xAxis = SIMD3<Float>(1, 0, 0)
        let yAxis = SIMD3<Float>(0, 1, 0)
        
        let rotate = simd_float4x4(rotateAbout: yAxis, byAngle: t)
        
        let modelMatrix = rotate * matrix_identity_float4x4

                let aspectRatio = Float(drawableSize.width / drawableSize.height)
                let canvasWidth: Float = 5.0
                let canvasHeight = canvasWidth / aspectRatio
//                let projectionMatrix = simd_float4x4(orthographicProjectionWithLeft: -canvasWidth / 2,
//                                                     top: canvasHeight / 2,
//                                                     right: canvasWidth / 2,
//                                                     bottom: -canvasHeight / 2,
//                                                     near: -0.01,
//                                                     far: 100)
        
        var projectionMatrix = simd_float4x4(perspectiveProjectionFoVY: .pi / 3,
                                                     aspectRatio: aspectRatio,
                                                     near: 0.01,
                                                     far: 100)
        var index = (count % 3) * bufferSize
        var pointer = constants.contents().advanced(by: index)
        pointer.copyMemory(from: &projectionMatrix, byteCount: MemoryLayout<simd_float4x4>.size)
        
        index += MemoryLayout<simd_float4x4>.size
        
        var transform = viewMatrix * modelMatrix
        pointer = constants.contents().advanced(by: index)
        pointer.copyMemory(from: &transform, byteCount: MemoryLayout<simd_float4x4>.size)
        
        index += MemoryLayout<simd_float4x4>.size
        
        
        
        
        

//                var transformMatrix = projectionMatrix * viewMatrix * modelMatrix
//
//                let constants = constants.contents().advanced(by: (count % 3) * (MemoryLayout<simd_float4x4>.size * 256))
//                constants.copyMemory(from: &transformMatrix, byteCount: MemoryLayout<simd_float4x4>.size)
    }
    
    private static var image: CGImage {
        
        let context = CGContext(data: nil,
                                width: imageSize * 2,
                                height: imageSize,
                                bitsPerComponent: 8,
                                bytesPerRow: 24 * imageSize,
                                space: CGColorSpace.init(name: CGColorSpace.acescgLinear)!,
                                bitmapInfo:  CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).rawValue)!
        
        let gradient = CAGradientLayer()
        gradient.startPoint = .init(x: 0, y: 0)
        gradient.endPoint = .init(x: 0, y: 1)
        gradient.locations = [0, 0.5, 1]
        gradient.colors = [CGColor(red: 0.92, green: 0.95, blue: 0.99, alpha: 1),
                           CGColor(red: 0.94, green: 0.945, blue: 0.985, alpha: 1),
                           CGColor(red: 0.935, green: 0.945, blue: 0.98, alpha: 1)]
        gradient.frame = .init(x: 0, y: 0, width: imageSize * 2, height: imageSize)
        gradient.render(in: context)
        
        let circle = CAShapeLayer()
//        circle.frame = .init(x: 0, y: 50, width: 50, height: 50)
        circle.fillColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
        let p = CGMutablePath()
        p.addArc(center: .init(x: 256, y: 128), radius: 64, startAngle: 0, endAngle: .pi * 2, clockwise: true)
//        circle.path = CGPath(ellipseIn: .init(x: 20, y: 20, width: 48, height: 48), transform: nil)
        circle.path = p
        circle.render(in: context)
        return context.makeImage()!
    }
}

private let imageSize = 512

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
    
    init(translate t: SIMD3<Float>) {
            self.init(SIMD4<Float>(  1,   0,   0, 0),
                      SIMD4<Float>(  0,   1,   0, 0),
                      SIMD4<Float>(  0,   0,   1, 0),
                      SIMD4<Float>(t.x, t.y, t.z, 1))
        }
    
    init(rotateAbout axis: SIMD3<Float>, byAngle radians: Float) {
            let x = axis.x
            let y = axis.y
            let z = axis.z
            let s = sin(radians)
            let c = cos(radians)

            self.init(
                SIMD4<Float>(x * x + (1 - x * x) * c, x * y * (1 - c) - z * s, x * z * (1 - c) + y * s, 0),
                SIMD4<Float>(x * y * (1 - c) + z * s, y * y + (1 - y * y) * c, y * z * (1 - c) - x * s, 0),
                SIMD4<Float>(x * z * (1 - c) - y * s, y * z * (1 - c) + x * s, z * z + (1 - z * z) * c, 0),
                SIMD4<Float>(                      0,                       0,                       0, 1)
            )
        }
    
    init(perspectiveProjectionFoVY fovYRadians: Float,
             aspectRatio: Float,
             near: Float,
             far: Float)
        {
            let sy = 1 / tan(fovYRadians * 0.5)
            let sx = sy / aspectRatio
            let zRange = far - near
            let sz = -(far + near) / zRange
            let tz = -2 * far * near / zRange
            self.init(SIMD4<Float>(sx, 0,  0,  0),
                      SIMD4<Float>(0, sy,  0,  0),
                      SIMD4<Float>(0,  0, sz, -1),
                      SIMD4<Float>(0,  0, tz,  0))
        }
}
