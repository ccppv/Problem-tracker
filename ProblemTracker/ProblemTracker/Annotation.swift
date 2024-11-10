import Foundation
import CoreGraphics

struct Annotation: Codable, Hashable {
    var rect: CGRect
    var problem: String

    // Реализация метода hash для уникальности
    func hash(into hasher: inout Hasher) {
        hasher.combine(rect.origin.x)
        hasher.combine(rect.origin.y)
        hasher.combine(rect.size.width)
        hasher.combine(rect.size.height)
        hasher.combine(problem)
    }

    static func == (lhs: Annotation, rhs: Annotation) -> Bool {
        return lhs.rect == rhs.rect && lhs.problem == rhs.problem
    }
}
