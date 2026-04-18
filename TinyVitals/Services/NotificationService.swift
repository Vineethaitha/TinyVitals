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
    
    /// Fetches background data and schedules vaccination reminders for all registered children in the app.
    func scheduleAllVaccinationReminders() {
        Task {
            let children = AppState.shared.children
            for child in children {
                do {
                    let vaccines = try await VaccinationService.shared.fetchVaccines(
                        childId: child.id,
                        dob: child.dob
                    )
                    updateVaccinationReminders(childId: child.id.uuidString, childName: child.name, vaccines: vaccines)
                } catch {
//                    print("❌ Failed to schedule background vaccinations for \(child.name)")
                }
            }
        }
    }
    
    /// Re-schedules all upcoming vaccination reminders, clearing out strictly the old vaccine ones.
    func updateVaccinationReminders(childId: String, childName: String, vaccines: [VaccineItem]) {
        let center = UNUserNotificationCenter.current()
        let childSpecificPrefix = "\(vaccinePrefix)\(childId)_"
        
        // 1. Fetch all pending reminders so we can selectively remove only the old vaccine ones for THIS child
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            
            // Find identifiers that start with this child's unique prefix
            let vaccineIdentifiers = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(childSpecificPrefix) }
            
            // Remove ONLY vaccines for this specific child
            center.removePendingNotificationRequests(withIdentifiers: vaccineIdentifiers)
            
            // 2. Schedule the new ones
            let upcoming = vaccines.filter { $0.status == .upcoming }
            let grouped = Dictionary(grouping: upcoming) { $0.ageGroup }
            
            for (ageGroup, vaccinesInGroup) in grouped {
                // Get the earliest vaccine due date in this group as the basis for the reminder
                guard let first = vaccinesInGroup.sorted(by: { $0.date < $1.date }).first else { continue }
                self.scheduleGroupedReminder(
                    childId: childId,
                    ageGroup: ageGroup,
                    dueDate: first.date,
                    childName: childName
                )
            }
        }
    }
    
    private func scheduleGroupedReminder(childId: String, ageGroup: String, dueDate: Date, childName: String) {
        let reminderOffsets: [(daysBefore: Int, message: String)] = [
            (28, "in 4 weeks"),
            (21, "in 3 weeks"),
            (14, "in 2 weeks"),
            (7, "in 1 week"),
            (1, "tomorrow")
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
            content.title = "Vaccination Reminder"
            content.body = "\(childName)'s \(ageGroup) vaccinations are due \(offset.message)."
            content.sound = .default
            
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour],
                from: reminderDate
            )
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
            
            // Create a unique identifier uniquely tied to the child
            let uniqueId = "\(vaccinePrefix)\(childId)_\(ageGroup)_\(offset.daysBefore)days"
            let request = UNNotificationRequest(
                identifier: uniqueId,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { _ in
            }
        }
    }
    
    /// Schedules educational push notifications every 2 days to teach the user about Siri commands.
    func scheduleSiriEducationalNotifications() {
        let center = UNUserNotificationCenter.current()
        let siriPrefix = "siri_tip_"
        
        // 1. Check if we already have a Siri tip scheduled
        center.getPendingNotificationRequests { requests in
            let hasPendingSiriTip = requests.contains { $0.identifier.hasPrefix(siriPrefix) }
            
            // Only schedule a new one if there isn't one already waiting
            if hasPendingSiriTip { return }
            
            // 2. Define the Siri tips
            let siriTips = [
                ("Log a fever easily with Siri", "Simply say: \"Hey Siri, log a fever in TinyVitals\""),
                ("Check upcoming vaccinations", "Simply say: \"Hey Siri, when is the next vaccination in TinyVitals?\""),
                ("Update a vaccine status hands-free", "Simply say: \"Hey Siri, update vaccination status in TinyVitals\""),
                ("Check your child's weight", "Simply say: \"Hey Siri, check weight in TinyVitals\""),
                ("Find prescriptions quickly", "Simply say: \"Hey Siri, check prescriptions in TinyVitals\""),
                ("Log any symptom with Siri", "Simply say: \"Hey Siri, log a symptom in TinyVitals\"")
            ]
            
            // 3. Get the next tip index from UserDefaults
            let tipIndex = UserDefaults.standard.integer(forKey: "nextSiriTipIndex")
            let tip = siriTips[tipIndex % siriTips.count]
            
            // Increment and save for next time
            UserDefaults.standard.set(tipIndex + 1, forKey: "nextSiriTipIndex")
            
            // 4. Schedule EXACTLY ONE notification for 2 days from now
            let content = UNMutableNotificationContent()
            content.title = tip.0
            content.body = tip.1
            content.sound = .default
            
            let daysFromNow = 2
            guard let targetDate = Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) else { return }
            
            var components = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
            components.hour = 10
            components.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "\(siriPrefix)\(tipIndex)",
                content: content,
                trigger: trigger
            )
            
            center.add(request)
        }
    }
}
