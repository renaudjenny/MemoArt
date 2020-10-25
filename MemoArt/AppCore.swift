import ComposableArchitecture

struct AppState: Equatable {
    var game = GameState()
    var highScores = HighScoresState()
}

enum AppAction: Equatable {
    case game(GameAction)
    case highScores(HighScoresAction)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var loadHighScores: () -> [HighScore]
    var saveHighScores: ([HighScore]) -> Void
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
    )
)
