import XCTest
@testable import MemoArt
import ComposableArchitecture

class GameCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler

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
}
