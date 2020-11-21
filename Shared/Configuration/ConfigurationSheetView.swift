import SwiftUI
import ComposableArchitecture

struct ConfigurationSheetView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView {
            GroupBox(label: artTypeSelectionLabel) {
                SymbolTypesSelectionConfigurationView(store: store)
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

    private var artTypeSelectionLabel: some View {
        Text("Choose the cards you want to play with")
    }
}
