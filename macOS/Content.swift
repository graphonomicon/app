import AppKit
import Coffee
import Combine
import MetalKit

final class Content: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        guard
            let shades = Bundle.main.url(forResource: "Shades", withExtension: "metal"),
            let device = MTLCreateSystemDefaultDevice(),
            let library = try? device.makeLibrary(URL: shades),
            let vertex = library.makeFunction(name: "vertex_main"),
            let fragment = library.makeFunction(name: "fragment_main"),
            let mesh = try? MTKMesh(mesh: .init(boxWithExtent: .init(x: 0.75, y: 0.75, z: 0.75),
                                                segments: [100, 100],
                                                inwardNormals: false,
                                                geometryType: .triangles,
                                                allocator: MTKMeshBufferAllocator(device: device)),
                                    device: device),
            let view = Miew(device: device)
        else { return }
        view.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
        addSubview(view)
        
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline.vertexFunction = vertex
        pipeline.fragmentFunction = fragment
        pipeline.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
        guard let state = try? device.makeRenderPipelineState(descriptor: pipeline) else { return }
        
        
        
//        view.translatesAutoresizingMaskIntoConstraints = false
//
//        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}
