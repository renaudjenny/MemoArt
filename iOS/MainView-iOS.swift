#if !os(macOS)
import SwiftUI
import ComposableArchitecture
import RenaudJennyAboutView

struct MainView: View {
    let store: Store<AppState, AppAction>
    @State private var isConfigurationNavigationActive = false
    @State private var isAboutNavigationActive = false
    @State private var isHighScoresNavigationActive = false

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    VStack {
                        GameModeView(store: store.gameStore)
                        Spacer()
                        AdaptiveGrid(store: store.gameStore)
                            .padding()
                        Spacer()
                    }

                    GameOverView(store: store.gameStore)
                        .padding()
                        .background(
                            Color.white.opacity(80/100).blur(radius: 5)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar(moves: viewStore.game.moves) }
                .background(navigation(highScorePreselectedLevel: viewStore.game.level))
                .background(GameBackground(store: store.gameStore))
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

    private func toolbar(moves: Int) -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                Text("Moves: \(moves)")
            }

            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    isAboutNavigationActive = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel(Text("About"))
                .accessibilityIdentifier("about")

                Button {
                    isConfigurationNavigationActive = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel(Text("Configuration"))
                .accessibilityIdentifier("configuration")
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NewGameButton(store: store.gameStore)
                Button {
                    isHighScoresNavigationActive = true
                } label: {
                    Image(systemName: "list.number")
                }
                .accessibility(label: Text("High Scores"))
                .accessibility(identifier: "high_scores")
            }
        }
    }

    private func navigation(highScorePreselectedLevel: DifficultyLevel) -> some View {
        VStack {
            NavigationLink(
                destination: ConfigurationView(store: store.configurationStore),
                isActive: $isConfigurationNavigationActive,
                label: EmptyView.init
            )
            NavigationLink(
                destination: aboutView,
                isActive: $isAboutNavigationActive,
                label: EmptyView.init
            )
            NavigationLink(
                destination: HighScoresView(store: store.highScoresStore, preselectedLevel: highScorePreselectedLevel),
                isActive: $isHighScoresNavigationActive,
                label: EmptyView.init
            )
        }
    }

    private var aboutView: some View {
        AboutView(
            appId: "id1536330844",
            logo: {
                Image("Pixel Art")
                    .resizable()
                    .modifier(AddCardStyle(foregroundColor: .red))
                    .frame(width: 120, height: 120)

            }
        )
        .background(
            Image("Motif")
                .resizable(resizingMode: .tile)
                .renderingMode(.template)
                .opacity(1/10)
                .ignoresSafeArea()
        )
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
                $0.game.discoveredArts = Art.allCases
                $0.game.moves = 42
                $0.game.cards = .predicted(isFaceUp: true)
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
