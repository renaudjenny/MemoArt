import SwiftUI
import ComposableArchitecture

struct GameOverView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isGameOver {
                VStack {
                    Text("⭐️ Bravo ⭐️").font(.largeTitle)
                    Button(action: { withAnimation(.spring()) { viewStore.send(.new) } }, label: {
                        Text("New game")
                    })
                }
                .padding(.top)
                .transition(
                    .asymmetric(insertion: .slide, removal: .opacity)
                )
            }
        }
    }
}

#if DEBUG
struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(
            initialState: .mocked {
                $0.game.isGameOver = true
                $0.game.discoveredArts = Art.allCases
                $0.game.moves = 142
                $0.game.cards = [Card].predicted(
                    isFaceUp: true,
                    level: .hard
                )
            },
            reducer: appReducer,
            environment: .preview
        ))
    }
}
#endif
