import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    let columns = [GridItem(.adaptive(minimum: 65))]

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.game.isGameOver {
                    Text("⭐️ Bravo! ⭐️").font(.largeTitle)
                    Text("Game Over")
                }
                Text("Moves: \(viewStore.game.moves)")
                LazyVGrid(columns: columns) {
                    ForEach(0..<20) {
                        CardView(store: store.scope(state: { $0.game }, action: AppAction.game), id: $0)
                    }
                }
                if viewStore.game.isGameOver {
                    Button(action: { viewStore.send(.game(.new)) }) {
                        Text("New game")
                    }
                    .padding()
                }
            }
            .padding()
            .onAppear { viewStore.send(.game(.new)) }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
        ))
    }
}

struct ContentViewGameOver_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store<AppState, AppAction>(
            initialState: .mocked {
                $0.game.isGameOver = true
                $0.game.discoveredSymbolTypes = SymbolType.allCases
                $0.game.moves = 42
            },
            reducer: appReducer,
            environment: AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
        ))
    }
}

extension AppState {
    static func mocked(modifier: (inout Self) -> Void) -> Self {
        var state = AppState()
        modifier(&state)
        return state
    }
}
#endif
