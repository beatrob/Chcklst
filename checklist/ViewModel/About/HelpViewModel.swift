import Foundation

struct WelcomeWizardPage: Identifiable {

    let id: String
    let introducedInVersion: Int
    let titleKey: String
    let descriptionKey: String
    let systemImage: String
}

enum WelcomeWizardCatalog {

    static let currentVersion = 1

    static let allPages: [WelcomeWizardPage] = [
        .init(
            id: "welcome",
            introducedInVersion: 1,
            titleKey: "welcome_wizard_welcome_title",
            descriptionKey: "welcome_wizard_welcome_description",
            systemImage: "checklist"
        ),
        .init(
            id: "checklists",
            introducedInVersion: 1,
            titleKey: "welcome_wizard_checklists_title",
            descriptionKey: "welcome_wizard_checklists_description",
            systemImage: "checkmark.circle"
        ),
        .init(
            id: "templates",
            introducedInVersion: 1,
            titleKey: "welcome_wizard_templates_title",
            descriptionKey: "welcome_wizard_templates_description",
            systemImage: "doc.on.doc"
        ),
        .init(
            id: "schedules",
            introducedInVersion: 1,
            titleKey: "welcome_wizard_schedules_title",
            descriptionKey: "welcome_wizard_schedules_description",
            systemImage: "calendar.badge.clock"
        ),
        .init(
            id: "reminders",
            introducedInVersion: 1,
            titleKey: "welcome_wizard_reminders_title",
            descriptionKey: "welcome_wizard_reminders_description",
            systemImage: "bell.badge"
        )
    ]
}

enum WelcomeWizardMode {
    case automatic
    case help
}

struct WelcomeWizardPresentation: Identifiable {

    let id = UUID()
    let pages: [WelcomeWizardPage]
    let mode: WelcomeWizardMode
}

protocol WelcomeWizardStateManaging: AnyObject {

    var lastViewedVersion: Int { get }

    func pages(for mode: WelcomeWizardMode) -> [WelcomeWizardPage]
    func markCurrentVersionViewed()
}

final class WelcomeWizardStateManager: WelcomeWizardStateManaging {

    private let userDefaults: UserDefaults
    private let allPages: [WelcomeWizardPage]
    private let currentVersion: Int

    var lastViewedVersion: Int {
        userDefaults.lastViewedWelcomeWizardVersion
    }

    init(
        userDefaults: UserDefaults = .standard,
        allPages: [WelcomeWizardPage] = WelcomeWizardCatalog.allPages,
        currentVersion: Int = WelcomeWizardCatalog.currentVersion
    ) {
        self.userDefaults = userDefaults
        self.allPages = allPages
        self.currentVersion = currentVersion
    }

    func pages(for mode: WelcomeWizardMode) -> [WelcomeWizardPage] {
        switch mode {
        case .automatic:
            return allPages.filter { $0.introducedInVersion > lastViewedVersion }
        case .help:
            return allPages
        }
    }

    func markCurrentVersionViewed() {
        userDefaults.setLastViewedWelcomeWizardVersion(
            max(lastViewedVersion, currentVersion)
        )
    }
}
