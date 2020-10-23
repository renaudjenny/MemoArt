import SwiftUI
import ComposableArchitecture

@main
struct MemoArtApp: App {
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
    )

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
