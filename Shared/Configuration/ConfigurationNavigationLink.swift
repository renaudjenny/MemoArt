import SwiftUI
import ComposableArchitecture

struct ConfigurationNavigationLink: View {
    let store: Store<ConfigurationState, ConfigurationAction>

    var body: some View {
        NavigationLink(
            destination: SymbolTypesSelectionConfigurationView(store: store),
            label: {
                Image(systemName: "gearshape")
            }
        )
    }
}
