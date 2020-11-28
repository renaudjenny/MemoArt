import SwiftUI
import ComposableArchitecture

struct ConfigurationView: View {
    let store: Store<ConfigurationState, ConfigurationAction>

    var body: some View {
        ScrollView {
            Divider()
            Text("Choose the cards you want to play with")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            ArtsSelectionConfigurationView(store: store)
            Divider()
        }
        .navigationTitle("Configuration")
    }
}
