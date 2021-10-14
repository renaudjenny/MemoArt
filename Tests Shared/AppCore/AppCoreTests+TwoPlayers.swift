import XCTest
@testable import MemoArt
import ComposableArchitecture

// MARK: AppCore Two Players mode related tests
extension AppCoreTests {
    func testPresentAndHideTwoPlayersScoresView() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.presentTwoPlayersScoresView) {
                $0.isTwoPlayersScoresPresented = true
            },
            .send(.hideTwoPlayersScoresView) {
                $0.isTwoPlayersScoresPresented = false
            }
        )
    }

    func testPresentTwoPlayersScoresWhenGameIsFinished() {
        let store = TestStore(
            initialState: AppState.almostFinishedGame {
                $0.game.mode = .twoPlayers(.almostFinishedGame)
            },
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.game(.cardReturned(2))) {
                $0.game.cards = $0.game.cards.map { card in
                    if card.id == 2 {
                        return Card(id: 2, art: .cave, isFaceUp: true)
                    }
                    return card
                }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(12))) {
                $0.game.isGameOver = true
                $0.game.cards = $0.game.cards.map { card in
                    if card.id == 12 {
                        return Card(id: 12, art: .cave, isFaceUp: true)
                    }
                    return card
                }
                $0.game.moves = 143
                $0.game.discoveredArts += [.cave]
                $0.game.mode = .twoPlayers(.almostFinishedGame {
                    $0.secondPlayerDiscoveredArts += [.cave]
                })
            },
            .receive(.game(.clearBackup)),
            .receive(.presentTwoPlayersScoresView) {
                $0.isTwoPlayersScoresPresented = true
            }
        )
    }
}
