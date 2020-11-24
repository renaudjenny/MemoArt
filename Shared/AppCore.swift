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
    var saveGame: (GameState) -> Void
    var loadGame: () -> GameState
    var clearGameBackup: () -> Void
    var loadHighScores: () -> [HighScore]
    var saveHighScores: ([HighScore]) -> Void
    var generateRandomCards: (Set<Art>) -> [Card]
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
            state.game.cards = environment.generateRandomCards(state.configuration.selectedArts)
            return .none
        case .presentNewHighScoreView:
            state.isNewHighScoreEntryPresented = true
            return .none
        case .newHighScoreEntered:
            state.isNewHighScoreEntryPresented = false
            return .none
        case .configuration(.selectArt), .configuration(.unselectArt):
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

    static let almostFinishedGame: Self = .mocked {
        $0.game.isGameOver = false
        $0.game.discoveredArts = Art.allCases.filter({ $0 != .cave })
        $0.game.moves = 142
        $0.game.cards = [Card].predicted(isFaceUp: true).map {
            if $0.art == .cave {
                return Card(id: $0.id, art: $0.art, isFaceUp: false)
            }
            return $0
        }
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
        generateRandomCards: { _ in .predicted },
        saveConfiguration: { _ in },
        loadConfiguration: { ConfigurationState() }
    )
}
#endif
