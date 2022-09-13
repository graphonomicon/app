import AppKit

private let pi2 = CGFloat.pi * 2

final class Layer: CALayer {
    private weak var model: Model!
    
    required init?(coder: NSCoder) { nil }
    override init(layer: Any) { super.init(layer: layer) }
    init(model: Model) {
        self.model = model
        super.init()
        backgroundColor = .white
    }
    
    override func draw(in context: CGContext) {
        context.translateBy(x: model.origin.x, y: model.origin.y)
        context.scaleBy(x: model.zoom, y: model.zoom)
        
        context.move(to: .init(x: model.constelation.points.first!.x, y: model.constelation.points.first!.y))
        context.addLine(to: .init(x: model.constelation.points.last!.x, y: model.constelation.points.last!.y))
        context.setStrokeColor(NSColor.systemIndigo.cgColor)
        context.setLineWidth(5)
        context.strokePath()
        
        model.constelation
            .points
            .forEach { point in
                context
                    .addArc(
                        center: .init(x: point.x, y: point.y),
                        radius: point.radius,
                        startAngle: .zero,
                        endAngle: pi2,
                        clockwise: true)
                context.setFillColor(NSColor.systemMint.cgColor)
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
