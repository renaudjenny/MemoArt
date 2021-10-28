import SwiftUI
import ComposableArchitecture

struct GameStatusView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.mode {
            case .singlePlayer: Text("Moves: \(viewStore.moves)")
            case let .twoPlayers(twoPlayers):
                VStack(spacing: 4) {
                    HStack {
                        Text("🔴 \(twoPlayers.firstPlayerDiscoveredArts.count)")
                            .foregroundColor(.red)
                        Text("🔵 \(twoPlayers.secondPlayerDiscoveredArts.count)")
                            .foregroundColor(.blue)
                    }

                    GeometryReader { geometry in
                        Rectangle()
                            .foregroundColor(twoPlayers.current.color)
                            .frame(width: geometry.size.width/2, height: 2)
                            .offset(
                                x: twoPlayers.current == .first ? 0 : geometry.size.width/2,
                                y: geometry.size.height - 3
                            )
                            .animation(.easeInOut, value: viewStore.mode)
                    }
                }
                .fixedSize()
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
            Preview(store: Store(
                initialState: .mocked {
                    $0.mode = .twoPlayers(.mocked {
                        $0.firstPlayerDiscoveredArts = [.cave, .childish]
                        $0.secondPlayerDiscoveredArts = [.shadow]
                    })
                },
                reducer: gameReducer,
                environment: .preview
            ))
            VStack {
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
            .frame(height: 50)
            .background(Color.yellow)
        }
    }

    private struct Preview: View {
        let store: Store<GameState, GameAction>

        var body: some View {
            VStack {
                WithViewStore(store) { viewStore in
                    GameStatusView(store: store)
                    Button { viewStore.send(.nextPlayer) } label: {
                        Text("Next player")
                    }
                }
            }
        }
    }
}
