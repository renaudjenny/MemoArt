#if os(macOS)
import SwiftUI
import ComposableArchitecture
import RenaudJennyAboutView

struct MainView: View {
    let store: Store<AppState, AppAction>
    @State private var isConfigurationPresented = false
    @State private var isHighScoresPresented = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Moves: \(viewStore.game.moves)")
                    .font(.title)
                    .padding()
                    .padding(.top)
                    .animation(nil)
                GameOverView(store: store.gameStore)
                LazyVGrid(columns: columns) {
                    ForEach(0..<20) {
                        CardView(store: store.gameStore, id: $0)
                    }
                }
                .padding()
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
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
                    store: store.configurationStore,
                    isPresented: $isConfigurationPresented
                )
            })
            .background(EmptyView().sheet(isPresented: $isHighScoresPresented) {
                HighScoresSheetView(
                    store: store.highScoresStore,
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
            .background(
                Image("Motif")
                    .resizable(resizingMode: .tile)
                    .renderingMode(.template)
                    .opacity(1/10)
            )
            .onAppear { NSWindow.allowsAutomaticWindowTabbing = false }
        }
    }

    private let columns = Array(repeating: GridItem(.flexible(minimum: 50, maximum: 125)), count: 5)
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
                $0.game.discoveredSymbolTypes = SymbolType.allCases
                $0.game.moves = 42
                $0.game.symbols = .predictedGameSymbols(isCardsFaceUp: true)
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
