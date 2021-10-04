import XCTest
@testable import MemoArt
import ComposableArchitecture

extension GameCoreTests {
    func testGameMode() {
        let store = TestStore(
            initialState: GameState(cards: .predicted),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.switchMode(.twoPlayers(.init()))) {
                $0.mode = .twoPlayers(.init())
            }
        )
    }

    func testNextPlayer() {
        let store = TestStore(
            initialState: GameState(cards: .predicted, mode: .twoPlayers(.init())),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.nextPlayer) {
                $0.mode = .twoPlayers(.init(current: .second))
            },
            .send(.nextPlayer) {
                $0.mode = .twoPlayers(.init(current: .first))
            }
        )
    }

    func testNextPlayerWhenNotDiscoveringArt() {
        let store = TestStore(
            initialState: GameState(cards: .predicted, mode: .twoPlayers(.init())),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.cardReturned(2)) {
                $0.cards = $0.cards.map { card in
                    if card.id == 2 {
                        return Card(id: 2, art: .cave, isFaceUp: true)
                    }
                    return card
                }
            },
            .receive(.save),
            .send(.cardReturned(3)) {
                $0.cards = $0.cards.map { card in
                    if card.id == 3 {
                        return Card(id: 3, art: .childish, isFaceUp: true)
                    }
                    return card
                }
                $0.moves = 1
            },
            .receive(.save),
            .receive(.nextPlayer) {
                $0.mode = .twoPlayers(.init(current: .second))
            }
        )
    }

    func testKeepCurrentPlayerWhenDiscoveringArt() {
        let store = TestStore(
            initialState: GameState(cards: .predicted, mode: .twoPlayers(.init())),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.cardReturned(2)) {
                $0.cards = $0.cards.map { card in
                    if card.id == 2 {
                        return Card(id: 2, art: .cave, isFaceUp: true)
                    }
                    return card
                }
            },
            .receive(.save),
            .send(.cardReturned(12)) {
                $0.cards = $0.cards.map { card in
                    if card.id == 12 {
                        return Card(id: 12, art: .cave, isFaceUp: true)
                    }
                    return card
                }
                $0.moves = 1
                $0.discoveredArts = [.cave]
                $0.mode = .twoPlayers(.init(firstPlayerDiscoveredArts: [.cave]))
            },
            .receive(.save)
        )
    }
}
