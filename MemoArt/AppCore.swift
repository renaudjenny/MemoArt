import ComposableArchitecture

struct AppState: Equatable {
    var game = GameState()
}

enum AppAction: Equatable {
    case game(GameAction)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    gameReducer.pullback(
        state: \.game,
        action: /AppAction.game,
        environment: { GameEnvironment(mainQueue: $0.mainQueue) }
    )
)
