import ComposableArchitecture

struct GameState: Equatable {
    var moves = 0
    var symbols: [Symbol] = []
    var discoveredSymbolTypes: [SymbolType] = []
    var isGameOver = false
}

enum GameAction: Equatable {
    case new
    case cardReturned(Int)
}

struct GameEnvironment {

}

let gameReducer = Reducer<GameState, GameAction, GameEnvironment> { state, action, _ in
    switch action {
    case .new:
        let symbols = (SymbolType.allCases + SymbolType.allCases).shuffled()
        state.symbols = symbols.enumerated().map({ (i, symbolType) in
            Symbol(id: i, type: symbolType, isReturned: true)
        })
        state.moves = 0
        state.discoveredSymbolTypes = []
        state.isGameOver = false
        return .none
    case let .cardReturned(cardId):
        state.symbols[cardId].isReturned = false
        let turnedUpSymbols = state.symbols
            .filter { !state.discoveredSymbolTypes.contains($0.type) }
            .filter { $0.isReturned == false }
        state.moves += 1

        guard turnedUpSymbols.count > 1 else { return .none }

        if turnedUpSymbols[0].type == turnedUpSymbols[1].type {
            state.discoveredSymbolTypes.append(turnedUpSymbols[0].type)
        }
        if state.discoveredSymbolTypes.count >= 10 {
            state.isGameOver = true
        }

        guard turnedUpSymbols.count > 2 else { return .none }

        // turn down all cards (except ones already discovered and the one just returned)
        state.symbols = state.symbols.map { symbol in
            if symbol.id == cardId || state.discoveredSymbolTypes.contains(symbol.type) {
                return Symbol(id: symbol.id, type: symbol.type, isReturned: false)
            }
            return Symbol(id: symbol.id, type: symbol.type, isReturned: true)
        }

        return .none
    }
}
