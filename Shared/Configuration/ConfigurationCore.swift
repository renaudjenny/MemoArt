import ComposableArchitecture

struct ConfigurationState: Equatable, Codable {
    var selectedSymbolTypes: Set<SymbolType> = Set(SymbolType.allCases)
}

enum ConfigurationAction: Equatable {
    case unselectSymbolType(SymbolType)
    case selectSymbolType(SymbolType)
    case save
    case load
}

struct ConfigurationEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var save: (ConfigurationState) -> Void
    var load: () -> ConfigurationState
}

private let saveDebounceId = "Configuration Save Debounce"

let configurationReducer = Reducer<
    ConfigurationState,
    ConfigurationAction,
    ConfigurationEnvironment
> { state, action, environment in
    switch action {
    case let .unselectSymbolType(symbol):
        guard state.selectedSymbolTypes.count > 10 else { return .none }

        state.selectedSymbolTypes = state.selectedSymbolTypes.filter({ $0 != symbol })
        return Effect(value: .save)
            .debounce(id: saveDebounceId, for: .seconds(2), scheduler: environment.mainQueue)
            .eraseToEffect()
    case let .selectSymbolType(symbol):
        state.selectedSymbolTypes.insert(symbol)
        return Effect(value: .save)
            .debounce(id: saveDebounceId, for: .seconds(2), scheduler: environment.mainQueue)
            .eraseToEffect()
    case .save:
        environment.save(state)
        return .none
    case .load:
        state = environment.load()
        return .none
    }
}
