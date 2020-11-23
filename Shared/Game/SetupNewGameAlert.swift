import SwiftUI
import ComposableArchitecture

struct SetupNewGameAlert: ViewModifier {
    let store: Store<GameState, GameAction>
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        WithViewStore(store) { viewStore in
            content.background(EmptyView().alert(isPresented: $isPresented) {
                Alert(
                    title: Text("New Game"),
                    message: Text("This will reset the current game, you will loose your progress!"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(
                        Text("Reset game"),
                        action: {
                            DispatchQueue.main.async {
                                viewStore.send(.new)
                            }
                        }
                    )
                )
            })
        }
    }
}
