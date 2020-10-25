import ComposableArchitecture
import Combine

struct GameState: Equatable {
    var moves = 0
    var symbols: [Symbol] = .newGameSymbols
    var discoveredSymbolTypes: [SymbolType] = []
    var isGameOver = false
}

enum GameAction: Equatable {
    case new
    case shuffleCards
    case cardReturned(Int)
}

struct GameEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let gameReducer = Reducer<GameState, GameAction, GameEnvironment> { state, action, environment in
    switch action {
    case .new:
        state.symbols = state.symbols.map { Symbol(id: $0.id, type: $0.type, isFaceUp: false) }
        state.moves = 0
        state.discoveredSymbolTypes = []
        state.isGameOver = false
        return .init(Just(.shuffleCards).delay(for: .seconds(0.5), scheduler: environment.mainQueue))
    case .shuffleCards:
        state.symbols = .newGameSymbols
        return .none
    case let .cardReturned(cardId):
        state.symbols[cardId].isFaceUp = true
        let turnedUpSymbols = state.symbols
            .filter { !state.discoveredSymbolTypes.contains($0.type) }
            .filter { $0.isFaceUp == true }

        switch turnedUpSymbols.count {
        case 1: return .none
        case 2:
            state.moves += 1
            if turnedUpSymbols[0].type == turnedUpSymbols[1].type {
                state.discoveredSymbolTypes.append(turnedUpSymbols[0].type)
            }
            if state.discoveredSymbolTypes.count >= 10 {
                state.isGameOver = true
            }
            return .none
        default:
            // turn down all cards (except ones already discovered and the one just returned)
            state.symbols = state.symbols.map { symbol in
                if symbol.id == cardId || state.discoveredSymbolTypes.contains(symbol.type) {
                    return Symbol(id: symbol.id, type: symbol.type, isFaceUp: true)
                }
                return Symbol(id: symbol.id, type: symbol.type, isFaceUp: false)
            }
            return .none
        }
    }
}
