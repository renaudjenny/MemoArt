import SwiftUI
import ComposableArchitecture

struct TwoPlayersScoresView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if case let .twoPlayers(twoPlayers) = viewStore.game.mode {
                VStack {
                    VictoryCardsView()

                    VStack {
                        switch twoPlayers.winner {
                        case .first: Text("First player won!")
                        case .second: Text("Second player won!")
                        case .none: Text("It's a draw!")
                        }
                    }
                    .font(.title)
                    .padding()

                    HStack(spacing: 0) {
                        resultView(
                            text: Text("First Player"),
                            color: .red,
                            score: twoPlayers.firstPlayerDiscoveredArts.count
                        )
                        resultView(
                            text: Text("Second Player"),
                            color: .blue,
                            score: twoPlayers.secondPlayerDiscoveredArts.count
                        )
                    }
                    Spacer()
                    Button { viewStore.send(.hideTwoPlayersScoresView) } label: {
                        Text("Close")
                    }
                    .padding()
                }
                .background(GameBackground(store: store.gameStore))
            }
        }
    }

    private func resultView(text: Text, color: Color, score: Int) -> some View {
        ZStack {
            color.opacity(60/100)
            VStack {
                text.font(.subheadline)
                Text("\(score) points")
            }
            .padding()
        }
        .fixedSize(horizontal: false, vertical: true)
        .cornerRadius(20)
        .padding(6)
    }
}

extension GameMode.TwoPlayers {
    var winner: GameMode.Player? {
        let first = firstPlayerDiscoveredArts.count
        let second = secondPlayerDiscoveredArts.count
        guard first != second else { return nil }
        return first > second ? .first : .second
    }
}

#if DEBUG
struct TwoPlayersScoresView_Previews: PreviewProvider {
    static var previews: some View {
        TwoPlayersScoresView(store: Store<AppState, AppAction>(
            initialState: AppState(
                game: GameState(isGameOver: true, mode: .twoPlayers(.finishedGame)),
                isTwoPlayersScoresPresented: true
            ),
            reducer: appReducer,
            environment: .preview
        ))
    }
}

extension GameMode.TwoPlayers {
    static var finishedGame: Self {
        .mocked {
            $0.firstPlayerDiscoveredArts = [.watercolor, .geometric, .artDeco]
            $0.secondPlayerDiscoveredArts = [.impressionism, .gradient, .shadow, .childish]
        }
    }
}
#endif
