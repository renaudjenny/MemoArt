import SwiftUI
import ComposableArchitecture

struct CardView: View {
    let store: Store<GameState, GameAction>
    let id: Int
    private static let turnCardAnimationDuration: Double = 2/3

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if !viewStore.symbols[id].isFaceUp {
                    Button(action: { returnCard(store: viewStore) }) {
                        Color.red
                    }
                    .transition(turnTransition)
                } else {
                    image.transition(turnTransition)
                }
            }
            .cornerRadius(8.0)
            .frame(width: 65, height: 65)
            .shadow(radius: 1, x: 1, y: 1)
            .rotation3DEffect(
                viewStore.symbols[id].isFaceUp
                    ? .radians(.pi)
                    : .zero,
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .animation(.linear(duration: Self.turnCardAnimationDuration))
        }
    }

    private var image: some View {
        WithViewStore(store) { viewStore in
            viewStore.symbols[id].type.image
                .renderingMode(.original)
                .resizable()
                .font(.largeTitle)
        }
    }

    private var turnTransition: AnyTransition {
        AnyTransition.opacity.animation(
            Animation
                .linear(duration: 0.01)
                .delay(Self.turnCardAnimationDuration/2)
        )
    }

    private func returnCard(store: ViewStore<GameState, GameAction>) {
        store.send(.cardReturned(id))
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        let store = Store<GameState, GameAction>(
            initialState: GameState(),
            reducer: gameReducer,
            environment: GameEnvironment()
        )

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            CardView(store: store, id: 0)
                            CardView(store: store, id: 1)
                        }
                        HStack {
                            CardView(store: store, id: 2)
                            CardView(store: store, id: 3)
                        }
                        HStack {
                            CardView(store: store, id: 4)
                            CardView(store: store, id: 5)
                        }
                    }
                    Spacer()
                    Button(action: { viewStore.send(.new) }) {
                        Text("New game!")
                    }
                    .padding()
                }
            }
        }
    }
}
