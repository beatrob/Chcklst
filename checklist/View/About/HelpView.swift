import SwiftUI

struct WelcomeWizardView: View {

    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize = 112.0

    let pages: [WelcomeWizardPage]
    let mode: WelcomeWizardMode
    let stateManager: WelcomeWizardStateManaging

    @State private var selectedPageIndex = 0
    @State private var didMarkViewed = false

    private var isFirstPage: Bool {
        selectedPageIndex == 0
    }

    private var isLastPage: Bool {
        selectedPageIndex == pages.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("welcome_wizard_cancel_button", action: finish)
                Spacer()
            }
            .padding()

            TabView(selection: $selectedPageIndex) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    WelcomeWizardPageView(
                        page: page,
                        iconSize: iconSize
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .accessibilityValue(pageProgressAccessibilityValue)

            HStack(spacing: 24) {
                Button("welcome_wizard_back_button", action: showPreviousPage)
                    .disabled(isFirstPage)
                    .opacity(isFirstPage ? 0 : 1)
                    .accessibilityHidden(isFirstPage)

                Spacer()

                Button(action: showNextPageOrFinish) {
                    Text(primaryButtonTitle)
                        .foregroundStyle(Color.lightText)
                        .fontWeight(.semibold)
                        .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .background(Color.mainBackground.ignoresSafeArea())
        .tint(.firstAccent)
        .onDisappear(perform: markViewed)
    }

    private var primaryButtonTitle: LocalizedStringKey {
        guard isLastPage else {
            return "welcome_wizard_next_button"
        }
        switch mode {
        case .automatic:
            return "welcome_wizard_get_started_button"
        case .help:
            return "welcome_wizard_done_button"
        }
    }

    private var pageProgressAccessibilityValue: Text {
        Text(
            String(
                format: NSLocalizedString(
                    "welcome_wizard_page_progress_accessibility_value",
                    comment: "Current welcome wizard page and total page count"
                ),
                selectedPageIndex + 1,
                pages.count
            )
        )
    }

    private func showPreviousPage() {
        guard !isFirstPage else { return }
        withAnimation {
            selectedPageIndex -= 1
        }
    }

    private func showNextPageOrFinish() {
        guard !isLastPage else {
            finish()
            return
        }
        withAnimation {
            selectedPageIndex += 1
        }
    }

    private func finish() {
        markViewed()
        dismiss()
    }

    private func markViewed() {
        guard !didMarkViewed else { return }
        didMarkViewed = true
        stateManager.markCurrentVersionViewed()
    }
}

private struct WelcomeWizardPageView: View {

    let page: WelcomeWizardPage
    let iconSize: Double

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 24)

                Image(systemName: page.systemImage)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color.firstAccent)
                    .accessibilityHidden(true)

                VStack(spacing: 16) {
                    Text(LocalizedStringKey(page.titleKey))
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text(LocalizedStringKey(page.descriptionKey))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .accessibilityElement(children: .combine)

                Spacer(minLength: 80)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    WelcomeWizardView(
        pages: WelcomeWizardCatalog.allPages,
        mode: .help,
        stateManager: WelcomeWizardStateManager(
            userDefaults: UserDefaults(suiteName: "WelcomeWizardPreview")!
        )
    )
}
