import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    let columns = [GridItem(.adaptive(minimum: 65))]

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    HStack {
                        Spacer()
                        NavigationLink(
                            destination: HighScoresView(store: store.scope(
                                state: { $0.highScores },
                                action: AppAction.highScores
                            )),
                            label: {
                                Text("🏆")
                                    .modifier(AddCardStyle())
                                    .frame(width: 50)
                            }
                        )
                        .accessibility(label: Text("High Scores"))
                    }
                    .padding()
                    Text("⭐️ Bravo! ⭐️").font(.largeTitle)
                        .padding(.bottom)
                        .hidden(!viewStore.game.isGameOver)
                    Text("Moves: ") + Text("\(viewStore.game.moves)").bold()
                    LazyVGrid(columns: columns) {
                        ForEach(0..<20) {
                            CardView(store: store.scope(state: { $0.game }, action: AppAction.game), id: $0)
                        }
                    }
                    .padding()
                    Button(action: { viewStore.send(.game(.new)) }) {
                        Text("New Game")
                    }
                    .hidden(!viewStore.game.isGameOver)
                    .padding()
                }
                .onAppear(perform: { viewStore.send(.highScores(.load)) })
                .navigationTitle("MemoArt")
                .navigationBarHidden(true)
            }
            .sheet(isPresented: viewStore.binding(get: { $0.isNewHighScoreEntryPresented }, send: .newHighScoreEntered), content: {
                NewHighScoreView(store: store)
            })
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .preview
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
                $0.game.symbols = .predictedGameSymbols(isCardsFaceUp: true)
            },
            reducer: appReducer,
            environment: .preview
        ))
    }
}

struct ContentViewAlmostFinished_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(
            initialState: .almostFinishedGame,
            reducer: appReducer,
            environment: .preview
        ))
    }
}

extension AppState {
    static func mocked(modifier: (inout Self) -> Void) -> Self {
        var state = AppState()
        modifier(&state)
        return state
    }

    static let almostFinishedGame: Self = .mocked {
        $0.game.isGameOver = false
        $0.game.discoveredSymbolTypes = SymbolType.allCases.filter({ $0 != .cave })
        $0.game.moves = 42
        $0.game.symbols = [Symbol].predictedGameSymbols(isCardsFaceUp: true).map {
            if $0.type == .cave {
                return Symbol(id: $0.id, type: $0.type, isFaceUp: false)
            }
            return $0
        }
    }
}

extension AnyScheduler where SchedulerTimeType == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    static var preview: Self { DispatchQueue.main.eraseToAnyScheduler() }
}

extension AppEnvironment {
    static let preview: Self = AppEnvironment(
        mainQueue: .preview,
        loadHighScores: { .preview },
        saveHighScores: { _ in }
    )
}
#endif
