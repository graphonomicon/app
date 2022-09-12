import AppKit
import Graph

private let pi2 = CGFloat.pi * 2

final class Layer: CALayer {
    private let graph = Puzzle.new(points: 30, length: 300)
    
    override func draw(in context: CGContext) {
        context
            .addRect(bounds)
        
        context.setFillColor(.white)
        context.fillPath()
        
        context.translateBy(x: bounds.midX, y: bounds.midY)
        
        graph
            .points
            .forEach { point in
                context
                    .addArc(
                        center: .init(x: point.x, y: point.y),
                        radius: 15 + point.z,
                        startAngle: .zero,
                        endAngle: pi2,
                        clockwise: true)
                context.setFillColor(NSColor.systemBlue.cgColor)
                context.fillPath()
            }
    }
    
    override class func defaultAction(forKey: String) -> CAAction? {
        NSNull()
    }
    
    override func hitTest(_: CGPoint) -> CALayer? {
        nil
    }
}
