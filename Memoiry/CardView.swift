import SwiftUI
import ComposableArchitecture

struct CardView: View {
    let store: Store<GameState, GameAction>
    let id: Int

    var body: some View {
        content
            .frame(width: 65, height: 65)
            .cornerRadius(8.0)
            .shadow(radius: 1, x: 1, y: 1)
    }

    private var content: some View {
        WithViewStore(store) { viewStore in
            if viewStore.symbols.count > 0 && viewStore.symbols[id].isReturned {
                Button(action: { returnCard(store: viewStore) }) {
                    Color.red
                }
            } else {
                image
            }
        }
    }

    private var image: some View {
        WithViewStore(store) { viewStore in
            if viewStore.symbols.count > 0 {
                viewStore.symbols[id].type.image
                    .renderingMode(.original)
                    .resizable()
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
