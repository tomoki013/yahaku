import SwiftUI

struct EmptyStateView: View {
    let message: LocalizedStringKey

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 48)
    }
}
