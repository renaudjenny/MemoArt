import ComposableArchitecture
import SwiftUI

struct GameBackground: View {
    let store: Store<GameState, GameAction>
    private(set) var foregroundColor: Color?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        WithViewStore(store) { viewStore in
            Image("Motif")
                .resizable(resizingMode: .tile)
                .renderingMode(.template)
                .foregroundColor(foregroundColor ?? viewStore.mode.currentPlayerColor)
                .opacity(colorScheme == .light ? 10/100 : 30/100)
                .ignoresSafeArea()
        }
    }
}

extension GameMode.Player {
    var color: Color {
        switch self {
        case .first: return .red
        case .second: return .blue
        }
    }
}

extension GameMode {
    var currentPlayerColor: Color? {
        switch self {
        case .singlePlayer: return nil
        case let .twoPlayers(twoPlayers): return twoPlayers.current.color
        }
    }
}

#if DEBUG
struct GameBackground_Previews: PreviewProvider {
    private struct Preview: View {
        let store: Store<GameState, GameAction>
        private(set) var foregroundColor: Color?

        var body: some View {
            ZStack {
                Text("Hello world!")
                GameBackground(store: store, foregroundColor: foregroundColor)
            }
        }
    }

    static var previews: some View {
        Group {
            Preview(store: Store(
                initialState: .preview,
                reducer: gameReducer,
                environment: .preview
            ))
            Preview(store: Store(
                initialState: .preview,
                reducer: gameReducer,
                environment: .preview
            )).preferredColorScheme(.dark)
            Preview(store: Store(
                initialState: .mocked {
                    $0.mode = .twoPlayers(.init(current: .first))
                },
                reducer: gameReducer,
                environment: .preview
            ))
            Preview(store: Store(
                initialState: .mocked {
                    $0.mode = .twoPlayers(.init(current: .second))
                },
                reducer: gameReducer,
                environment: .preview
            ))
            Preview(store: Store(
                initialState: .mocked {
                    $0.mode = .twoPlayers(.init(current: .first))
                },
                reducer: gameReducer,
                environment: .preview
            )).preferredColorScheme(.dark)
            Preview(store: Store(
                initialState: .mocked {
                    $0.mode = .twoPlayers(.init(current: .second))
                },
                reducer: gameReducer,
                environment: .preview
            )).preferredColorScheme(.dark)
            Preview(
                store: Store(
                    initialState: .preview,
                    reducer: gameReducer,
                    environment: .preview
                ),
                foregroundColor: .yellow
            )
        }
    }
}
#endif
