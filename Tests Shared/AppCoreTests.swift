import XCTest
@testable import MemoArt
import ComposableArchitecture

// swiftlint:disable:next type_body_length
class AppCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler

    func testDoNotPresentNewHighScoreWhenTheGameIsNotFinished() throws {
        let store = TestStore(
            initialState: AppState.mocked {
                $0.game.symbols = .predictedGameSymbols
            },
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )

        store.assert(
            .send(.game(.cardReturned(0))) {
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 0: return Symbol(id: 0, type: .artDeco, isFaceUp: true)
                    default: return symbol
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
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 2: return Symbol(id: 2, type: .cave, isFaceUp: true)
                    default: return symbol
                    }
                }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(12))) {
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 12: return Symbol(id: 12, type: .cave, isFaceUp: true)
                    default: return symbol
                    }
                }
                $0.game.isGameOver = true
                $0.game.moves = 143
                $0.game.discoveredSymbolTypes = $0.game.discoveredSymbolTypes + [.cave]
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
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 2: return Symbol(id: 2, type: .cave, isFaceUp: true)
                    default: return symbol
                    }
                }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(12))) {
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 12: return Symbol(id: 12, type: .cave, isFaceUp: true)
                    default: return symbol
                    }
                }
                $0.game.isGameOver = true
                $0.game.moves = 11
                $0.game.discoveredSymbolTypes = $0.game.discoveredSymbolTypes + [.cave]
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
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 2: return Symbol(id: 2, type: .cave, isFaceUp: true)
                    default: return symbol
                    }
                }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(12))) {
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 12: return Symbol(id: 12, type: .cave, isFaceUp: true)
                    default: return symbol
                    }
                }
                $0.game.isGameOver = true
                $0.game.moves = 143
                $0.game.discoveredSymbolTypes = $0.game.discoveredSymbolTypes + [.cave]
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

    func testShuffleCardWithRestrictedSymbolTypes() {
        let selectedSymbolTypes: [SymbolType] = [
            .artDeco, .cave, .arty, .chalk, .childish,
            .destructured, .geometric, .gradient, .impressionism, .moderArt,
        ]

        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler) {
                $0.generateRandomSymbols = { _ in .predictedGameSymbols(from: selectedSymbolTypes) }
            }
        )
        store.assert(
            .send(.game(.shuffleCards)) {
                $0.game.symbols = .predictedGameSymbols(from: selectedSymbolTypes)
            }
        )
    }

    // swiftlint:disable:next function_body_length
    func testConfiguringSymbolTypesWillReshuffleCardWhenGameHasNotStartedYet() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler)
        )
        store.assert(
            .send(.configuration(.unselectSymbolType(.cave))) {
                $0.configuration.selectedSymbolTypes = Set(SymbolType.allCases.filter({ $0 != .cave }))
            },
            .receive(.game(.new)),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.symbols = .predictedGameSymbols
            },
            .do { self.scheduler.advance(by: .seconds(1.5)) },
            .receive(.configuration(.save)),
            .send(.configuration(.selectSymbolType(.cave))) {
                $0.configuration.selectedSymbolTypes = Set(SymbolType.allCases)
            },
            .receive(.game(.new)),
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.symbols = .predictedGameSymbols
            },
            .do { self.scheduler.advance(by: .seconds(1.5)) },
            .receive(.configuration(.save)),
            .send(.game(.cardReturned(0))) {
                $0.game.symbols = $0.game.symbols.map { $0.id == 0 ? Symbol(id: 0, type: $0.type, isFaceUp: true) : $0 }
            },
            .receive(.game(.save)),
            .send(.configuration(.unselectSymbolType(.cave))) {
                $0.configuration.selectedSymbolTypes = Set(SymbolType.allCases.filter({ $0 != .cave }))
            },
            .receive(.game(.new)) {
                $0.game.symbols = $0.game.symbols.map { Symbol(id: $0.id, type: $0.type, isFaceUp: false) }
            },
            .do { self.scheduler.advance(by: .seconds(0.5)) },
            .receive(.game(.shuffleCards)) {
                $0.game.symbols = .predictedGameSymbols
            },
            .do { self.scheduler.advance(by: .seconds(1.5)) },
            .receive(.configuration(.save)),
            .send(.game(.cardReturned(0))) {
                $0.game.symbols = $0.game.symbols.map { $0.id == 0 ? Symbol(id: 0, type: $0.type, isFaceUp: true) : $0 }
            },
            .receive(.game(.save)),
            .send(.game(.cardReturned(1))) {
                $0.game.symbols = $0.game.symbols.map { $0.id == 1 ? Symbol(id: 1, type: $0.type, isFaceUp: true) : $0 }
                $0.game.moves = 1
            },
            .receive(.game(.save)),
            .send(.configuration(.selectSymbolType(.cave))) {
                $0.configuration.selectedSymbolTypes = Set(SymbolType.allCases)
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
                $0.game.symbols = .predictedGameSymbols
            }
        )
        wait(for: [expectingLoadConfigurationToBeCalled], timeout: 0.1)
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
            generateRandomSymbols: { _ in .predictedGameSymbols },
            saveConfiguration: { _ in },
            loadConfiguration: { ConfigurationState() }
        )
        modifier(&appEnvironment)
        return appEnvironment
    }
}
