import SwiftUI
import ComposableArchitecture

struct GameCardView: View {
    let store: Store<GameState, GameAction>
    let card: Card
    private static let turnCardAnimationDuration: Double = 2/5

    var body: some View {
        WithViewStore(store) { viewStore in
            CardView(
                color: backgroundColor(level: viewStore.level),
                image: card.art.image,
                isFacedUp: card.isFaceUp,
                action: { returnCard(store: viewStore) }
            )
        }
    }

    private func returnCard(store: ViewStore<GameState, GameAction>) {
        withAnimation(.spring()) { store.send(.cardReturned(card.id)) }
    }

    private func backgroundColor(level: DifficultyLevel) -> Color {
        switch level {
        case .easy: return .green
        case .normal: return .blue
        case .hard: return .red
        }
    }
}

#if DEBUG
struct GameCardView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        let store = Store<GameState, GameAction>(
            initialState: .preview,
            reducer: gameReducer,
            environment: .preview
        )

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            GameCardView(store: store, card: card(store: viewStore, id: 0))
                            GameCardView(store: store, card: card(store: viewStore, id: 1))
                        }
                        HStack {
                            GameCardView(store: store, card: card(store: viewStore, id: 2))
                            GameCardView(store: store, card: card(store: viewStore, id: 3))
                        }
                        HStack {
                            GameCardView(store: store, card: card(store: viewStore, id: 4))
                            GameCardView(store: store, card: card(store: viewStore, id: 5))
                        }
                    }
                    Spacer()
                    Button(action: { viewStore.send(.new) }, label: {
                        Text("New game!")
                    })
                    .padding()
                }.padding()
            }
        }

        private func card(store: ViewStore<GameState, GameAction>, id: Int) -> Card {
            store.cards[id]
        }
    }
}
#endif
