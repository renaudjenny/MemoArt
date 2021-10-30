import XCTest
@testable import MemoArt
import ComposableArchitecture

// MARK: GameCore New Game related tests
extension GameCoreTests {
    func testNewGame() {
        let store = TestStore(
            initialState: GameState(cards: .predicted),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert([.send(.newGameButtonTapped)] + newGameSteps)
    }

    func testNewGameWithHardDifficultyLevel() {
        let store = TestStore(
            initialState: GameState(cards: .predicted(level: .hard)),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert([.send(.newGameButtonTapped)] + newGameSteps(level: .hard))
    }

    func testNewGameWithEasyDifficultyLevel() {
        let store = TestStore(
            initialState: GameState(cards: .predicted(level: .easy)),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert([.send(.newGameButtonTapped)] + newGameSteps(level: .easy))
    }

    func testAlertUserBeforeNewGameWhenAGameAlreadyStarted() {
        let store = TestStore(
            initialState: GameState(moves: 1, cards: .predicted),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )
        let alertSteps: [Step] = [
            .send(.newGameButtonTapped) {
                $0.newGameAlert = AlertState(
                    title: TextState("New game"),
                    message: TextState("This will reset the current game, you will loose your progress!"),
                    primaryButton: .cancel(TextState("Cancel")),
                    secondaryButton: .destructive(
                        TextState("Reset game"),
                        action: (.send(.newGameAlertConfirmTapped))
                    )
                )
            },
            .send(.newGameAlertConfirmTapped) {
                $0.newGameAlert = nil
            },
        ]
        store.assert(alertSteps + newGameSteps)
    }

    func testDoNotAlertUserBeforeNewGameWhenAGameIsOver() {
        let store = TestStore(
            initialState: GameState(moves: 42, cards: .predicted, isGameOver: true),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert([.send(.newGameButtonTapped)] + newGameSteps)
    }

    func testDoNotAlertUserBeforeNewGameWhenHaveNotStarted() {
        let store = TestStore(
            initialState: GameState(moves: 0, cards: .predicted),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert([.send(.newGameButtonTapped)] + newGameSteps)
    }

    func testAlertUserBeforeChangingGameModeWhenAGameAlreadyStarted() {
        let store = TestStore(
            initialState: GameState(moves: 1, cards: .predicted),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
        )

        let mode: GameMode = .twoPlayers(.init())

        store.assert(
            .send(.gameModeSelected(mode)) {
                $0.newGameAlert = AlertState(
                    title: TextState("New game"),
                    message: TextState("This will reset the current game, you will loose your progress!"),
                    primaryButton: .cancel(TextState("Cancel")),
                    secondaryButton: .destructive(
                        TextState("Reset game"),
                        action: .send(.switchMode(mode))
                    )
                )
            },
            .send(.switchMode(mode)) {
                $0.newGameAlert = nil
                $0.mode = mode
            },
            .receive(.new) {
                $0.isGameOver = false
                $0.discoveredArts = []
                $0.moves = 0
                $0.cards = $0.cards.map { Card(id: $0.id, art: $0.art, isFaceUp: false) }
                $0.mode = mode
                $0.mode = .twoPlayers(.mocked { $0.current = .second })
            },
            .receive(.clearBackup),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.shuffleCards) {
                $0.cards = .predicted(level: .normal)
            }
        )
    }

    private func newGameSteps(level: DifficultyLevel) -> [Step] {[
        .receive(.new) {
            $0.isGameOver = false
            $0.discoveredArts = []
            $0.moves = 0
            $0.cards = $0.cards.map { Card(id: $0.id, art: $0.art, isFaceUp: false) }
        },
        .receive(.clearBackup),
        .do { self.scheduler.advance(by: .seconds(0.5)) },
        .receive(.shuffleCards) {
            $0.cards = .predicted(level: level)
        },
    ]}

    private var newGameSteps: [Step] { newGameSteps(level: .normal) }
}
