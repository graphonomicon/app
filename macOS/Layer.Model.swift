import CoreGraphics
import Graph

extension Layer {
    final class Model {
        var origin = CGPoint.zero
        var zoom = CGFloat(1)
        let constelation = Constelation.new(points: 2, length: 300)
    }
}
