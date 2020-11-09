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
            saveHighScores: saveHighScores,
            generateRandomSymbols: { .newGameSymbols(from: $0) }
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
        guard
            let data = UserDefaults.standard.data(forKey: highScoresKey),
            let highScores = try? JSONDecoder().decode([HighScore].self, from: data)
        else { return [] }

        return highScores
    }

    private static func saveHighScores(highScores: [HighScore]) {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(highScores), forKey: highScoresKey)
    }
}
