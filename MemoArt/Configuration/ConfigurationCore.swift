import ComposableArchitecture

struct ConfigurationState: Equatable {
    var selectedSymbolTypes: Set<SymbolType> = Set(SymbolType.allCases)
}

enum ConfigurationAction: Equatable {
    case unselectSymbolType(SymbolType)
    case selectSymbolType(SymbolType)
}

struct ConfigurationEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let configurationReducer = Reducer<
    ConfigurationState,
    ConfigurationAction,
    ConfigurationEnvironment
> { state, action, _ in
    switch action {
    case let .unselectSymbolType(symbol):
        // TODO: prevent user from unselect too much cards (this should always be >= 10)
        state.selectedSymbolTypes = state.selectedSymbolTypes.filter({ $0 != symbol })
        return .none
    case let .selectSymbolType(symbol):
        state.selectedSymbolTypes.insert(symbol)
        return .none
    }
}
