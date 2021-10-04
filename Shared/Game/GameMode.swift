enum GameMode: Equatable {
    struct TwoPlayers: Equatable {
        var current: Player = .first
        var firstPlayerDiscoveredArts: [Art] = []
        var secondPlayerDiscoveredArts: [Art] = []
    }

    enum Player {
        case first
        case second
    }

    case singlePlayer
    case twoPlayers(TwoPlayers)
}
