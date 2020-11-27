import ComposableArchitecture

struct ConfigurationState: Equatable, Codable {
    var selectedArts: Set<Art> = Set(Art.allCases)
}

enum ConfigurationAction: Equatable {
    case unselectArt(Art)
    case selectArt(Art)
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
    case let .unselectArt(art):
        guard state.selectedArts.count > 10 else { return .none }

        state.selectedArts = state.selectedArts.filter({ $0 != art })
        return Effect(value: .save)
            .debounce(id: saveDebounceId, for: .seconds(2), scheduler: environment.mainQueue)
            .eraseToEffect()
    case let .selectArt(art):
        state.selectedArts.insert(art)
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
