import XCTest
@testable import MemoArt
import ComposableArchitecture

class AppCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler

    func testDoNotPresentNewHighScoreWhenTheGameIsNotFinished() throws {
        let store = TestStore(
            initialState: AppState.mocked {
                $0.game.cards = .predicted
            },
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.game(.cardReturned(0))) {
                $0.game.cards = $0.game.cards.map { card in
                    switch card.id {
                    case 0: return Card(id: 0, art: .artDeco, isFaceUp: true)
                    default: return card
                    }
                }
            },
            .receive(.game(.save))
        )
    }

    func testPresentNewHighScoreForAnEmptyHighScoresBoard() throws {
        let store = TestStore(
            initialState: AppState.almostFinishedGame,
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.game(.cardReturned(2))) {
                $0.game.cards = $0.game.cards.map { card in
                    switch card.id {
                    case 2: return Card(id: 2, art: .cave, isFaceUp: true)
                    default: return card
                    }
                }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(12))) {
                $0.game.cards = $0.game.cards.map { card in
                    switch card.id {
                    case 12: return Card(id: 12, art: .cave, isFaceUp: true)
                    default: return card
                    }
                }
                $0.game.isGameOver = true
                $0.game.moves = 143
                $0.game.discoveredArts = $0.game.discoveredArts + [.cave]
            },
            .receive(.game(.clearBackup)),
            .do { self.scheduler.advance(by: .seconds(0.8)) },
            .receive(.presentNewHighScoreView) {
                $0.isNewHighScoreEntryPresented = true
            }
        )
    }

    func testPresentNewHighScoreForAFullHighScoresBoard() throws {
        let store = TestStore(
            initialState: AppState.mocked {
                $0.game = AppState.almostFinishedGame.game
                $0.game.moves = 10
                $0.highScores = HighScoresState(scores: .test)
            },
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.game(.cardReturned(2))) {
                $0.game.cards = $0.game.cards.map { card in
                    switch card.id {
                    case 2: return Card(id: 2, art: .cave, isFaceUp: true)
                    default: return card
                    }
                }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(12))) {
                $0.game.cards = $0.game.cards.map { card in
                    switch card.id {
                    case 12: return Card(id: 12, art: .cave, isFaceUp: true)
                    default: return card
                    }
                }
                $0.game.isGameOver = true
                $0.game.moves = 11
                $0.game.discoveredArts = $0.game.discoveredArts + [.cave]
            },
            .receive(.game(.clearBackup)),
            .do { self.scheduler.advance(by: .seconds(0.8)) },
            .receive(.presentNewHighScoreView) {
                $0.isNewHighScoreEntryPresented = true
            }
        )
    }

    func testDoNotPresentNewHighScoreForAFullHighScoresBoardWhenTheScoreIsTooBad() throws {
        let store = TestStore(
            initialState: AppState.mocked {
                $0.game = AppState.almostFinishedGame.game
                $0.highScores = HighScoresState(scores: .test)
            },
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.game(.cardReturned(2))) {
                $0.game.cards = $0.game.cards.map { card in
                    switch card.id {
                    case 2: return Card(id: 2, art: .cave, isFaceUp: true)
                    default: return card
                    }
                }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(12))) {
                $0.game.cards = $0.game.cards.map { card in
                    switch card.id {
                    case 12: return Card(id: 12, art: .cave, isFaceUp: true)
                    default: return card
                    }
                }
                $0.game.isGameOver = true
                $0.game.moves = 143
                $0.game.discoveredArts = $0.game.discoveredArts + [.cave]
            },
            .receive(.game(.clearBackup))
        )
    }

    func testEnteringANewHighScore() {
        let store = TestStore(
            initialState: AppState.mocked {
                $0.isNewHighScoreEntryPresented = true
            },
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.newHighScoreEntered) {
                $0.isNewHighScoreEntryPresented = false
            }
        )
    }

    func testShuffleCardWithRestrictedArts() {
        let selectedArts: [Art] = [
            .artDeco, .cave, .arty, .chalk, .childish,
            .destructured, .geometric, .gradient, .impressionism, .moderArt,
        ]

        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler) {
                $0.generateRandomCards = { _, _ in .predicted(from: selectedArts) }
            }
        )
        store.assert(
            .send(.game(.shuffleCards)) {
                $0.game.cards = .predicted(from: selectedArts)
            }
        )
    }

    // swiftlint:disable:next function_body_length
    func testConfiguringArtsWillReshuffleCardWhenGameHasNotStartedYet() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert(
            .send(.configuration(.unselectArt(.cave))) {
                $0.configuration.selectedArts = Set(Art.allCases.filter({ $0 != .cave }))
            },
            .receive(.game(.new)),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.cards = .predicted
            },
            .do { self.scheduler.advance(by: .seconds(1.5)) },
            .receive(.configuration(.save)),
            .send(.configuration(.selectArt(.cave))) {
                $0.configuration.selectedArts = Set(Art.allCases)
            },
            .receive(.game(.new)),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.cards = .predicted
            },
            .do { self.scheduler.advance(by: .seconds(1.5)) },
            .receive(.configuration(.save)),
            .send(.game(.cardReturned(0))) {
                $0.game.cards = $0.game.cards.map { $0.id == 0 ? Card(id: 0, art: $0.art, isFaceUp: true) : $0 }
            },
            .receive(.game(.save)),
            .send(.configuration(.unselectArt(.cave))) {
                $0.configuration.selectedArts = Set(Art.allCases.filter({ $0 != .cave }))
            },
            .receive(.game(.new)) {
                $0.game.cards = $0.game.cards.map { Card(id: $0.id, art: $0.art, isFaceUp: false) }
            },
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.cards = .predicted
            },
            .do { self.scheduler.advance(by: .seconds(1.5)) },
            .receive(.configuration(.save)),
            .send(.game(.cardReturned(0))) {
                $0.game.cards = $0.game.cards.map { $0.id == 0 ? Card(id: 0, art: $0.art, isFaceUp: true) : $0 }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(1))) {
                $0.game.cards = $0.game.cards.map { $0.id == 1 ? Card(id: 1, art: $0.art, isFaceUp: true) : $0 }
                $0.game.moves = 1
            },
            .receive(.game(.save)),
            .send(.configuration(.selectArt(.cave))) {
                $0.configuration.selectedArts = Set(Art.allCases)
            },
            // As game has started, we shouldn't receive a .game(.new) action anymore
            .do { self.scheduler.advance(by: .seconds(2)) },
            .receive(.configuration(.save))
        )
    }

    func testSavingConfiguration() {
        let expectingSaveConfigurationToBeCalled = expectation(description: "Expect save configuration to be called")
        let mockedSaveConfiguration: (ConfigurationState) -> Void = { _ in
            expectingSaveConfigurationToBeCalled.fulfill()
        }
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler) {
                $0.saveConfiguration = mockedSaveConfiguration
            }
        )
        store.assert(
            .send(.configuration(.save))
        )
        wait(for: [expectingSaveConfigurationToBeCalled], timeout: 0.1)
    }

    func testLoadConfiguration() {
        let expectingLoadConfigurationToBeCalled = expectation(description: "Expect load configuration to be called")
        let mockedLoadConfiguration: () -> ConfigurationState = {
            expectingLoadConfigurationToBeCalled.fulfill()
            return ConfigurationState()
        }
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler) {
                $0.loadConfiguration = mockedLoadConfiguration
            }
        )
        store.assert(
            .send(.configuration(.load)),
            .receive(.game(.shuffleCards)) {
                $0.game.cards = .predicted
            }
        )
        wait(for: [expectingLoadConfigurationToBeCalled], timeout: 0.1)
    }

    func testShuffleCardWithNewDifficultyLevelConfigured() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert(
            .send(.game(.new)),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.cards = .predicted(level: .normal)
            },
            .send(.configuration(.changeDifficultyLevel(.easy))) {
                $0.configuration.difficultyLevel = .easy
            },
            .receive(.configuration(.save)),
            .receive(.game(.new)),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.level = .easy
                $0.game.cards = .predicted(level: .easy)
            }
        )
    }

    func testConfiguringDifficultyLevelStartNewGameWhenGameHasNotStartedYet() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert(
            .send(.configuration(.changeDifficultyLevel(.easy))) {
                $0.configuration.difficultyLevel = .easy
            },
            .receive(.configuration(.save)),
            .receive(.game(.new)),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.cards = .predicted(level: .easy)
                $0.game.level = .easy
            },

            .send(.game(.cardReturned(0))) {
                $0.game.cards = $0.game.cards.map { $0.id == 0 ? Card(id: 0, art: $0.art, isFaceUp: true) : $0 }
            },
            .receive(.game(.save)),
            .send(.configuration(.changeDifficultyLevel(.normal))) {
                $0.configuration.difficultyLevel = .normal
            },
            .receive(.configuration(.save)),
            .receive(.game(.new)) {
                $0.game.cards = $0.game.cards.map { Card(id: $0.id, art: $0.art, isFaceUp: false) }
            },
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.cards = .predicted(level: .normal)
                $0.game.level = .normal
            },

            .send(.game(.cardReturned(0))) {
                $0.game.cards = $0.game.cards.map { $0.id == 0 ? Card(id: 0, art: $0.art, isFaceUp: true) : $0 }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(1))) {
                $0.game.cards = $0.game.cards.map { $0.id == 1 ? Card(id: 1, art: $0.art, isFaceUp: true) : $0 }
                $0.game.moves = 1
            },
            .receive(.game(.save)),
            .send(.configuration(.changeDifficultyLevel(.hard))) {
                $0.configuration.difficultyLevel = .hard
            },
            .receive(.configuration(.save)),
            // As game has already started, we shouldn't receive a .game(.new) action anymore
            // But instead we will receive the disclaimer about starting a new game
            .receive(.presentDifficultyLevelHasChanged) {
                $0.isDifficultyLevelHasChangedPresented = true
            }
        )
    }

    func testChangingLevelWillDisplayADisclaimerMessageAskingToSetANewGame() {
        let store = TestStore(
            initialState: .mocked {
                $0.game.moves = 42
            },
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.configuration(.changeDifficultyLevel(.easy))) {
                $0.configuration.difficultyLevel = .easy
            },
            .receive(.configuration(.save)),
            .receive(.presentDifficultyLevelHasChanged) {
                $0.isDifficultyLevelHasChangedPresented = true
            }
        )
    }
}

extension AppEnvironment {
    static func mocked(
        scheduler: TestSchedulerOf<DispatchQueue>,
        modifier: (inout Self) -> Void = { _ in }
    ) -> Self {
        var appEnvironment = AppEnvironment(
            mainQueue: scheduler.eraseToAnyScheduler(),
            saveGame: { _ in },
            loadGame: { GameState() },
            clearGameBackup: { },
            loadHighScores: { [] },
            saveHighScores: { _ in },
            generateRandomCards: { _, level in .predicted(level: level) },
            saveConfiguration: { _ in },
            loadConfiguration: { ConfigurationState() }
        )
        modifier(&appEnvironment)
        return appEnvironment
    }
}
