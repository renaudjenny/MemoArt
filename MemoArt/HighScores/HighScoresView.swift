import SwiftUI
import ComposableArchitecture

struct HighScoresView: View {
    let store: Store<HighScoresState, HighScoresAction>
    let columns = [
        GridItem(.fixed(40)),
        GridItem(.flexible(minimum: 100, maximum: 300)),
        GridItem(.fixed(100)),
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if viewStore.scores.count <= 0 {
                    Text("Go win some game to see your best scores here ⭐️")
                        .bold()
                        .padding(.top, 64)
                        .padding()
                } else {
                    LazyVGrid(columns: columns) {
                        ForEach(viewStore.scores, content: HighScoreView.init)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("High Scores")
            .navigationBarHidden(false)
        }
    }
}

struct HighScoreView: View {
    let highScore: HighScore
    private static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        Group {
            Text("\(highScore.score)").font(.title2)
            Text(highScore.name)
            Text(highScore.date, formatter: Self.dateFormat)
                .font(.caption)
        }
        .padding(.vertical)
    }
}

#if DEBUG
struct HighScoresView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresView(store: .init(
            initialState: HighScoresState(),
            reducer: highScoresReducer,
            environment: HighScoresEnvironment(
                load: { .preview },
                save: { _ in }
            )
        ))
    }
}

struct HighScoresViewEmptyScores_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresView(store: .init(
            initialState: HighScoresState(),
            reducer: highScoresReducer,
            environment: HighScoresEnvironment(
                load: { [] },
                save: { _ in }
            )
        ))
    }
}

extension Date {
    static let preview = Date(timeIntervalSince1970: 12345)
}

extension Array where Element == HighScore {
    static let preview: Self = (1...10).map {
        HighScore(score: 10 * $0, name: "Preview player \($0)", date: .preview)
    }
}
#endif
