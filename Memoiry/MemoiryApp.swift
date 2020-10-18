import SwiftUI
import ComposableArchitecture

@main
struct MemoiryApp: App {
    let store = Store(
        initialState: AppState(),
        reducer: appReducer.debug(),
        environment: AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
    )

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
