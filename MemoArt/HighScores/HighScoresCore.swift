import ComposableArchitecture

struct HighScoresState: Equatable {
    var scores: [HighScore] = []
}

enum HighScoresAction: Equatable {
    case addScore(HighScore)
    case reset
}

struct HighScoresEnvironment {

}

let highScoresReducer = Reducer<HighScoresState, HighScoresAction, HighScoresEnvironment> { state, action, _ in
    switch action {
    case let .addScore(newHighScore):
        guard !state.scores.isEmpty else {
            state.scores = [newHighScore]
            return .none
        }

        state.scores = (state.scores + [newHighScore])
            .sorted(by: {
                $0.score == $1.score
                    ? $0.date > $1.date
                    : $0.score <= $1.score
            })
            .prefix(10)

        return .none
    case .reset:
        state.scores = []
        return .none
    }
}

extension Array {
    func prefix(_ maxLength: Int) -> Self {
        let slicedArray: ArraySlice = self.prefix(maxLength)
        return Array(slicedArray)
    }
}
