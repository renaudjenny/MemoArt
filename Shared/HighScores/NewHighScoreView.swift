import SwiftUI
import ComposableArchitecture

struct NewHighScoreView: View {
    let store: Store<AppState, AppAction>
    @State private var name = ""

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                TextField("Your name", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: { submit(with: viewStore) }, label: {
                    Text("Add my new high score")
                })
            }
        }
    }

    private func submit(with viewStore: ViewStore<AppState, AppAction>) {
        if name == "" {
            viewStore.send(.highScores(.addScore(HighScore(score: viewStore.game.moves, date: Date()))))
        } else {
            viewStore.send(.highScores(.addScore(HighScore(
                score: viewStore.game.moves,
                name: name,
                date: Date()
            ))))
        }
        viewStore.send(.newHighScoreEntered)
    }
}

#if DEBUG
struct NewHighScoreView_Previews: PreviewProvider {
    static var previews: some View {
        NewHighScoreView(store: Store<AppState, AppAction>(
            initialState: AppState(
                game: GameState(
                    moves: 42,
                    cards: [],
                    discoveredArts: [],
                    isGameOver: true
                ),
                highScores: HighScoresState(scores: .preview),
                isNewHighScoreEntryPresented: true
            ),
            reducer: appReducer,
            environment: .preview
        ))
    }
}
#endif
