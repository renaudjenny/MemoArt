import XCTest
@testable import MemoArt
import ComposableArchitecture

class AppCoreTests: XCTestCase {
    let testScheduler = DispatchQueue.testScheduler

    func testDoNotPresentNewHighScoreWhenTheGameIsNotFinished() throws {
        let store = TestStore(
            initialState: AppState.mocked {
                $0.game.symbols = .predictedGameSymbols
            },
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: testScheduler.eraseToAnyScheduler(),
                loadHighScores: { [] },
                saveHighScores: { _ in },
                generateRandomSymbols: { _ in .predictedGameSymbols }
            )
        )

        store.assert(
            .send(.game(.cardReturned(0))) {
                $0.game.symbols = $0.game.symbols.map { symbol in
                    switch symbol.id {
                    case 0: return Symbol(id: 0, type: .artDeco, isFaceUp: true)
                    default: return symbol
                    }
                }
            }
        )
    }

    func testPresentNewHighScoreForAnEmptyHighScoresBoard() throws {
        let store = TestStore(
            initialState: AppState.almostFinishedGame,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: testScheduler.eraseToAnyScheduler(),
                loadHighScores: { [] },
                saveHighScores: { _ in },
                generateRandomSymbols: { _ in .predictedGameSymbols }
            )
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
            .do { self.testScheduler.advance(by: .seconds(0.8)) },
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
            environment: AppEnvironment(
                mainQueue: testScheduler.eraseToAnyScheduler(),
                loadHighScores: { [] },
                saveHighScores: { _ in },
                generateRandomSymbols: { _ in .predictedGameSymbols }
            )
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
            .do { self.testScheduler.advance(by: .seconds(0.8)) },
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
            environment: AppEnvironment(
                mainQueue: testScheduler.eraseToAnyScheduler(),
                loadHighScores: { [] },
                saveHighScores: { _ in },
                generateRandomSymbols: { _ in .predictedGameSymbols }
            )
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
            }
        )
    }

    func testEnteringANewHighScore() {
        let store = TestStore(
            initialState: AppState.mocked {
                $0.isNewHighScoreEntryPresented = true
            },
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: testScheduler.eraseToAnyScheduler(),
                loadHighScores: { [] },
                saveHighScores: { _ in },
                generateRandomSymbols: { _ in .predictedGameSymbols }
            )
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
            environment: AppEnvironment(
                mainQueue: testScheduler.eraseToAnyScheduler(),
                loadHighScores: { [] },
                saveHighScores: { _ in },
                generateRandomSymbols: { _ in .predictedGameSymbols(from: selectedSymbolTypes) }
            )
        )
        store.assert(
            .send(.game(.shuffleCards)) {
                $0.game.symbols = .predictedGameSymbols(from: selectedSymbolTypes)
            }
        )
    }
}
