import ComposableArchitecture
import Combine

struct AppState: Equatable {
    var game = GameState()
    var highScores = HighScoresState()
    var configuration = ConfigurationState()
    var isNewHighScoreEntryPresented = false
    var isTwoPlayersScoresPresented = false
    var isAboutPresented = false
}

enum AppAction: Equatable {
    case game(GameAction)
    case highScores(HighScoresAction)
    case configuration(ConfigurationAction)
    case presentNewHighScoreView
    case newHighScoreEntered
    case presentTwoPlayersScoresView
    case hideTwoPlayersScoresView
    case presentAbout
    case hideAbout
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var saveGame: (GameState) -> Void
    var loadGame: () -> GameState
    var clearGameBackup: () -> Void
    var loadHighScores: () -> HighScoresState
    var saveHighScores: (HighScoresState) -> Void
    var generateRandomCards: (Set<Art>, DifficultyLevel) -> [Card]
    var saveConfiguration: (ConfigurationState) -> Void
    var loadConfiguration: () -> ConfigurationState
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    gameReducer.pullback(
        state: \.game,
        action: /AppAction.game,
        environment: { GameEnvironment(
            mainQueue: $0.mainQueue,
            save: $0.saveGame,
            load: $0.loadGame,
            clearBackup: $0.clearGameBackup
        ) }
    ),
    highScoresReducer.pullback(
        state: \.highScores,
        action: /AppAction.highScores,
        environment: { HighScoresEnvironment(load: $0.loadHighScores, save: $0.saveHighScores) }
    ),
    configurationReducer.pullback(
        state: \.configuration,
        action: /AppAction.configuration,
        environment: { ConfigurationEnvironment(
            mainQueue: $0.mainQueue,
            save: $0.saveConfiguration,
            load: $0.loadConfiguration
        ) }
    ),
    Reducer { state, action, environment in
        switch action {
        case .game(.cardReturned):
            guard state.game.isGameOver else { return .none }
            switch state.game.mode {
            case .singlePlayer:
                let presentNewHighScoreEffect = Just(AppAction.presentNewHighScoreView)
                    .delay(for: .seconds(0.8), scheduler: environment.mainQueue)
                    .eraseToEffect()

                let currentLevelHighScores = state.highScores.boards.highScores(level: state.game.level)
                if currentLevelHighScores.count < 10 {
                    return presentNewHighScoreEffect
                }

                let moves = state.game.moves
                let worstHighScoreMoves: Int = currentLevelHighScores.last?.score ?? .max
                if moves <= worstHighScoreMoves {
                    return presentNewHighScoreEffect
                }
                return .none
            case .twoPlayers:
                return Effect(value: .presentTwoPlayersScoresView)
            }
        case .game(.shuffleCards):
            state.game.level = state.configuration.difficultyLevel
            state.game.cards = environment.generateRandomCards(
                state.configuration.selectedArts,
                state.game.level
            )
            return .none
        case .presentNewHighScoreView:
            state.isNewHighScoreEntryPresented = true
            return .none
        case .newHighScoreEntered:
            state.isNewHighScoreEntryPresented = false
            return .none
        case .presentTwoPlayersScoresView:
            state.isTwoPlayersScoresPresented = true
            return .none
        case .hideTwoPlayersScoresView:
            state.isTwoPlayersScoresPresented = false
            return .none
        case .configuration(.selectArt), .configuration(.unselectArt):
            if state.game.moves <= 0 {
                return Effect(value: .game(.new))
            }
            return .none
        case .configuration(.changeDifficultyLevel):
            if state.game.moves <= 0 {
                return Effect(value: .game(.new))
            }
            return Effect(value: .configuration(.presentChangeLevelAlert))
        case .configuration(.changeLevelAlertConfirmTapped):
            return Effect(value: .game(.new))
        case .configuration(.load):
            return Effect(value: .game(.shuffleCards))
        case .presentAbout:
            state.isAboutPresented = true
            return .none
        case .hideAbout:
            state.isAboutPresented = false
            return .none
        case .game: return .none
        case .highScores: return .none
        case .configuration: return .none
        }
    }
)

extension Store where State == AppState, Action == AppAction {
    var gameStore: Store<GameState, GameAction> {
        scope(state: { $0.game }, action: AppAction.game)
    }
    var configurationStore: Store<ConfigurationState, ConfigurationAction> {
        scope(state: { $0.configuration }, action: AppAction.configuration)
    }
    var highScoresStore: Store<HighScoresState, HighScoresAction> {
        scope(state: { $0.highScores }, action: AppAction.highScores)
    }
}

#if DEBUG
extension AppState {
    static func mocked(modifier: (inout Self) -> Void) -> Self {
        var state = AppState()
        modifier(&state)
        return state
    }

    static let almostFinishedGame: Self = .almostFinishedGame(modifier: { _ in })

    static func almostFinishedGame(modifier: (inout Self) -> Void) -> Self {
        var state: AppState = .mocked { $0.game = .almostFinishedGame }
        modifier(&state)
        return state
    }
}

extension AnyScheduler
where
    SchedulerTimeType == DispatchQueue.SchedulerTimeType,
    SchedulerOptions == DispatchQueue.SchedulerOptions {
    static var preview: Self { DispatchQueue.main.eraseToAnyScheduler() }
}

extension AppEnvironment {
    static let preview: Self = AppEnvironment(
        mainQueue: .preview,
        saveGame: { _ in },
        loadGame: { GameState() },
        clearGameBackup: { },
        loadHighScores: { .preview },
        saveHighScores: { _ in },
        generateRandomCards: { _, _ in .predicted },
        saveConfiguration: { _ in },
        loadConfiguration: { ConfigurationState() }
    )

    static let almostFinishedGame: Self = AppEnvironment(
        mainQueue: .preview,
        saveGame: { _ in },
        loadGame: { .almostFinishedGame },
        clearGameBackup: { },
        loadHighScores: { .miscellaneous },
        saveHighScores: { _ in },
        generateRandomCards: { _, _ in .predicted },
        saveConfiguration: { _ in },
        loadConfiguration: { ConfigurationState() }
    )
}

extension Store where State == AppState, Action == AppAction {
    static var almostFinishedGame: Self {
        Self(
            initialState: .almostFinishedGame,
            reducer: appReducer,
            environment: .almostFinishedGame
        )
    }
}
#endif
