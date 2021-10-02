import ComposableArchitecture
import Combine

struct GameState: Equatable, Codable {
    var moves = 0
    var cards: [Card] = .newGame
    var discoveredArts: [Art] = []
    var isGameOver = false
    var level: DifficultyLevel = .normal
    var mode: GameMode = .singlePlayer

    var newGameAlert: AlertState<GameAction>?

    var hasCardsFacedUp: Bool { cards.filter { $0.isFaceUp }.count > 0 }
    var isGameInProgress: Bool { moves > 0 || hasCardsFacedUp }
    func isCardValid(id: Int) -> Bool { cards.count > id }

    private enum CodingKeys: CodingKey {
        case moves, cards, discoveredArts, isGameOver, level
    }
}

enum GameAction: Equatable {
    case new
    case shuffleCards
    case cardReturned(Int)
    case save
    case load
    case clearBackup
    case newGameButtonTapped
    case newGameAlertCancelTapped
    case newGameAlertConfirmTapped
    case switchMode(GameMode)
    case nextPlayer
}

struct GameEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var save: (GameState) -> Void
    var load: () -> GameState
    var clearBackup: () -> Void
}

let gameReducer = Reducer<GameState, GameAction, GameEnvironment> { state, action, environment in
    switch action {
    case .new:
        state.cards = state.cards.map { Card(id: $0.id, art: $0.art, isFaceUp: false) }
        state.moves = 0
        state.discoveredArts = []
        state.isGameOver = false
        return Effect(value: .clearBackup).append(
            Effect(value: .shuffleCards)
                .delay(for: .seconds(0.5), scheduler: environment.mainQueue)
        )
        .eraseToEffect()
    case .shuffleCards:
        return .none
    case let .cardReturned(cardId):
        state.cards[cardId].isFaceUp = true
        let facedUpCards = state.cards
            .filter { !state.discoveredArts.contains($0.art) }
            .filter { $0.isFaceUp == true }

        switch facedUpCards.count {
        case 1: return Effect(value: .save)
        case 2:
            state.moves += 1
            let artDiscovered = facedUpCards[0].art == facedUpCards[1].art
            if artDiscovered {
                state.discoveredArts.append(facedUpCards[0].art)
            }
            guard state.discoveredArts.count < state.level.cardsCount/2 else {
                state.isGameOver = true
                return Effect(value: .clearBackup)
            }
            return Effect(value: .save)
                .append(artDiscovered ? .none : Effect(value: .nextPlayer))
                .eraseToEffect()
        default:
            // turn down all cards (except ones already discovered and the one just returned)
            state.cards = state.cards.map { card in
                if card.id == cardId || state.discoveredArts.contains(card.art) {
                    return Card(id: card.id, art: card.art, isFaceUp: true)
                }
                return Card(id: card.id, art: card.art, isFaceUp: false)
            }
            return Effect(value: .save)
        }
    case .save:
        environment.save(state)
        return .none
    case .load:
        state = environment.load()
        return .none
    case .clearBackup:
        environment.clearBackup()
        return .none
    case .newGameButtonTapped:
        guard state.moves > 0 && !state.isGameOver else {
            // No need to present this alert, do a new game right now
            return Effect(value: .new)
        }
        state.newGameAlert = AlertState(
            title: TextState("New game"),
            message: TextState("This will reset the current game, you will loose your progress!"),
            primaryButton: .cancel(TextState("Cancel")),
            secondaryButton: .destructive(
                TextState("Reset game"),
                action: .send(.newGameAlertConfirmTapped)
            )
        )
        return .none
    case .newGameAlertCancelTapped:
        state.newGameAlert = nil
        return .none
    case .newGameAlertConfirmTapped:
        state.newGameAlert = nil
        return Effect(value: .new)
    case let .switchMode(mode):
        state.mode = mode
        return .none
    case .nextPlayer:
        if case let .twoPlayers(currentPlayer) = state.mode {
            switch currentPlayer {
            case .first: state.mode = .twoPlayers(.second)
            case .second: state.mode = .twoPlayers(.first)
            }
        }
        return .none
    }

}

#if DEBUG
extension GameState {
    static func mocked(modifier: (inout Self) -> Void) -> Self {
        var state = GameState()
        modifier(&state)
        return state
    }
    static var preview: Self = .mocked {
        $0.moves = 42
        $0.cards = .predicted
    }
    static let almostFinishedGame: Self = .mocked {
        $0.isGameOver = false
        $0.discoveredArts = Art.allCases.filter({ $0 != .cave })
        $0.moves = 142
        $0.cards = [Card].predicted(isFaceUp: true).map {
            if $0.art == .cave {
                return Card(id: $0.id, art: $0.art, isFaceUp: false)
            }
            return $0
        }
    }
}

extension GameEnvironment {
    static var preview: Self {
        GameEnvironment(mainQueue: .preview, save: { _ in }, load: { .preview }, clearBackup: { })
    }
}
#endif
