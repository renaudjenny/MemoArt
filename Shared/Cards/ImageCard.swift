import SwiftUI
import SwiftUICardGame

struct ImageCard: CardRepresentable {
    let color: Color
    let image: Image
    let isFacedUp: Bool
    let accessibilityIdentifier: String
    let accessibilityFacedDownText: Text
    let accessibilityFacedUpText: Text
    private(set) var action: () -> Void = { }

    var foreground: some View {
        image
            .renderingMode(.original)
            .resizable()
            .font(.largeTitle)
            .modifier(AddCardStyle(foregroundColor: color))
            .accessibility(label: accessibilityFacedUpText)
    }

    var background: some View {
        color
            .modifier(AddCardStyle(foregroundColor: color))
            .accessibility(label: accessibilityFacedDownText)
            .accessibility(identifier: accessibilityIdentifier)
    }
}
