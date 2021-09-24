import ComposableArchitecture
import SwiftUI

struct AdaptiveGrid: View {
    let store: Store<GameState, GameAction>
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        WithViewStore(store) { viewState in
            VStack {
                ForEach(grid(cards: viewState.cards), id: \.id) { rows in
                    HStack {
                        ForEach(rows) { card in
                            GameCardView(store: store, card: card)
                        }
                    }
                }
            }
        }
    }

    private func grid(cards: [Card]) -> [[Card]] {
        let more = cards.count/4
        let less = cards.count/more
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular), (_, .compact):
            return cards.group(rows: less, columns: more)
        default:
            return cards.group(rows: more, columns: less)
        }
    }
}

extension Array where Element == Card {
    var id: Int {
        var hasher = Hasher()
        map(\.id).forEach { hasher.combine($0) }
        return hasher.finalize()
    }

    func group(rows: Int, columns: Int) -> [[Card]] {
        (0..<rows).map { row in
            (0..<columns).map { column in
                let index = column + (row * columns)
                guard count > index else { return nil }
                return self[index]
            }
            .compactMap { $0 }
        }
    }
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

    private static func preview(level: DifficultyLevel) -> some View {
        VStack {
            Text("Level: \(level.rawValue) - \(level.cardsCount) cards").padding()
            AdaptiveGrid(
                store: Store(
                    initialState: GameState(cards: .predicted(level: level), level: level),
                    reducer: gameReducer,
                    environment: .preview
                )
            ).padding()
        }
    }
}
#endif
