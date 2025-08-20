import Foundation

struct WeightedGrade: Identifiable, Codable {
    let id = UUID()
    var value: Double
    var weight: Double
    var description: String = ""
}
