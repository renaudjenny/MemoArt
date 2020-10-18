import SwiftUI
import ComposableArchitecture

struct CardView: View {
    let store: Store<GameState, GameAction>
    let id: Int

    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.symbols.count > 0 && viewStore.symbols[id].isReturned {
                Button(action: { returnCard(store: viewStore) }) {
                    Color.red
                        .frame(width: 65, height: 65)
                        .cornerRadius(8.0)
                }
            } else {
                image
                    .frame(width: 65, height: 65)
                    .border(Color.red, width: 4)
                    .cornerRadius(8.0)
            }
        }
    }

    private var image: some View {
        WithViewStore(store) { viewStore in
            if viewStore.symbols.count > 0 {
                viewStore.symbols[id].type.image
                    .renderingMode(.original)
                    .font(.largeTitle)
            } else {
                Image(systemName: "questionmark")
            }
        }
    }

    private func returnCard(store: ViewStore<GameState, GameAction>) {
        withAnimation {
            store.send(.cardReturned(id))
        }
    }
}
