import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    let columns = [GridItem(.adaptive(minimum: 65))]

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.game.isGameOver {
                    Text("⭐️ Bravo! ⭐️").font(.largeTitle)
                    Text("Game Over")
                }
                Text("Moves: \(viewStore.game.moves/2)")
                LazyVGrid(columns: columns) {
                    ForEach(0..<20) {
                        CardView(store: store.scope(state: { $0.game }, action: AppAction.game), id: $0)
                    }
                }
                if viewStore.game.isGameOver {
                    Button(action: { viewStore.send(.game(.new)) }) {
                        Text("New game")
                    }
                }
            }
            .padding()
            .onAppear { viewStore.send(.game(.new)) }
        }
    }
}

// TODO: put back the preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
