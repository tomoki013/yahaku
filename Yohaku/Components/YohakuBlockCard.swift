import SwiftUI

struct YohakuBlockCard: View {
    let block: YohakuBlock
    @State private var isBreathing = false

    var body: some View {
        TimelineView(.everyMinute) { context in
            let isActive = block.startTime <= context.date && context.date < block.endTime

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(block.startTime, format: .dateTime.hour().minute())
                    Text(verbatim: "–")
                    Text(block.endTime, format: .dateTime.hour().minute())
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(block.title)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        Color.primary.opacity(isActive ? (isBreathing ? 0.55 : 0.18) : 0.14),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
            .onAppear {
                updateBreathing(isActive: isActive)
            }
            .onChange(of: isActive) { _, nowActive in
                updateBreathing(isActive: nowActive)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func updateBreathing(isActive: Bool) {
        if isActive {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        } else {
            withAnimation(nil) {
                isBreathing = false
            }
        }
    }
}
