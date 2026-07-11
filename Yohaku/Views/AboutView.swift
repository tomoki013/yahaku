import SwiftUI
import SwiftData

enum AppInfo {
    // TODO: 公開時に実際のURLに差し替える
    static let privacyPolicyURL = URL(string: "https://example.com/yohaku/privacy")!
    static let termsURL = URL(string: "https://example.com/yohaku/terms")!

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @Query private var blocks: [YohakuBlock]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 10) {
                        BrandMark()
                        Text("about.tagline")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        appearanceRow

                        Divider()
                            .overlay(Color.primary.opacity(0.1))

                        Toggle(isOn: $notificationsEnabled) {
                            Text("notification.title")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        .toggleStyle(MonoToggleStyle())
                        .padding(.vertical, 14)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled {
                                NotificationManager.requestAuthorization()
                                NotificationManager.rescheduleAll(blocks)
                            } else {
                                NotificationManager.cancelAll()
                            }
                        }
                    }

                    VStack(spacing: 0) {
                        legalRow(titleKey: "about.privacy") {
                            LegalTextView(
                                titleKey: "about.privacy",
                                bodyKey: "privacy.body",
                                url: AppInfo.privacyPolicyURL
                            )
                        }

                        Divider()
                            .overlay(Color.primary.opacity(0.1))

                        legalRow(titleKey: "about.terms") {
                            LegalTextView(
                                titleKey: "about.terms",
                                bodyKey: "terms.body",
                                url: AppInfo.termsURL
                            )
                        }

                        Divider()
                            .overlay(Color.primary.opacity(0.1))

                        HStack {
                            Text("about.version")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(verbatim: AppInfo.version)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 14)
                    }
                }
                .padding(24)
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel(Text("action.close"))
                }
            }
        }
        .tint(.primary)
    }

    private func legalRow(titleKey: LocalizedStringKey, destination: @escaping () -> some View) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Text(titleKey)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var appearanceRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("appearance.title")
                .font(.body)
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                    let isSelected = appearanceMode == mode.rawValue
                    Button {
                        appearanceMode = mode.rawValue
                    } label: {
                        Text(mode.labelKey)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundStyle(isSelected ? Color(.systemBackground) : .secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.primary : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        Color.primary.opacity(isSelected ? 0 : 0.2),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 14)
    }
}

// ON=真っ黒(ダーク時は真っ白)の塗り、OFF=薄いグレーの白黒トグル
struct MonoToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer()
                Capsule()
                    .fill(configuration.isOn ? Color.primary : Color.primary.opacity(0.15))
                    .frame(width: 52, height: 32)
                    .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                        Circle()
                            .fill(Color(.systemBackground))
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                            .padding(3)
                    }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: configuration.isOn)
    }
}

struct LegalTextView: View {
    let titleKey: LocalizedStringKey
    let bodyKey: LocalizedStringKey
    let url: URL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(titleKey)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(bodyKey)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(6)

                Link(destination: url) {
                    HStack(spacing: 6) {
                        Text("privacy.web")
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

#Preview {
    AboutView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
