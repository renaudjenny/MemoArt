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
        (try? JSONDecoder().decode([HighScore].self, from: UserDefaults.standard.data(forKey: highScoresKey) ?? Data())) ?? []
    }

    private static func saveHighScores(highScores: [HighScore]) -> Void {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(highScores), forKey: highScoresKey)
    }
}
