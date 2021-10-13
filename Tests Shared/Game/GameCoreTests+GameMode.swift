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

    func testResetTwoPlayersDataWhenNewGame() {
        let store = TestStore(
            initialState: GameState(
                moves: 10,
                cards: .predicted,
                discoveredArts: [
                    .artDeco, .arty, .childish, .destructured, .geometric,
                    .gradient, .impressionism, .pixelArt, .watercolor,
                ],
                mode: .twoPlayers(.almostFinishedGame)
            ),
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
                $0.moves = 11
                $0.discoveredArts = $0.discoveredArts + [.cave]
                $0.mode = .twoPlayers(.almostFinishedGame {
                    $0.secondPlayerDiscoveredArts += [.cave]
                })
                $0.isGameOver = true
            },
            .receive(.clearBackup),
            .send(.newGameButtonTapped),
            .receive(.new) {
                $0 = GameState(
                    cards: .predicted,
                    mode: .twoPlayers(.init())
                )
            },
            .receive(.clearBackup),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.shuffleCards) {
                $0.cards = .predicted(level: .normal)
            }
        )
    }
}

extension GameMode.TwoPlayers {
    static var almostFinishedGame: Self {
        .almostFinishedGame(modifier: { _ in })
    }

    static func almostFinishedGame(modifier: (inout Self) -> Void) -> Self {
        var twoPlayers = GameMode.TwoPlayers.mocked {
            $0.current = .second
            $0.firstPlayerDiscoveredArts = [
                .artDeco, .arty, .childish, .destructured, .geometric,
            ]
            $0.secondPlayerDiscoveredArts = [
                .geometric, .gradient, .impressionism, .pixelArt, .watercolor,
            ]
        }
        modifier(&twoPlayers)
        return twoPlayers
    }
}
