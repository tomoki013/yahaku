import SwiftUI

struct YohakuBlockCard: View {
    let block: YohakuBlock

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(block.startTime, format: .dateTime.hour().minute())
                Text(verbatim: "–")
                Text(block.endTime, format: .dateTime.hour().minute())
            }
            .font(.caption)
            .foregroundStyle(.gray)

            Text(block.title)
                .font(.body)
                .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(white: 0.88), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
