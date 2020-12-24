#if os(macOS)
import SwiftUI
import ComposableArchitecture
import RenaudJennyAboutView

struct MainView: View {
    let store: Store<AppState, AppAction>
    @State private var isConfigurationPresented = false
    @State private var isHighScoresPresented = false
    @State private var isNewGameAlertPresented = false
    @State private var isDifficultyLevelAlertPresented = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Moves: \(viewStore.game.moves)")
                    .font(.title)
                    .padding()
                    .padding(.top)
                    .animation(nil)
                GameOverView(store: store.gameStore)
                LazyHGrid(rows: gridItems) {
                    ForEach(viewStore.game.cards) {
                        GameCardView(store: store.gameStore, card: $0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem {
                    NewGameButton(store: store.gameStore, isNewGameAlertPresented: $isNewGameAlertPresented)
                }
                ToolbarItem {
                    Button {
                        isConfigurationPresented = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibility(label: Text("Configuration"))
                }
                ToolbarItem {
                    Button {
                        isHighScoresPresented = true
                    } label: {
                        Image(systemName: "list.number")
                    }
                    .accessibility(label: Text("High Scores"))
                }
            }
            .background(EmptyView().sheet(isPresented: $isConfigurationPresented) {
                ConfigurationSheetView(
                    store: store,
                    isPresented: $isConfigurationPresented
                )
            })
            .background(EmptyView().sheet(isPresented: $isHighScoresPresented) {
                HighScoresSheetView(
                    store: store.highScoresStore,
                    preselectedLevel: viewStore.game.level,
                    isPresented: $isHighScoresPresented
                )
            })
            .background(EmptyView().sheet(
                isPresented: viewStore.binding(
                    get: { $0.isNewHighScoreEntryPresented },
                    send: .newHighScoreEntered
                ),
                content: {
                    NewHighScoreView(store: store)
                        .padding()
                }
            ))
            .modifier(SetupNewGameAlert(
                store: store.gameStore,
                isPresented: $isNewGameAlertPresented
            ))
            .background(
                Image("Motif")
                    .resizable(resizingMode: .tile)
                    .renderingMode(.template)
                    .opacity(1/10)
            )
            .onAppear { NSWindow.allowsAutomaticWindowTabbing = false }
        }
    }

    private let gridItems = Array(repeating: GridItem(.flexible(minimum: 50, maximum: 150)), count: 4)
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .preview
        ))
    }
}

struct MainViewGameOver_Previews: PreviewProvider {
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

struct MainViewAlmostFinished_Previews: PreviewProvider {
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
