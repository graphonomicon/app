import Foundation

extension Puzzle {
    public struct Point: Hashable {
        public let x: Double
        public let y: Double
        public let radius: Double
        let id: UUID
        
        init(x: Double, y: Double, radius: Double) {
            self.x = x
            self.y = y
            self.radius = radius
            id = .init()
        }
    }
}
