import SwiftUI
import ComposableArchitecture

struct ConfigurationSheetView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    @Binding var isPresented: Bool

    var body: some View {
        SymbolTypesSelectionConfigurationView(store: store)
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
