import AppKit

private let pi2 = CGFloat.pi * 2

final class Layer: CALayer {
    override func draw(in context: CGContext) {
        context
            .addRect(bounds)
        context.setFillColor(.white)
        context.fillPath()
        
        context
            .addArc(
                center: .init(x: bounds.midX, y: bounds.midY),
                radius: 30,
                startAngle: .zero,
                endAngle: pi2,
                clockwise: true)
        context.setFillColor(NSColor.systemBlue.cgColor)
        context.fillPath()
    }
    
    override class func defaultAction(forKey: String) -> CAAction? {
        NSNull()
    }
    
    override func hitTest(_: CGPoint) -> CALayer? {
        nil
    }
}
