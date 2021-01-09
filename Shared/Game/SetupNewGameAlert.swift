import SwiftUI
import ComposableArchitecture

struct SetupNewGameAlert: ViewModifier {
    let store: Store<GameState, GameAction>

    func body(content: Content) -> some View {
        WithViewStore(store) { viewStore in
            content.background(EmptyView().alert(isPresented: isPresented(viewStore: viewStore)) {
                Alert(
                    title: Text("New game"),
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

    private func isPresented(viewStore: ViewStore<GameState, GameAction>) -> Binding<Bool> {
        viewStore.binding(get: { $0.isNewGameAlertPresented }, send: .hideNewGameAlert)
    }
}
