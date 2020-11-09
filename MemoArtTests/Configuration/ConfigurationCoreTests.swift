import XCTest
@testable import MemoArt
import ComposableArchitecture

class ConfigurationCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler

    func testUnselectSymbolType() {
        let store = TestStore(
            initialState: ConfigurationState(),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(mainQueue: scheduler.eraseToAnyScheduler())
        )
        store.assert(
            .send(.unselectSymbolType(.cave)) {
                $0.selectedSymbolTypes = Set(SymbolType.allCases.filter({ $0 != .cave }))
            }
        )
    }

    func testSelectSymbolType() {
        let store = TestStore(
            initialState: .allSymbolsButCave,
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(mainQueue: scheduler.eraseToAnyScheduler())
        )
        store.assert(
            .send(.selectSymbolType(.cave)) {
                $0.selectedSymbolTypes = Set(SymbolType.allCases)
            }
        )
    }

    func testUnselectSymbolTypeWhenThereIsOnlyTenRemainingSelectedSymbolTypes() {
        let store = TestStore(
            initialState: .onlyTenSelectedSymbolTypes,
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(mainQueue: scheduler.eraseToAnyScheduler())
        )
        store.assert(
            .send(.unselectSymbolType(.cave))
        )
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
