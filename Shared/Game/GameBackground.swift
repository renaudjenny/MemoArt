import ComposableArchitecture
import SwiftUI

struct GameBackground: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if case let .twoPlayers(twoPlayers) = viewStore.state.mode {
                    twoPlayers.current.color.opacity(10/100)
                }
                Image("Motif")
                    .resizable(resizingMode: .tile)
                    .renderingMode(.template)
                    .opacity(1/10)
            }
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
