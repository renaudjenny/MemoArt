enum GameMode: Equatable {
    enum PlayerTurn: Equatable {
        case first
        case second
    }

    case singlePlayer
    case twoPlayers(PlayerTurn)
}
