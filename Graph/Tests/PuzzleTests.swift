import XCTest
@testable import Graph

final class PuzzleTests: XCTestCase {
    func testMinDistance() {
        let puzzle = Constelation.new(points: 300, length: Constelation.Constants.distance.min)
        
        puzzle
            .points
            .forEach { point in
                XCTAssertTrue(puzzle
                    .points
                    .filter {
                        $0.id != point.id
                    }
                    .filter { other in
                        pow(point.x - other.x, 2) + pow(point.y - other.y, 2) < Constelation.Constants.distance.min
                    }
                    .isEmpty)
            }
    }
}
