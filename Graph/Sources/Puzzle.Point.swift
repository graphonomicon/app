import Foundation

extension Puzzle {
    public struct Point: Hashable {
        public let x: Double
        public let y: Double
        public let z: Double
        let id: UUID
        
        init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
            id = .init()
        }
    }
}
