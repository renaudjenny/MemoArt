import SwiftUI
import ComposableArchitecture

struct HighScoresNavigationLink: View {
    let store: Store<HighScoresState, HighScoresAction>

    var body: some View {
        NavigationLink(
            destination: HighScoresView(store: store),
            label: {
                Text("🏆")
            }
        )
        .accessibility(label: Text("High Scores"))
    }
}
