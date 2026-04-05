import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private let calendar = Calendar.current
    
    // Identifier prefix for vaccination reminders
    private let vaccinePrefix = "vaccine_"
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted {
//                    print("Notification permission granted.")
                } else {
//                    print("Notification permission denied.")
                }
            }
    }
    
    /// Re-schedules all upcoming vaccination reminders, clearing out strictly the old vaccine ones.
    func updateVaccinationReminders(childName: String, vaccines: [VaccineItem]) {
        let center = UNUserNotificationCenter.current()
        
        // 1. Fetch all pending reminders so we can selectively remove only the old vaccine ones
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            
            // Find identifiers that start with our vaccinePrefix
            let vaccineIdentifiers = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(self.vaccinePrefix) }
            
            // Remove ONLY vaccine reminders
            center.removePendingNotificationRequests(withIdentifiers: vaccineIdentifiers)
            
            // 2. Schedule the new ones
            let upcoming = vaccines.filter { $0.status == .upcoming }
            let grouped = Dictionary(grouping: upcoming) { $0.ageGroup }
            
            for (ageGroup, vaccinesInGroup) in grouped {
                // Get the earliest vaccine due date in this group as the basis for the reminder
                guard let first = vaccinesInGroup.sorted(by: { $0.date < $1.date }).first else { continue }
                self.scheduleGroupedReminder(
                    ageGroup: ageGroup,
                    dueDate: first.date,
                    childName: childName
                )
            }
        }
    }
    
    private func scheduleGroupedReminder(ageGroup: String, dueDate: Date, childName: String) {
        let reminderOffsets: [(daysBefore: Int, message: String)] = [
            (28, "4 weeks left"),
            (21, "3 weeks left"),
            (14, "2 weeks left"),
            (1, "Vaccination is tomorrow")
        ]
        
        for offset in reminderOffsets {
            guard let reminderDate = calendar.date(
                byAdding: .day,
                value: -offset.daysBefore,
                to: dueDate
            ) else { continue }
            
            // Don't schedule reminders in the past
            if reminderDate < Date() { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "\(childName)'s Vaccination Reminder"
            
            if offset.daysBefore == 1 {
                content.body = "\(ageGroup) vaccinations are due tomorrow."
            } else {
                content.body = "\(offset.message) for \(ageGroup) vaccinations."
            }
            
            content.sound = .default
            
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour],
                from: reminderDate
            )
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
            
            // Create a unique identifier, ensuring it starts with the designated prefix
            let uniqueId = "\(vaccinePrefix)\(ageGroup)_\(offset.daysBefore)days_\(Int(dueDate.timeIntervalSince1970))"
            let request = UNNotificationRequest(
                identifier: uniqueId,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { _ in
            }
        }
    }
}
