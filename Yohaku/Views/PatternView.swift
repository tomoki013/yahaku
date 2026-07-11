import SwiftUI
import SwiftData

struct PatternView: View {
    @Query private var blocks: [YohakuBlock]
    @State private var isShowingInfo = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("pattern.title")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    if blocks.isEmpty {
                        EmptyStateView(message: "empty.pattern")
                    } else {
                        observations

                        NebulaCanvas(blocks: blocks, ink: .primary)
                            .frame(height: 400)
                            .accessibilityHidden(true)

                        shareButton
                    }
                }
                .padding(24)
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BrandMark()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel(Text("tab.about"))
                }
            }
            .sheet(isPresented: $isShowingInfo) {
                AboutView()
            }
        }
    }

    // MARK: - 観察

    private var observations: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: String(
                format: NSLocalizedString("pattern.drops %@", comment: ""),
                String(blocks.count)
            ))

            Text(verbatim: String(
                format: NSLocalizedString("pattern.total %@", comment: ""),
                hoursString(totalHours)
            ))

            if let longest = longestBlock {
                Text(verbatim: String(
                    format: NSLocalizedString("pattern.longest %1$@ %2$@", comment: ""),
                    hoursString(NebulaCanvas.durationHours(longest)),
                    longest.date.formatted(.dateTime.month().day())
                ))
            }

            Text(tendencyKey)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineSpacing(4)
    }

    private var totalHours: Double {
        blocks.reduce(0) { $0 + NebulaCanvas.durationHours($1) }
    }

    private var longestBlock: YohakuBlock? {
        blocks.max { NebulaCanvas.durationHours($0) < NebulaCanvas.durationHours($1) }
    }

    private func hoursString(_ hours: Double) -> String {
        let rounded = (hours * 10).rounded() / 10
        return rounded.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(rounded))
            : String(rounded)
    }

    private var tendencyKey: LocalizedStringKey {
        var parts = [0.0, 0.0, 0.0, 0.0] // 朝 昼 夕 夜
        let calendar = Calendar.current
        for block in blocks {
            var t = block.startTime
            let limit = block.startTime.addingTimeInterval(24 * 3600)
            while t < block.endTime && t < limit {
                let hour = calendar.component(.hour, from: t)
                switch hour {
                case 5..<11: parts[0] += 0.5
                case 11..<17: parts[1] += 0.5
                case 17..<22: parts[2] += 0.5
                default: parts[3] += 0.5
                }
                t.addTimeInterval(1800)
            }
        }
        switch parts.firstIndex(of: parts.max() ?? 0) ?? 0 {
        case 0: return "pattern.tendency.morning"
        case 1: return "pattern.tendency.afternoon"
        case 2: return "pattern.tendency.evening"
        default: return "pattern.tendency.night"
        }
    }

    // MARK: - 共有

    private var shareButton: some View {
        HStack {
            Spacer()
            ShareLink(item: shareImage, preview: SharePreview("Yohaku", image: shareImage)) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(Text("pattern.share"))
        }
    }

    private var shareImage: Image {
        let renderer = ImageRenderer(content: NebulaShareView(
            blocks: blocks,
            totalLine: String(
                format: NSLocalizedString("pattern.total %@", comment: ""),
                hoursString(totalHours)
            )
        ))
        renderer.scale = 3
        renderer.proposedSize = ProposedViewSize(width: 360, height: 450)
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "circle")
    }
}

// MARK: - 墨の星雲(ひとつの余白 = ひと滴の墨。中心から外へ育つ)

struct NebulaCanvas: View {
    let blocks: [YohakuBlock]
    let ink: Color

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let sorted = blocks.sorted { $0.createdAt < $1.createdAt }

            for (index, block) in sorted.enumerated() {
                var seed = Self.stableSeed(for: block)

                // 古い滴は中心に、新しい滴ほど外側へ。約60滴で満天になる
                let growth = min(1.0, Double(index) / 60.0).squareRoot()
                let radiusFactor = (0.05 + 0.95 * growth) * (0.55 + 0.45 * Self.random(&seed))
                let angle = Self.random(&seed) * 2 * .pi
                let x = center.x + cos(angle) * radiusFactor * size.width * 0.44
                let y = center.y + sin(angle) * radiusFactor * size.height * 0.46

                let hours = min(max(Self.durationHours(block), 0.25), 8)
                let diameter = 14 + (hours / 8) * 56 // 14〜70pt

                // にじみ(ぼかした薄い暈)
                var halo = context
                halo.addFilter(.blur(radius: diameter * 0.22))
                halo.opacity = 0.10 + 0.10 * Self.random(&seed)
                halo.fill(
                    Circle().path(in: CGRect(
                        x: x - diameter / 2, y: y - diameter / 2,
                        width: diameter, height: diameter
                    )),
                    with: .color(ink)
                )

                // 芯(小さく濃い滴)
                let core = diameter * (0.26 + 0.12 * Self.random(&seed))
                var coreContext = context
                coreContext.opacity = 0.45 + 0.30 * Self.random(&seed)
                coreContext.fill(
                    Circle().path(in: CGRect(
                        x: x - core / 2, y: y - core / 2,
                        width: core, height: core
                    )),
                    with: .color(ink)
                )
            }
        }
    }

    static func durationHours(_ block: YohakuBlock) -> Double {
        block.endTime.timeIntervalSince(block.startTime) / 3600
    }

    // 余白ごとに固定のシード(開き直しても同じ場所に滴が残る)
    private static func stableSeed(for block: YohakuBlock) -> UInt64 {
        let start = UInt64(bitPattern: Int64(block.startTime.timeIntervalSince1970))
        let end = UInt64(bitPattern: Int64(block.endTime.timeIntervalSince1970))
        return start &* 2654435761 ^ end
    }

    private static func random(_ seed: inout UInt64) -> Double {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return Double((seed >> 33) % 100000) / 100000
    }
}

// MARK: - 共有用の一枚(白地に墨、ワードマーク入り)

struct NebulaShareView: View {
    let blocks: [YohakuBlock]
    let totalLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 6, height: 6)
                Text(verbatim: "Yohaku")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .tracking(1.5)
                    .foregroundStyle(.black)
            }

            NebulaCanvas(blocks: blocks, ink: .black)
                .frame(maxHeight: .infinity)

            Text(verbatim: totalLine)
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .padding(28)
        .frame(width: 360, height: 450)
        .background(Color.white)
    }
}

#Preview {
    PatternView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
