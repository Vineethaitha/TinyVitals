//
//  AppState.swift
//  TinyVitals
//
//  Created by admin0 on 1/25/26.
//

import Foundation
import AppIntents
import Supabase

final class AppState {

    static let shared = AppState()
    private init() {}

    var userId: String?
    private(set) var children: [ChildProfile] = []
    var activeChild: ChildProfile?

    // 🔥 SET FROM SUPABASE
    func setChildren(_ children: [ChildProfile]) {
        self.children = children
        self.activeChild = children.first
    }

    // 🔥 UPDATE CHILD
    func updateChild(_ child: ChildProfile) {
        if let index = children.firstIndex(where: { $0.id == child.id }) {
            children[index] = child
            activeChild = child
        }
    }

    // 🔥 ADD CHILD
    func addChild(_ child: ChildProfile) {
        children.append(child)
        activeChild = child
    }

    func setActiveChild(_ child: ChildProfile) {
        activeChild = child
    }

    func clear() {
        userId = nil
        children = []
        activeChild = nil
    }
    
    func removeChild(_ child: ChildProfile) {
        children.removeAll { $0.id == child.id }

        if activeChild?.id == child.id {
            activeChild = children.first
        }
    }

}

// MARK: - Siri Integration (App Intents)

@available(iOS 16.0, *)
struct UpcomingVaccineIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Upcoming Vaccination"
    static let description = IntentDescription("Find out how many days are left until a child's next vaccination.")

    @Parameter(title: "Child's Name", requestValueDialog: "Which child's vaccination do you want to check?")
    var childName: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Fetch session silently in background without UI
        guard let session = try? await SupabaseAuthService.shared.client.auth.session else {
            return .result(dialog: "Please open TinyVitals and log in first.")
        }
        
        // Query child table
        guard let children = try? await ChildService.shared.fetchChildren(userId: session.user.id) else {
            return .result(dialog: "I couldn't fetch your profile data from TinyVitals.")
        }
        
        // Find matching child using case-insensitive search to handle Siri capitalization quirks
        guard let child = children.first(where: { $0.name.localizedCaseInsensitiveContains(childName) }) else {
            return .result(dialog: "I couldn't find a child named \(childName) in your TinyVitals profile.")
        }
        
        guard let childId = child.id else {
            return .result(dialog: "There was an issue loading the records for \(child.name).")
        }
        
        // Query vaccines
        guard let vaccines = try? await VaccinationService.shared.fetchVaccines(childId: childId, dob: child.dob) else {
            return .result(dialog: "I couldn't fetch the vaccination records for \(child.name).")
        }
        
        let upcomingVaccines = vaccines
            .filter { $0.status == .upcoming && $0.date >= Date() }
            .sorted { $0.date < $1.date }
            
        guard let nextVaccine = upcomingVaccines.first else {
            return .result(dialog: "Great news! \(child.name) has all vaccinations up to date.")
        }
        
        // Calculate days cleanly
        let today = Calendar.current.startOfDay(for: Date())
        let dueDate = Calendar.current.startOfDay(for: nextVaccine.date)
        let daysLeft = Calendar.current.dateComponents([.day], from: today, to: dueDate).day ?? 0
        
        let dialog: IntentDialog
        if daysLeft == 0 {
            dialog = IntentDialog("\(child.name)'s \(nextVaccine.name) vaccination is due today.")
        } else if daysLeft == 1 {
            dialog = IntentDialog("\(child.name)'s \(nextVaccine.name) vaccination is due tomorrow.")
        } else {
            dialog = IntentDialog("\(child.name)'s \(nextVaccine.name) vaccination is coming up in \(daysLeft) days.")
        }
        
        return .result(dialog: dialog)
    }
}

@available(iOS 16.0, *)
struct LogFeverIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Fever"
    static let description = IntentDescription("Log a fever for a child in TinyVitals.")

    @Parameter(title: "Child's Name", requestValueDialog: "Which child has a fever?")
    var childName: String

    @Parameter(title: "Temperature", requestValueDialog: "What is the temperature?")
    var temperature: Double

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let session = try? await SupabaseAuthService.shared.client.auth.session else {
            return .result(dialog: "Please log in to TinyVitals first.")
        }
        guard let children = try? await ChildService.shared.fetchChildren(userId: session.user.id),
              let child = children.first(where: { $0.name.localizedCaseInsensitiveContains(childName) }),
              let childId = child.id else {
            return .result(dialog: "I couldn't find a child named \(childName).")
        }
        
        let dto = SymptomLogDTO(
            id: UUID(),
            child_id: childId,
            symptom_title: "Fever",
            logged_at: Date(),
            height: child.height,
            weight: child.weight,
            temperature: temperature,
            severity: 5,
            notes: "Logged via Siri",
            image_path: nil
        )
        do {
            try await SymptomService.shared.addSymptom(dto)
            return .result(dialog: "I've logged a fever of \(temperature) degrees for \(child.name).")
        } catch {
            return .result(dialog: "There was an error saving the fever to your account.")
        }
    }
}

@available(iOS 16.0, *)
struct CheckWeightIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Weight"
    static let description = IntentDescription("Check a child's latest weight in TinyVitals.")

    @Parameter(title: "Child's Name", requestValueDialog: "Whose weight do you want to check?")
    var childName: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let session = try? await SupabaseAuthService.shared.client.auth.session else {
            return .result(dialog: "Please log in to TinyVitals first.")
        }
        guard let children = try? await ChildService.shared.fetchChildren(userId: session.user.id),
              let child = children.first(where: { $0.name.localizedCaseInsensitiveContains(childName) }) else {
            return .result(dialog: "I couldn't find a child named \(childName).")
        }
        
        if let weight = child.weight {
            return .result(dialog: "\(child.name)'s latest recorded weight is \(weight) kilograms.")
        } else {
            return .result(dialog: "I don't have a weight recorded for \(child.name) yet.")
        }
    }
}

@available(iOS 16.0, *)
struct CheckPrescriptionsIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Prescriptions"
    static let description = IntentDescription("Check for recent prescriptions in TinyVitals.")

    @Parameter(title: "Child's Name", requestValueDialog: "Whose prescriptions do you want to check?")
    var childName: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let session = try? await SupabaseAuthService.shared.client.auth.session else {
            return .result(dialog: "Please log in to TinyVitals first.")
        }
        guard let children = try? await ChildService.shared.fetchChildren(userId: session.user.id),
              let child = children.first(where: { $0.name.localizedCaseInsensitiveContains(childName) }),
              let childId = child.id else {
            return .result(dialog: "I couldn't find a child named \(childName).")
        }
        
        guard let records = try? await MedicalRecordService.shared.fetchRecords(childId: childId) else {
            return .result(dialog: "I couldn't fetch the medical records for \(child.name).")
        }
        
        let prescriptions = records.filter { $0.folder_name.localizedCaseInsensitiveContains("Prescription") || $0.title.localizedCaseInsensitiveContains("Prescription") }
        
        if prescriptions.isEmpty {
            return .result(dialog: "\(child.name) doesn't have any prescriptions logged.")
        }
        
        let latest = prescriptions.first!
        let word = prescriptions.count == 1 ? "prescription" : "prescriptions"
        return .result(dialog: "\(child.name) has \(prescriptions.count) \(word) on file. The latest is \(latest.title).")
    }
}

@available(iOS 16.0, *)
struct LogGenericSymptomIntent: AppIntent {
    static let title: LocalizedStringResource = "Log a Symptom"
    static let description = IntentDescription("Log any generic symptom for a child in TinyVitals.")

    @Parameter(title: "Child's Name", requestValueDialog: "Which child has a symptom?")
    var childName: String

    @Parameter(title: "Symptom", requestValueDialog: "What symptom are they experiencing? For example: cough, rash, or headache.")
    var symptomName: String

    @Parameter(title: "Severity", requestValueDialog: "On a scale of 1 to 5, how severe is it?")
    var severity: Int

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let session = try? await SupabaseAuthService.shared.client.auth.session else {
            return .result(dialog: "Please log in to TinyVitals first.")
        }
        guard let children = try? await ChildService.shared.fetchChildren(userId: session.user.id),
              let child = children.first(where: { $0.name.localizedCaseInsensitiveContains(childName) }),
              let childId = child.id else {
            return .result(dialog: "I couldn't find a child named \(childName).")
        }
        
        // Clamp severity
        let validSeverity = max(1, min(5, severity))
        
        let dto = SymptomLogDTO(
            id: UUID(),
            child_id: childId,
            symptom_title: symptomName.capitalized,
            logged_at: Date(),
            height: child.height,
            weight: child.weight,
            temperature: nil,
            severity: validSeverity,
            notes: "Logged via Siri",
            image_path: nil
        )
        do {
            try await SymptomService.shared.addSymptom(dto)
            return .result(dialog: "I've logged a level \(validSeverity) \(symptomName) for \(child.name).")
        } catch {
            return .result(dialog: "There was an error saving the symptom to your account.")
        }
    }
}

@available(iOS 16.0, *)
struct TinyVitalsShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: UpcomingVaccineIntent(),
                phrases: [
                    "When is the next vaccination in \(.applicationName)?",
                    "How many days until the next vaccination in \(.applicationName)?",
                    "Check upcoming vaccine in \(.applicationName)"
                ],
                shortTitle: "Next Vaccination",
                systemImageName: "syringe"
            ),
            AppShortcut(
                intent: LogFeverIntent(),
                phrases: [
                    "Log a fever in \(.applicationName)",
                    "Log a temperature in \(.applicationName)",
                    "Record a fever in \(.applicationName)"
                ],
                shortTitle: "Log Fever",
                systemImageName: "thermometer"
            ),
            AppShortcut(
                intent: CheckWeightIntent(),
                phrases: [
                    "Check weight in \(.applicationName)",
                    "What is the latest weight in \(.applicationName)?"
                ],
                shortTitle: "Check Weight",
                systemImageName: "scalemass"
            ),
            AppShortcut(
                intent: CheckPrescriptionsIntent(),
                phrases: [
                    "Check prescriptions in \(.applicationName)",
                    "Are there any new prescriptions in \(.applicationName)?",
                    "Find prescriptions in \(.applicationName)"
                ],
                shortTitle: "Check Prescriptions",
                systemImageName: "doc.text.magnifyingglass"
            ),
            AppShortcut(
                intent: LogGenericSymptomIntent(),
                phrases: [
                    "Log a symptom in \(.applicationName)",
                    "Record a symptom in \(.applicationName)",
                    "Add a symptom in \(.applicationName)"
                ],
                shortTitle: "Log Symptom",
                systemImageName: "bandage"
            )
        ]
    }
}
