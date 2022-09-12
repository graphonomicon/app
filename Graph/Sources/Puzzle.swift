public struct Puzzle {
    
    public static func new(points: Int, length: Double) -> Self {
        let range = Range(uncheckedBounds: (-length, length))
        let deep = Range(uncheckedBounds: (-10, 10.0))
        
        return .init(points: (0 ..< points)
              .reduce(into: .init()) { result, _ in
                  let x = Double.random(in: range)
                  let y = Double.random(in: range)
                  let z = Double.random(in: deep)
            
                    result.insert(.init(x: x,
                                        y: y,
                                        z: z))
                })
    }
    
    public let points: Set<Point>
    
    init(points: Set<Point>) {
        self.points = points
    }
}
