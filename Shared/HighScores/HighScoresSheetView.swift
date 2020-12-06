import SwiftUI
import ComposableArchitecture

struct HighScoresSheetView: View {
    let store: Store<HighScoresState, HighScoresAction>
    let preselectedLevel: DifficultyLevel
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("High Scores 🏆")
                .font(.largeTitle)
                .padding()
            HighScoresView(store: store, preselectedLevel: preselectedLevel)
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Text("Done")
                }
            }.padding()
        }
    }
}
