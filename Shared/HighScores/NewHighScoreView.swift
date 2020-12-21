import SwiftUI
import ComposableArchitecture

struct NewHighScoreView: View {
    let store: Store<AppState, AppAction>
    @State private var name = ""

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                cardsAnimation
                TextField("Your name", text: $name, onCommit: {
                    submit(with: viewStore)
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: { submit(with: viewStore) }, label: {
                    Text("Add my new high score")
                })
            }
        }
    }

    private func submit(with viewStore: ViewStore<AppState, AppAction>) {
        if name == "" {
            viewStore.send(.highScores(.addScore(
                HighScore(score: viewStore.game.moves, date: Date()),
                viewStore.game.level
            )))
        } else {
            viewStore.send(.highScores(.addScore(
                HighScore(score: viewStore.game.moves, name: name, date: Date()),
                viewStore.game.level
            )))
        }
        viewStore.send(.newHighScoreEntered)
    }

    private var cardsAnimation: some View {
        HStack {
            Spacer()
            ZStack {
                ForEach(0..<5) { cardNumber in
                    CCardView(color: randomColor, image: randomArt, isFacedUp: .constant(true))
                        .frame(width: 60, height: 60)
                        .rotationEffect(angle(cardNumber: cardNumber))
                        .offset(offset(cardNumber: cardNumber))
                }
                .padding()
            }
            Spacer()
        }
    }

    private func angle(cardNumber: Int) -> Angle {
        .radians(-.pi/16 * 4 + 2 * .pi/16 * Double(cardNumber))
    }

    private func offset(cardNumber: Int) -> CGSize {
        CGSize(
            width: -16 * 4 + 2 * 16 * cardNumber,
            height: 4 * (cardNumber * cardNumber) - 16 * cardNumber
        )
    }

    private var randomColor: Color {
        [Color.green, Color.blue, Color.red].randomElement() ?? .red
    }

    private var randomArt: Image {
        Art.allCases.randomElement()?.image ?? Art.artDeco.image
    }
}

struct CCardView: View {
    let color: Color
    let image: Image
    @Binding var isFacedUp: Bool
    let action: () -> Void = { }
    private static let turnCardAnimationDuration: Double = 2/5

    var body: some View {
        ZStack {
            if !isFacedUp {
                Button(action: action) {
                    color.transition(turnTransition)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                image
                    .renderingMode(.original)
                    .resizable()
                    .font(.largeTitle)
                    .transition(turnTransition)
            }
        }
        .modifier(AddCardStyle(foregroundColor: color))
        .rotation3DEffect(
            isFacedUp
                ? .radians(.pi)
                : .zero,
            axis: (x: 0.0, y: 1.0, z: 0.0),
            perspective: 1/3
        )
        .animation(.easeInOut(duration: Self.turnCardAnimationDuration))
        .rotation3DEffect(.radians(.pi), axis: (x: 0.0, y: 1.0, z: 0.0))
    }

    private var turnTransition: AnyTransition {
        AnyTransition.opacity.animation(
            Animation
                .linear(duration: 0.01)
                .delay(Self.turnCardAnimationDuration/2)
        )
    }
}

#if DEBUG
struct NewHighScoreView_Previews: PreviewProvider {
    static var previews: some View {
        NewHighScoreView(store: Store<AppState, AppAction>(
            initialState: AppState(
                game: GameState(
                    moves: 42,
                    cards: [],
                    discoveredArts: [],
                    isGameOver: true
                ),
                highScores: .preview,
                isNewHighScoreEntryPresented: true
            ),
            reducer: appReducer,
            environment: .preview
        ))
    }
}
#endif
