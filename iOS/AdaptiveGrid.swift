import ComposableArchitecture
import SwiftUI

struct AdaptiveGrid<Content: View>: View {
    let content: () -> Content
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular), (_, .compact):
            LazyHGrid(rows: gridItems, content: content)
        default:
            LazyVGrid(columns: gridItems, content: content)
        }
    }

    private let gridItems = Array(repeating: GridItem(.adaptive(minimum: 50)), count: 4)
}

#if DEBUG
struct AdaptiveGrid_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(level: .easy)
            preview(level: .normal)
            preview(level: .hard)
            preview(level: .easy)
                .environment(\.verticalSizeClass, .compact)
                .previewLayout(.fixed(width: 800, height: 400))
            preview(level: .normal)
                .environment(\.verticalSizeClass, .compact)
                .previewLayout(.fixed(width: 800, height: 400))
            preview(level: .hard)
                .environment(\.verticalSizeClass, .compact)
                .previewLayout(.fixed(width: 800, height: 400))
        }
    }

    private static func cards(level: DifficultyLevel) -> [Card] {
        (0..<level.cardsCount).map { Card(id: $0, art: .artDeco, isFaceUp: false) }
    }

    private static func preview(level: DifficultyLevel) -> some View {
        AdaptiveGrid {
            ForEach(cards(level: level)) {
                GameCardView(
                    store: Store(
                        initialState: GameState(
                            cards: cards(level: level),
                            level: level
                        ),
                        reducer: gameReducer,
                        environment: .preview
                    ),
                    card: $0
                )
            }
        }
        .padding()
    }
}
#endif
