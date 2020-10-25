import SwiftUI
import ComposableArchitecture

struct HighScoresView: View {
    let store: Store<HighScoresState, HighScoresAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if viewStore.scores.count <= 0 {
                    Text("Go win some game to see your best scores here ⭐️")
                        .bold()
                        .padding(.top, 64)
                        .padding()
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(viewStore.scores.enumerated()), id: \.0) { position, score in
                            HighScoreView(position: position, highScore: score)
                        }
                    }
                }
            }
            .navigationTitle("High Scores 🏆")
            .navigationBarHidden(false)
        }
    }
}

struct HighScoreView: View {
    let position: Int
    let highScore: HighScore
    private static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8.0)
                .foregroundColor(.red)
                .overlay(positionView)
                .aspectRatio(contentMode: .fit)
                .shadow(radius: 1, x: 1, y: 1)
                .frame(width: 50)
            Text("\(highScore.score)")
                .font(.title3)
                .frame(width: 40)
            Text(highScore.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(highScore.date, formatter: Self.dateFormat)
                .font(.caption)
                .frame(width: 120, alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            position.isMultiple(of: 2)
                ? Color(UIColor.systemBackground)
                : Color(UIColor.systemGray5)
        )
    }

    private var positionView: some View {
        Group {
            switch position {
            case 0: Text("🥇").font(.title)
            case 1: Text("🥈").font(.title)
            case 2: Text("🥉").font(.title)
            default: Text("\(position + 1)")
                .bold()
                .font(.title2)
            }
        }
        .foregroundColor(.yellow)
    }
}

#if DEBUG
struct HighScoresView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HighScoresView(store: .init(
                initialState: HighScoresState(scores: .preview),
                reducer: highScoresReducer,
                environment: HighScoresEnvironment(
                    load: { .preview },
                    save: { _ in }
                )
            ))
        }
    }
}

struct HighScoresViewEmptyScores_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
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
