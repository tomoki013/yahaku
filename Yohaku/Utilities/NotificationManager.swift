import Foundation
import UserNotifications

enum NotificationManager {
    static var isEnabled: Bool {
        (UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool) ?? true
    }

    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func schedule(for block: YohakuBlock) {
        cancel(id: block.id)
        guard isEnabled, block.startTime > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = block.title
        content.body = String(localized: "notification.message")
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: block.startTime
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: block.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func rescheduleAll(_ blocks: [YohakuBlock]) {
        cancelAll()
        for block in blocks {
            schedule(for: block)
        }
    }
}
