#if os(macOS)
import SwiftUI
import ComposableArchitecture
import RenaudJennyAboutView

struct MainView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                GameOverView(store: store.gameStore)
                LazyVGrid(columns: columns) {
                    ForEach(0..<20) {
                        CardView(store: store.gameStore, id: $0)
                    }
                }
                .padding()
            }
            .onAppear(perform: { viewStore.send(.highScores(.load)) })
        }
    }

    private let columns = Array(repeating: GridItem(.flexible(minimum: 50, maximum: 125)), count: 5)
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .preview
        ))
    }
}

struct ContentViewGameOver_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store<AppState, AppAction>(
            initialState: .mocked {
                $0.game.isGameOver = true
                $0.game.discoveredSymbolTypes = SymbolType.allCases
                $0.game.moves = 42
                $0.game.symbols = .predictedGameSymbols(isCardsFaceUp: true)
            },
            reducer: appReducer,
            environment: .preview
        ))
    }
}

struct ContentViewAlmostFinished_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(
            initialState: .almostFinishedGame,
            reducer: appReducer,
            environment: .preview
        ))
    }
}
#endif
#endif
