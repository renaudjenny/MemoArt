import ComposableArchitecture
import SwiftUI

struct GameModeView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Menu {
                    Button {
                        viewStore.send(.switchMode(.singlePlayer))
                    } label: { Label("Single Player", systemImage: "person.fill") }
                    Button {
                        viewStore.send(.switchMode(.twoPlayers(.init())))
                    } label: { Label("Two Players", systemImage: "person.2.fill") }
                } label: {
                    Label(
                        "Current mode: \(viewStore.mode.description)",
                        systemImage: viewStore.mode.systemImage
                    )
                }
                if case let .twoPlayers(twoPlayers) = viewStore.state.mode {
                    HStack {
                        VStack {
                            Text("Player turn")
                            switch twoPlayers.current {
                            case .first: Text("First player turn").foregroundColor(.red)
                            case .second: Text("Second player turn").foregroundColor(.blue)
                            }
                        }
                        Divider().frame(maxHeight: 40)
                        VStack {
                            Text("Scores")
                            HStack {
                                Text("First: \(twoPlayers.firstPlayerDiscoveredArts.count)")
                                    .foregroundColor(.red)
                                Text("Second: \(twoPlayers.secondPlayerDiscoveredArts.count)")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension GameMode {
    var description: String {
        switch self {
        case .singlePlayer: return NSLocalizedString("Single player", comment: "")
        case .twoPlayers: return NSLocalizedString("Two players", comment: "")
        }
    }

    var systemImage: String {
        switch self {
        case .singlePlayer: return "person.fill"
        case .twoPlayers: return "person.2.fill"
        }
    }
}

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
