enum DifficultyLevel: String, Codable {
    case easy
    case normal
    case hard

    var cardsCount: Int {
        switch self {
        case .easy: return 18
        case .normal: return 20
        case .hard: return 22
        }
    }
}
