import SwiftUI

struct AddCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        RoundedRectangle(cornerRadius: 8.0)
            .foregroundColor(.red)
            .overlay(
                content.clipShape(RoundedRectangle(cornerRadius: 8.0))
            )
            .aspectRatio(contentMode: .fit)
            .shadow(radius: 1, x: 1, y: 1)
    }
}

#if DEBUG
struct AddCardStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello, World!")
                .bold()
                .foregroundColor(.yellow)
                .modifier(AddCardStyle())
                .frame(width: 150)
            Image("Pop Art")
                .resizable()
                .modifier(AddCardStyle())
                .frame(width: 150)
        }
    }
}
#endif
