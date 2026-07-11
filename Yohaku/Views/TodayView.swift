import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \YohakuBlock.startTime) private var blocks: [YohakuBlock]
    @Binding var displayedDay: Date
    @State private var isAdding = false
    @State private var isShowingInfo = false
    @State private var editing: YohakuBlock?
    @State private var releasing: YohakuBlock?

    private var dayBlocks: [YohakuBlock] {
        blocks.filter { DateHelpers.isSameDay($0.date, displayedDay) }
    }

    private var isToday: Bool {
        DateHelpers.isSameDay(displayedDay, Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    daySelector

                    if dayBlocks.isEmpty {
                        EmptyStateView(message: isToday ? "empty.today" : "empty.day")

                        ghostAddCard
                    } else {
                        VStack(spacing: 12) {
                            ForEach(dayBlocks) { block in
                                YohakuBlockCard(block: block)
                                    .onTapGesture {
                                        editing = block
                                    }
                                    .contextMenu {
                                        Button {
                                            editing = block
                                        } label: {
                                            Label("action.edit", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            releasing = block
                                        } label: {
                                            Label("action.release", systemImage: "trash")
                                        }
                                    }
                            }

                            ghostAddCard
                        }
                    }
                }
                .padding(24)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        if value.translation.width < -40 {
                            shiftDay(by: 1)
                        } else if value.translation.width > 40 {
                            shiftDay(by: -1)
                        }
                    }
            )
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
            .sheet(isPresented: $isAdding) {
                AddYohakuView(presetDate: displayedDay)
            }
            .sheet(isPresented: $isShowingInfo) {
                AboutView()
            }
            .sheet(item: $editing) { block in
                AddYohakuView(editing: block)
            }
            .confirmationDialog("confirm.release", isPresented: releaseBinding, titleVisibility: .visible) {
                Button("action.release", role: .destructive) {
                    if let block = releasing {
                        NotificationManager.cancel(id: block.id)
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

    private var ghostAddCard: some View {
        Button {
            isAdding = true
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            Color.primary.opacity(colorScheme == .dark ? 0.35 : 0.18),
                            style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                        )
                )
                .frame(height: 72)
                .overlay(
                    Image(systemName: "plus")
                        .font(.body)
                        .foregroundStyle(colorScheme == .dark ? .primary : .secondary)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("add.title"))
    }

    private var daySelector: some View {
        HStack(spacing: 16) {
            Button {
                shiftDay(by: -1)
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("accessibility.previous_day"))

            Text(displayedDay, format: .dateTime.month().day().weekday())
                .font(.subheadline)
                .foregroundStyle(isToday ? .primary : .secondary)
                .frame(maxWidth: .infinity)

            Button {
                shiftDay(by: 1)
            } label: {
                Image(systemName: "chevron.forward")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("accessibility.next_day"))
        }
    }

    private func shiftDay(by value: Int) {
        if let shifted = Calendar.current.date(byAdding: .day, value: value, to: displayedDay) {
            displayedDay = shifted
        }
    }
}

#Preview {
    TodayView(displayedDay: .constant(Date()))
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
