import SwiftUI
import ComposableArchitecture

struct NewGameButton: View {
    let store: Store<GameState, GameAction>
    @Binding var isNewGameAlertPresented: Bool

    var body: some View {
        WithViewStore(store) { viewStore in
            Button {
                guard viewStore.moves > 0 else {
                    viewStore.send(.new)
                    return
                }
                isNewGameAlertPresented = true
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .accessibility(label: Text("New Game"))
            .disabled(!viewStore.isGameInProgress)
        }
    }
}
