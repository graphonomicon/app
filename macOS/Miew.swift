import MetalKit

final class Miew: MTKView {
    private let queue: MTLCommandQueue
    
    required init(coder: NSCoder) { fatalError() }
    init?(device: MTLDevice) {
        guard let queue = device.makeCommandQueue() else { return nil }
        self.queue = queue
        super.init(frame: .init(origin: .zero, size: .init(width: 600, height: 600)), device: device)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard
            let commandBuffer = queue.makeCommandBuffer(),
            let pass = currentRenderPassDescriptor,
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: pass)
        else { return }
    }
}
