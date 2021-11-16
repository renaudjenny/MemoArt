import ComposableArchitecture
import SwiftUI

struct GameModeView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Menu {
                    Button {
                        viewStore.send(.gameModeSelected(.singlePlayer))
                    } label: { Label("Single player", systemImage: "person.fill") }
                    Button {
                        viewStore.send(.gameModeSelected(.twoPlayers(.init())))
                    } label: { Label("Two players", systemImage: "person.2.fill") }
                } label: {
                    Label(
                        "\(viewStore.mode.description)",
                        systemImage: viewStore.mode.systemImage
                    )
                }
                .menuStyle(BorderlessButtonMenuStyle())
            }
            .animation(nil)
        }
    }
}

private extension GameMode {
    var description: Text {
        switch self {
        case .singlePlayer: return Text("Single player")
        case .twoPlayers: return Text("Two players")
        }
    }

    var systemImage: String {
        switch self {
        case .singlePlayer: return "person.fill"
        case .twoPlayers: return "person.2.fill"
        }
    }
}

#if DEBUG
struct GameMoveView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameModeView(
                store: Store(
                    initialState: .preview,
                    reducer: gameReducer,
                    environment: .preview
                )
            )
            GameModeView(
                store: Store(
                    initialState: .mocked {
                        $0.mode = .twoPlayers(.init(
                            firstPlayerDiscoveredArts: [.cave],
                            secondPlayerDiscoveredArts: [.artDeco, .shadow]
                        ))
                    },
                    reducer: gameReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif
