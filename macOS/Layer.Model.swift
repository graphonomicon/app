import CoreGraphics
import Graph

extension Layer {
    final class Model {
        var zoom = CGFloat(1)
        var origin = CGPoint.zero
        let constelation = Constelation.new(points: 20, length: 300)
        
        func approximate(pointX: CGFloat, centerX: CGFloat) {
            let x = origin.x - pointX
            
            if x > 0 {
                print(x)
                origin.x -= min(x, 2)
            } else {
                origin.x -= max(x, -1)
            }
        }
    }
}
