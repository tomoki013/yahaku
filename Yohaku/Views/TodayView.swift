import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \YohakuBlock.startTime) private var blocks: [YohakuBlock]
    @State private var isAdding = false
    @State private var releasing: YohakuBlock?

    private var todayBlocks: [YohakuBlock] {
        blocks.filter { DateHelpers.isSameDay($0.date, Date()) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    if todayBlocks.isEmpty {
                        EmptyStateView(message: "empty.today")
                    } else {
                        VStack(spacing: 12) {
                            ForEach(todayBlocks) { block in
                                YohakuBlockCard(block: block)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            releasing = block
                                        } label: {
                                            Label("action.release", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAdding = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.black)
                    }
                    .accessibilityLabel(Text("add.title"))
                }
            }
            .sheet(isPresented: $isAdding) {
                AddYohakuView()
            }
            .confirmationDialog("confirm.release", isPresented: releaseBinding, titleVisibility: .visible) {
                Button("action.release", role: .destructive) {
                    if let block = releasing {
                        modelContext.delete(block)
                    }
                    releasing = nil
                }
                Button("action.close", role: .cancel) {
                    releasing = nil
                }
            }
        }
    }

    private var releaseBinding: Binding<Bool> {
        Binding(
            get: { releasing != nil },
            set: { if !$0 { releasing = nil } }
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: "Yohaku")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.black)
            Text(Date(), format: .dateTime.month().day())
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
