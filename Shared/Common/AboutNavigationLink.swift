import SwiftUI
import RenaudJennyAboutView

struct AboutNavigationLink: View {
    var body: some View {
        NavigationLink(
            destination: AboutView(
                appId: "id1536330844",
                logo: {
                    Image("Pixel Art")
                        .resizable()
                        .modifier(AddCardStyle())
                        .frame(width: 120, height: 120)

                }),
            label: {
                Image(systemName: "questionmark.circle")
            }
        )
    }
}
