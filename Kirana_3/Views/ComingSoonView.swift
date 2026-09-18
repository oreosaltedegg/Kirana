import SwiftUI

/// A plain placeholder screen for tabs that aren't built yet.
/// Pass in a title and it handles the rest.
struct ComingSoonView: View {
    let title: String
    let subtitle: String

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.custom("Fredoka", size: 34, relativeTo: .largeTitle))
                    .bold()
                    .padding(.horizontal)
                    .foregroundStyle(Color.grey)

                Text(subtitle)
                    .font(.custom("Fredoka", size: 20, relativeTo: .subheadline))
                    .foregroundStyle(Color("mysecondary"))
                    .padding(.horizontal)
                
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.dashed")
                        .font(.system(size: 48))
                        .foregroundStyle(Color("mysecondary"))
                    Text("Segera Hadir")
                        .font(.custom("Fredoka-Medium", size: 24, relativeTo: .title2))
                        .foregroundStyle(Color.grey)
                    Text("Halaman ini sedang dibuat.")
                        .font(.custom("Fredoka", size: 16, relativeTo:.subheadline))
                        .foregroundStyle(Color("mysecondary"))
                }
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .background(Color("mybackground").ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ComingSoonView(title: "Raya", subtitle: "Ragam Karya")
}
