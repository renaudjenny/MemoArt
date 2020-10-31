import XCTest
@testable import MemoArt
import ComposableArchitecture

class GameCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler
    typealias Step = TestStore<GameState, GameState, GameAction, GameAction, GameEnvironment>.Step

    func testNewGame() {
        let store = TestStore(
            initialState: GameState(),
            reducer: gameReducer,
            environment: GameEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                generateRandomSymbols: { .predictedGameSymbols }
            )
        )
        store.assert(
            .send(.new) {
                $0.isGameOver = false
                $0.discoveredSymbolTypes = []
                $0.moves = 0
                $0.symbols = $0.symbols.map { Symbol(id: $0.id, type: $0.type, isFaceUp: false) }
            },
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.shuffleCards) {
                $0.symbols = .predictedGameSymbols
            }
        )
    }

    func testReturningCards() {
        let store = TestStore(
            initialState: GameState(),
            reducer: gameReducer,
            environment: GameEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                generateRandomSymbols: { .predictedGameSymbols }
            )
        )

        store.assert(
            .send(.shuffleCards) {
                $0.symbols = .predictedGameSymbols
            },
            .send(.cardReturned(0)) {
                $0.symbols = $0.symbols.map {
                    switch $0.id {
                    case 0: return Symbol(id: 0, type: .artDeco, isFaceUp: true)
                    default: return $0
                    }
                }
                $0.moves = 0
            },
            .send(.cardReturned(1)) {
                $0.symbols = $0.symbols.map {
                    switch $0.id {
                    case 0: return Symbol(id: $0.id, type: $0.type, isFaceUp: true)
                    case 1: return Symbol(id: 1, type: .arty, isFaceUp: true)
                    default: return $0
                    }
                }
                $0.moves = 1
            },
            .send(.cardReturned(2)) {
                $0.symbols = $0.symbols.map {
                    switch $0.id {
                    case 0, 1: return Symbol(id: $0.id, type: $0.type, isFaceUp: false)
                    case 2: return Symbol(id: 2, type: .cave, isFaceUp: true)
                    default: return $0
                    }
                }
                $0.moves = 1
            },
            .send(.cardReturned(12)) {
                $0.symbols = $0.symbols.map {
                    switch $0.id {
                    case 2: return Symbol(id: 2, type: .cave, isFaceUp: true)
                    case 12: return Symbol(id: 12, type: .cave, isFaceUp: true)
                    default: return $0
                    }
                }
                $0.moves = 2
                $0.discoveredSymbolTypes = [.cave]
            }
        )
    }

    func testFinishingAGame() {
        let store = TestStore(
            initialState: GameState(),
            reducer: gameReducer,
            environment: GameEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                generateRandomSymbols: { .predictedGameSymbols }
            )
        )

        let returnAllCardsSteps: [Step] = (0..<10).flatMap { cardId in
            [
                .send(.cardReturned(cardId)) {
                    $0.symbols = $0.symbols.map { symbol in
                        switch symbol.id {
                        case cardId: return Symbol(id: cardId, type: symbol.type, isFaceUp: true)
                        case 0..<cardId: return Symbol(id: symbol.id, type: symbol.type, isFaceUp: true)
                        case 10..<(cardId + 10): return Symbol(id: symbol.id, type: symbol.type, isFaceUp: true)
                        default: return Symbol(id: symbol.id, type: symbol.type, isFaceUp: false)
                        }
                    }
                },
                .send(.cardReturned(cardId + 10)) {
                    $0.symbols = $0.symbols.map { symbol in
                        switch symbol.id {
                        case cardId: return Symbol(id: cardId, type: symbol.type, isFaceUp: true)
                        case cardId + 10: return Symbol(id: cardId + 10, type: symbol.type, isFaceUp: true)
                        case 0..<cardId: return Symbol(id: symbol.id, type: symbol.type, isFaceUp: true)
                        case 10..<(cardId + 10): return Symbol(id: symbol.id, type: symbol.type, isFaceUp: true)
                        default: return Symbol(id: symbol.id, type: symbol.type, isFaceUp: false)
                        }
                    }
                    let numberOfCardReturned = (cardId + 1) * 2
                    $0.discoveredSymbolTypes = SymbolType.allCases.prefix(numberOfCardReturned/2)
                    $0.moves = numberOfCardReturned/2
                    if numberOfCardReturned == 20 {
                        $0.isGameOver = true
                    }
                }
            ]
        }

        store.assert(
            [.send(.shuffleCards) {
                $0.symbols = .predictedGameSymbols
            }]
            +
            returnAllCardsSteps
        )
    }
}
