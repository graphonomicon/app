import Foundation

public struct Puzzle {
    public static func new(points: Int, length: Double) -> Self {
        let range = Range(uncheckedBounds: (-length, length))
        return .init(points: (0 ..< points)
            .reduce(into: .init()) { result, _ in
                let x = Double.random(in: range)
                let y = Double.random(in: range)
                
                guard
                result
                    .filter({ point in
                        pow(point.x - x, 2) + pow(point.y - y, 2) < Constants.distance.min
                    })
                    .isEmpty
                else { return }
                
                result.insert(.init(x: x,
                                    y: y,
                                    radius: .random(in: Constants.radius)))
            })
    }
    
    public let points: Set<Point>
    
    init(points: Set<Point>) {
        self.points = points
    }
}
