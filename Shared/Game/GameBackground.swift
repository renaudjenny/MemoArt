import ComposableArchitecture
import SwiftUI

struct GameBackground: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if case let .twoPlayers(playerTurn) = viewStore.state.mode {
                    playerTurn.color
                }
                Image("Motif")
                    .resizable(resizingMode: .tile)
                    .renderingMode(.template)
                    .opacity(1/10)
                    .ignoresSafeArea()
            }
        }
    }
}

private extension GameMode.PlayerTurn {
    var color: Color {
        switch self {
        case .first: return .red
        case .second: return .blue
        }
    }
}
