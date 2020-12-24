import SwiftUI

struct CardView: View {
    let color: Color
    let image: Image
    let isFacedUp: Bool
    var action: () -> Void = { }
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
