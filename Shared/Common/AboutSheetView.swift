import SwiftUI
import RenaudJennyAboutView

struct AboutSheetView: View {
    @Binding var isOpen: Bool

    var body: some View {
        ZStack {
            AboutView(
                appId: "id1536330844",
                logo: {
                    Image("Pixel Art")
                        .resizable()
                        .modifier(AddCardStyle())
                        .frame(width: 120, height: 120)
                }
            )
            .buttonStyle(aboutBoutonStyle)
            .padding(.bottom, 30)
            .background(
                Image("Motif")
                    .resizable(resizingMode: .tile)
                    .renderingMode(.template)
                    .opacity(1/16)
            )
            VStack {
                Spacer()
                Button {
                    isOpen = false
                } label: {
                    Text("Done")
                }
                .padding()
            }
        }
    }

    private var aboutBoutonStyle: some PrimitiveButtonStyle {
        #if os(macOS)
        return LinkButtonStyle()
        #else
        return DefaultButtonStyle()
        #endif
    }
}
