import ComposableArchitecture
import Combine

struct AppState: Equatable {
    var game = GameState()
    var highScores = HighScoresState()
    var configuration = ConfigurationState()
    var isNewHighScoreEntryPresented = false
}

enum AppAction: Equatable {
    case game(GameAction)
    case highScores(HighScoresAction)
    case configuration(ConfigurationAction)
    case presentNewHighScoreView
    case newHighScoreEntered
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var loadHighScores: () -> [HighScore]
    var saveHighScores: ([HighScore]) -> Void
    var generateRandomSymbols: (Set<SymbolType>) -> [Symbol]
    var saveConfiguration: (ConfigurationState) -> Void
    var loadConfiguration: () -> ConfigurationState
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    gameReducer.pullback(
        state: \.game,
        action: /AppAction.game,
        environment: { GameEnvironment(mainQueue: $0.mainQueue) }
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
            if state.game.isGameOver {
                let presentNewHighScoreEffect = Just(AppAction.presentNewHighScoreView)
                    .delay(for: .seconds(0.8), scheduler: environment.mainQueue)
                    .eraseToEffect()

                if state.highScores.scores.count < 10 {
                    return presentNewHighScoreEffect
                }

                let moves = state.game.moves
                let worstHighScoreMoves: Int = state.highScores.scores.last?.score ?? .max
                if moves <= worstHighScoreMoves {
                    return presentNewHighScoreEffect
                }
            }
            return .none
        case .game(.shuffleCards):
            state.game.symbols = environment.generateRandomSymbols(state.configuration.selectedSymbolTypes)
            return .none
        case .presentNewHighScoreView:
            state.isNewHighScoreEntryPresented = true
            return .none
        case .newHighScoreEntered:
            state.isNewHighScoreEntryPresented = false
            return .none
        case .configuration(.selectSymbolType), .configuration(.unselectSymbolType):
            if state.game.moves <= 0 {
                return Effect(value: .game(.new))
            }
            return .none
        case .configuration(.load):
            return Effect(value: .game(.shuffleCards))
        case .game: return .none
        case .highScores: return .none
        case .configuration: return .none
        }
    }
)
