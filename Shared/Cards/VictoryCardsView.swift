import SwiftUI
import Combine

struct VictoryCardsView: View {
    @State private var isCardsFacedUp = Array(repeating: Bool.random(), count: 5)
    @State private var colors: [Color] = [.green, .blue, .red, .blue, .green]
    @State private var images: [Image] = Art.allCases.shuffled().prefix(5).map(\.image)
    @State private var returnCardTask: Cancellable?

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                ForEach(0..<5) { cardNumber in
                    CCardView(
                        color: colors[cardNumber],
                        image: images[cardNumber],
                        isFacedUp: $isCardsFacedUp[cardNumber]
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(angle(cardNumber: cardNumber))
                    .offset(offset(cardNumber: cardNumber))
                }
                .padding(.vertical, 50)
                .padding(.horizontal, 115)
            }
            Spacer()
        }
        .onAppear {
            returnCardTask = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { _ in
                    isCardsFacedUp = [Bool.random(), Bool.random(), Bool.random(), Bool.random(), Bool.random()]
                    colors = isCardsFacedUp.enumerated().map { offset, isFacedUp in
                        if isFacedUp { return [.green, .blue, .red].randomElement() ?? .red }
                        return colors[offset]
                    }
                    images = isCardsFacedUp.enumerated().map { offset, isFacedUp in
                        if isFacedUp { return images[offset] }
                        return Art.allCases.randomElement()?.image ?? Art.artDeco.image
                    }
                }
        }
        .onDisappear {
            returnCardTask?.cancel()
        }
    }

    private func angle(cardNumber: Int) -> Angle {
        .radians(-.pi/16 * 4 + 2 * .pi/16 * Double(cardNumber))
    }

    private func offset(cardNumber: Int) -> CGSize {
        CGSize(
            width: -24 * 4 + 2 * 24 * cardNumber,
            height: 7 * (cardNumber * cardNumber) - 28 * cardNumber
        )
    }

    private var randomColor: Color {
        [Color.green, Color.blue, Color.red].randomElement() ?? .red
    }

    private var randomArt: Image {
        Art.allCases.randomElement()?.image ?? Art.artDeco.image
    }
}

// TODO: refactor this with the one in CardView
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
struct VictoryCardsView_Previews: PreviewProvider {
    static var previews: some View {
        VictoryCardsView()
    }
}
#endif
