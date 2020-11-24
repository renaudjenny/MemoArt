import ComposableArchitecture
import Combine

struct GameState: Equatable, Codable {
    var moves = 0
    var symbols: [Symbol] = .newGameSymbols
    var discoveredSymbolTypes: [SymbolType] = []
    var isGameOver = false

    var hasCardsFacedUp: Bool { symbols.filter { $0.isFaceUp }.count > 0 }
    var isGameInProgress: Bool { moves > 0 || hasCardsFacedUp }
}

enum GameAction: Equatable {
    case new
    case shuffleCards
    case cardReturned(Int)
    case save
    case load
    case clearBackup
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
        state.symbols = state.symbols.map { Symbol(id: $0.id, type: $0.type, isFaceUp: false) }
        state.moves = 0
        state.discoveredSymbolTypes = []
        state.isGameOver = false
        return Effect(value: .shuffleCards)
            .delay(for: .seconds(0.5), scheduler: environment.mainQueue)
            .eraseToEffect()
    case .shuffleCards:
        return .none
    case let .cardReturned(cardId):
        state.symbols[cardId].isFaceUp = true
        let turnedUpSymbols = state.symbols
            .filter { !state.discoveredSymbolTypes.contains($0.type) }
            .filter { $0.isFaceUp == true }

        switch turnedUpSymbols.count {
        case 1: return Effect(value: .save)
        case 2:
            state.moves += 1
            if turnedUpSymbols[0].type == turnedUpSymbols[1].type {
                state.discoveredSymbolTypes.append(turnedUpSymbols[0].type)
            }
            guard state.discoveredSymbolTypes.count < 10 else {
                state.isGameOver = true
                return Effect(value: .clearBackup)
            }
            return Effect(value: .save)
        default:
            // turn down all cards (except ones already discovered and the one just returned)
            state.symbols = state.symbols.map { symbol in
                if symbol.id == cardId || state.discoveredSymbolTypes.contains(symbol.type) {
                    return Symbol(id: symbol.id, type: symbol.type, isFaceUp: true)
                }
                return Symbol(id: symbol.id, type: symbol.type, isFaceUp: false)
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
    }
}
