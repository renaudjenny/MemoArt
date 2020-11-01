import ComposableArchitecture
import Combine

struct AppState: Equatable {
    var game = GameState()
    var highScores = HighScoresState()
    var isNewHighScoreEntryPresented = false
}

enum AppAction: Equatable {
    case game(GameAction)
    case highScores(HighScoresAction)
    case presentNewHighScoreView
    case newHighScoreEntered
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var loadHighScores: () -> [HighScore]
    var saveHighScores: ([HighScore]) -> Void
    var generateRandomSymbols: () -> [Symbol]
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    gameReducer.pullback(
        state: \.game,
        action: /AppAction.game,
        environment: { GameEnvironment(mainQueue: $0.mainQueue, generateRandomSymbols: $0.generateRandomSymbols) }
    ),
    highScoresReducer.pullback(
        state: \.highScores,
        action: /AppAction.highScores,
        environment: { HighScoresEnvironment(load: $0.loadHighScores, save: $0.saveHighScores) }
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
        case .presentNewHighScoreView:
            state.isNewHighScoreEntryPresented = true
            return .none
        case .newHighScoreEntered:
            state.isNewHighScoreEntryPresented = false
            return .none
        case .game: return .none
        case .highScores: return .none
        }
    }
)
