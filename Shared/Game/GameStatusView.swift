import SwiftUI
import ComposableArchitecture

struct GameStatusView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.mode {
            case .singlePlayer: Text("Moves: \(viewStore.moves)")
            case let .twoPlayers(twoPlayers):
                Text("🔴 \(twoPlayers.firstPlayerDiscoveredArts.count)").foregroundColor(.red)
                + Text("  ")
                + Text("🔵 \(twoPlayers.secondPlayerDiscoveredArts.count)").foregroundColor(.blue)
            }
        }
    }
}

struct GameStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameStatusView(store: Store(
                initialState: .preview,
                reducer: gameReducer,
                environment: .preview
            ))
            GameStatusView(store: Store(
                initialState: .mocked {
                    $0.mode = .twoPlayers(.mocked {
                        $0.firstPlayerDiscoveredArts = [.cave, .childish]
                        $0.secondPlayerDiscoveredArts = [.shadow]
                    })
                },
                reducer: gameReducer,
                environment: .preview
            ))
        }
    }
}
