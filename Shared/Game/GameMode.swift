enum GameMode: Equatable, Codable {
    struct TwoPlayers: Equatable, Codable {
        var current: Player = .first
        var firstPlayerDiscoveredArts: [Art] = []
        var secondPlayerDiscoveredArts: [Art] = []
    }

    enum Player: Codable {
        case first
        case second
    }

    case singlePlayer
    case twoPlayers(TwoPlayers)
}

#if DEBUG
extension GameMode.TwoPlayers {
    static func mocked(modifier: (inout Self) -> Void) -> Self {
        var twoPlayers = GameMode.TwoPlayers()
        modifier(&twoPlayers)
        return twoPlayers
    }
}
#endif
