import Foundation

struct HighScore: Equatable {
    let score: Int
    let name: String
    let date: Date

    init(score: Int, name: String = "❓", date: Date) {
        self.score = score
        self.name = name
        self.date = date
    }
}

extension HighScore: Identifiable {
    var id: String {
        "\(score) \(name) \(date)"
    }
}
