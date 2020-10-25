import SwiftUI
import ComposableArchitecture

@main
struct MemoArtApp: App {
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            loadHighScores: loadHighScores,
            saveHighScores: saveHighScores
        )
    )

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

// MARK: High Scores Persistence
extension MemoArtApp {
    private static let highScoresKey = "MemoArtHighScores"

    private static func loadHighScores() -> [HighScore] {
        UserDefaults.standard.array(forKey: highScoresKey) as? [HighScore] ?? []
    }

    private static func saveHighScores(highScores: [HighScore]) -> Void {
        UserDefaults.standard.setValue(highScores, forKey: highScoresKey)
    }
}
