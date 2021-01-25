import ComposableArchitecture

struct ConfigurationState: Equatable, Codable {
    var selectedArts: Set<Art> = Set(Art.allCases)
    var difficultyLevel: DifficultyLevel = .normal
    var cardsCount: Int { difficultyLevel.cardsCount }
    var isPresented = false

    var changeLevelAlert: AlertState<ConfigurationAction>?

    private enum CodingKeys: CodingKey {
        case selectedArts, difficultyLevel
    }
}

enum ConfigurationAction: Equatable {
    case unselectArt(Art)
    case selectArt(Art)
    case save
    case load
    case changeDifficultyLevel(DifficultyLevel)
    case present
    case hide
    case presentChangeLevelAlert
    case changeLevelAlertCancelTapped
    case changeLevelAlertConfirmTapped
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
        guard state.selectedArts.count > state.difficultyLevel.cardsCount/2 else { return .none }

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
    case let .changeDifficultyLevel(difficultyLevel):
        state.difficultyLevel = difficultyLevel

        // Check if the number of selected arts are sufficient for the new selected difficulty level
        if state.selectedArts.count < difficultyLevel.cardsCount/2 {
            Art.allCases.forEach {
                if state.selectedArts.count >= difficultyLevel.cardsCount/2 { return }

                state.selectedArts.insert($0)
            }
        }

        return Effect(value: .save)
    case .present:
        state.isPresented = true
        return .none
    case .hide:
        state.isPresented = false
        return .none
    case .presentChangeLevelAlert:
        state.changeLevelAlert = AlertState(
            title: "Difficulty level changed",
            message: """
            You have just changed the difficulty level, but there is a game currently in progress
            Do you want to start a new game? You will loose your current progress then!
            """,
            primaryButton: .cancel(),
            secondaryButton: .destructive(
                "New game",
                send: .changeLevelAlertConfirmTapped
            )
        )
        return .none
    case .changeLevelAlertCancelTapped:
        state.changeLevelAlert = nil
        return .none
    case .changeLevelAlertConfirmTapped:
        state.changeLevelAlert = nil
        return .none
    }
}
