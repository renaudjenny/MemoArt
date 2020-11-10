import XCTest
@testable import MemoArt
import ComposableArchitecture

class ConfigurationCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler

    func testUnselectSymbolType() {
        let store = TestStore(
            initialState: ConfigurationState(),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                save: { _ in },
                load: { ConfigurationState() }
            )
        )
        store.assert(
            .send(.unselectSymbolType(.cave)) {
                $0.selectedSymbolTypes = Set(SymbolType.allCases.filter({ $0 != .cave }))
            },
            .do { self.scheduler.advance(by: .seconds(2)) },
            .receive(.save)
        )
    }

    func testSelectSymbolType() {
        let store = TestStore(
            initialState: .allSymbolsButCave,
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                save: { _ in },
                load: { ConfigurationState() }
            )
        )
        store.assert(
            .send(.selectSymbolType(.cave)) {
                $0.selectedSymbolTypes = Set(SymbolType.allCases)
            },
            .do { self.scheduler.advance(by: .seconds(2)) },
            .receive(.save)
        )
    }

    func testUnselectSymbolTypeWhenThereIsOnlyTenRemainingSelectedSymbolTypes() {
        let store = TestStore(
            initialState: .onlyTenSelectedSymbolTypes,
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                save: { _ in },
                load: { ConfigurationState() }
            )
        )
        store.assert(
            .send(.unselectSymbolType(.cave))
        )
        // Do not receive .save here, it's not necessary
    }
}

extension ConfigurationState {
    static var allSymbolsButCave: Self {
        ConfigurationState(
            selectedSymbolTypes: Set(SymbolType.allCases.filter({ $0 != .cave }))
        )
    }

    static var onlyTenSelectedSymbolTypes: Self {
        ConfigurationState(
            selectedSymbolTypes: Set(SymbolType.allCases.prefix(10))
        )
    }
}
