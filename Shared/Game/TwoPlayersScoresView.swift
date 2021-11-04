import SwiftUI
import ComposableArchitecture

struct TwoPlayersScoresView: View {
    let store: Store<AppState, AppAction>
    @State private var animate = false
    
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
                            arts: twoPlayers.firstPlayerDiscoveredArts
                        )
                        resultView(
                            text: Text("Second Player"),
                            color: .blue,
                            arts: twoPlayers.secondPlayerDiscoveredArts
                        )
                    }
                    Spacer()
                    Button { viewStore.send(.hideTwoPlayersScoresView) } label: {
                        Text("Close")
                    }
                    .padding()
                }
                .background(GameBackground(store: store.gameStore))
                .onAppear { animate = true }
            }
        }
    }
    
    private func resultView(text: Text, color: Color, arts: [Art]) -> some View {
        VStack {
            ZStack {
                color.opacity(60/100)
                VStack {
                    text.font(.subheadline)
                    Text("\(arts.count) points")
                }
                .padding()
            }
            .fixedSize(horizontal: false, vertical: true)
            .cornerRadius(20)
            .padding(6)

            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(arts.enumerated()), id: \.0) { index, art in
                        CardView(
                            color: color,
                            image: art.image,
                            isFacedUp: true,
                            accessibilityIdentifier: "\(text) discovered art: \(art.description)",
                            accessibilityFaceDownText: Text("\(text) winning card"),
                            accessibilityFaceUpText: Text("\(text) discovered art: \(art.description)")
                        )
                            .frame(width: 80, height: 80)
                            .rotationEffect(cardAngle(index: index))
                            .offset(
                                cardOffset(
                                    index: index,
                                    count: arts.count,
                                    height: geometry.size.height
                                )
                            )
                            .animation(
                                .easeInOut(duration: 5).repeatForever(autoreverses: true),
                                value: animate
                            )
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
        }
    }

    private func cardAngle(index: Int) -> Angle {
        .radians(.pi/16 * (index.isMultiple(of: 2) ? -1 : 1) * (animate ? -1 : 1))
    }

    private func cardOffset(index: Int, count: Int, height: CGFloat) -> CGSize {
        let width: CGFloat = 20 * (index.isMultiple(of: 2) ? -1 : 1) * (animate ? -1 : 1)
        let index = CGFloat(index)
        let count = CGFloat(count)
        return CGSize(width: width, height: index * (height - 80)/(count - 1))
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
            $0.secondPlayerDiscoveredArts = [.impressionism, .gradient, .shadow, .cave, .arty]
        }
    }
}
#endif
