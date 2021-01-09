import SwiftUI
import ComposableArchitecture

struct ConfigurationSheetView: View {
    let store: Store<AppState, AppAction>
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView {
            GroupBox(label: Text("Choose a difficulty level")) {
                DifficultyLevelConfigurationView(store: store.configurationStore)
            }
            .padding()

            GroupBox(label: Text("Choose the cards you want to play with")) {
                ArtsSelectionConfigurationView(store: store.configurationStore)
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
            .accessibilityIdentifier("done")
        }
        .modifier(SetupDifficultyLevelChangedAlert(store: store))
    }
}
