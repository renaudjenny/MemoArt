#if !os(macOS)
import SwiftUI
import ComposableArchitecture

struct MainView: View {
    let store: Store<AppState, AppAction>
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                stackOrScroll {
                    GameOverView(store: store.gameStore)
                    LazyVGrid(columns: columns) {
                        ForEach(0..<20) {
                            CardView(store: store.gameStore, id: $0)
                        }
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("MemoArt").font(.headline)
                            Text("Moves: \(viewStore.game.moves)").font(.subheadline)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            AboutNavigationLink()
                            ConfigurationNavigationLink(store: store.configurationStore)
                                .padding(.leading)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HighScoresNavigationLink(store: store.highScoresStore)
                    }
                }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.isNewHighScoreEntryPresented },
                    send: .newHighScoreEntered
                ),
                content: { NewHighScoreView(store: store) }
            )
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    var columns: [GridItem] {
        let gridItemPattern = GridItem(.flexible(minimum: 50, maximum: 125))
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular):
            // 4x5 Grid
            return Array(repeating: gridItemPattern, count: 4)
        case (.compact, .compact):
            // 7x3 Grid
            return Array(repeating: gridItemPattern, count: 7)
        case (.regular, .regular):
            // 5x4 Grid, bigger images
            return Array(repeating: gridItemPattern, count: 5)
        default:
            return [GridItem(.adaptive(minimum: 100))]
        }
    }

    @ViewBuilder
    private func stackOrScroll<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular): VStack { content() }
        default: ReversedScrollView { content() }
        }
    }
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
