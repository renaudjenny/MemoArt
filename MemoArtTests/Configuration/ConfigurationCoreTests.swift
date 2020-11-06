import XCTest
@testable import MemoArt
import ComposableArchitecture

class ConfigurationCoreTests: XCTestCase {
    func testUnselectSymbolType() {
        let store = TestStore(
            initialState: ConfigurationState(),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment()
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
            environment: ConfigurationEnvironment()
        )
        store.assert(
            .send(.selectSymbolType(.cave)) {
                $0.selectedSymbolTypes = Set(SymbolType.allCases)
            }
        )
    }
}

extension ConfigurationState {
    static var allSymbolsButCave: Self {
        ConfigurationState(
            selectedSymbolTypes: Set(SymbolType.allCases.filter({ $0 != .cave }))
        )
    }
}
