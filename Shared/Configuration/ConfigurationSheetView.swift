import SwiftUI
import ComposableArchitecture

struct ConfigurationSheetView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView {
            GroupBox(label: Text("Choose a difficulty level")) {
                DifficultyLevelConfigurationView(store: store)
            }
            .padding()

            GroupBox(label: Text("Choose the cards you want to play with")) {
                ArtsSelectionConfigurationView(store: store)
            }
            .padding()
        }
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
