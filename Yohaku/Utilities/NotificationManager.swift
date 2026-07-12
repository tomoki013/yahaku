import Foundation
import UserNotifications

enum NotificationManager {
    private static let enabledKey = "notificationsEnabled"

    static var isEnabled: Bool {
        (UserDefaults.standard.object(forKey: enabledKey) as? Bool) ?? false
    }

    // トグルが一度でも確定したか(初回許可の結果、または明示的な操作)
    private static var hasStoredPreference: Bool {
        UserDefaults.standard.object(forKey: enabledKey) != nil
    }

    // 最初の余白が置かれた時だけ許可を求め、許可されたらトグルをオンにする。
    // 一度オフが確定した後は何もしない(明示的なオフを尊重する)
    static func requestInitialAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        guard !hasStoredPreference else {
            completion(isEnabled)
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: enabledKey)
                completion(granted)
            }
        }
    }

    // トグルをオンにした時に呼ぶ。OS のポップは未確定の時しか出ず、
    // 確定済みなら既存の許可状態がそのまま返る
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
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
