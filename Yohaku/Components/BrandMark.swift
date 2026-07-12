import SwiftUI

// 各画面の左上に静かに置かれるワードマーク。墨の一滴+セリフ体
struct BrandMark: View {
    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(Color.primary)
                .frame(width: 6, height: 6)
            Text(verbatim: "Yohaku")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .tracking(1.5)
                .foregroundStyle(.primary)
        }
        .fixedSize()
        .accessibilityHidden(true)
    }
}

// ガラス背景なしで左上に置くためのツールバー項目(押せる見た目にしない)
struct BrandToolbarItem: ToolbarContent {
    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarLeading) {
                BrandMark()
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .topBarLeading) {
                BrandMark()
            }
        }
    }
}
