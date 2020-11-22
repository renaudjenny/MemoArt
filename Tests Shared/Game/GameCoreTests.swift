import XCTest
@testable import MemoArt
import ComposableArchitecture

class GameCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler
    typealias Step = TestStore<GameState, GameState, GameAction, GameAction, GameEnvironment>.Step

    func testNewGame() {
        let store = TestStore(
            initialState: GameState(symbols: .predictedGameSymbols),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
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

    // swiftlint:disable:next cyclomatic_complexity
    func testReturningCards() {
        let store = TestStore(
            initialState: GameState(symbols: .predictedGameSymbols),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
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
            .receive(.save),
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
            .receive(.save),
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
            .receive(.save),
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
            },
            .receive(.save)
        )
    }

    func testFinishingAGame() {
        let store = TestStore(
            initialState: GameState(symbols: .predictedGameSymbols),
            reducer: gameReducer,
            environment: .mocked(scheduler: scheduler)
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
                .receive(.save),
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
                },
                .receive(cardId + 11 < 20 ? .save : .clearBackup),
            ]
        }

        store.assert(
            [
                .send(.shuffleCards) {
                    $0.symbols = .predictedGameSymbols
                },
            ]
            +
            returnAllCardsSteps
        )
    }

    func testSavingGame() {
        let expectingSaveGameToBeCalled = expectation(description: "Expect save game to be called")
        let mockedSaveGame: (GameState) -> Void = { _ in
            expectingSaveGameToBeCalled.fulfill()
        }
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler) {
                $0.saveGame = mockedSaveGame
            }
        )
        store.assert(
            .send(.game(.save))
        )
        wait(for: [expectingSaveGameToBeCalled], timeout: 0.1)
    }

    func testLoadGame() {
        let expectingLoadGameToBeCalled = expectation(description: "Expect load game to be called")
        let mockedGameState = GameState(
            moves: 42,
            symbols: .predictedGameSymbols,
            discoveredSymbolTypes: [.cave, .popArt],
            isGameOver: false
        )
        let mockedLoadGame: () -> GameState = {
            expectingLoadGameToBeCalled.fulfill()
            return mockedGameState
        }
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler) {
                $0.loadGame = mockedLoadGame
            }
        )
        store.assert(
            .send(.game(.load)) {
                $0.game = mockedGameState
            }
        )
        wait(for: [expectingLoadGameToBeCalled], timeout: 0.1)
    }

    func testClearBackup() {
        let expectingClearGameBackupToBeCalled = expectation(description: "Expect clear game backup to be called")
        let mockedClearGameBackup: () -> Void = {
            expectingClearGameBackupToBeCalled.fulfill()
        }
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .mocked(scheduler: scheduler) {
                $0.clearGameBackup = mockedClearGameBackup
            }
        )
        store.assert(
            .send(.game(.clearBackup))
        )
        wait(for: [expectingClearGameBackupToBeCalled], timeout: 0.1)
    }
}

extension GameEnvironment {
    static func mocked(
        scheduler: TestSchedulerOf<DispatchQueue>,
        modifier: (inout Self) -> Void = { _ in }
    ) -> Self {
        var gameEnvironment = GameEnvironment(
            mainQueue: scheduler.eraseToAnyScheduler(),
            save: { _ in },
            load: { GameState() },
            clearBackup: { }
        )
        modifier(&gameEnvironment)
        return gameEnvironment
    }
}
