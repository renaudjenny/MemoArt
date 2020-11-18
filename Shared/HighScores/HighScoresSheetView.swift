import SwiftUI
import ComposableArchitecture

struct HighScoresSheetView: View {
    let store: Store<HighScoresState, HighScoresAction>
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            HighScoresView(store: store)
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Text("Done")
                }
                .padding([.bottom, .trailing])
            }
        }
    }
}
