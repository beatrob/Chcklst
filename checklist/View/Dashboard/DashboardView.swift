import SwiftUI

struct DashboardView: View {

    @StateObject var viewModel: DashboardViewModel
    @State var isSearching = false

    var body: some View {
        ZStack {
            Color.mainBackground.ignoresSafeArea()
            dashboardContent
        }
        .navigationTitle("Checklists")
        .navigationBarTitleDisplayMode(.inline)
        .if(isSearching) {
            $0.searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button { viewModel.onCreateNewChecklist.send() } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create new checklist")
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.isSortAndFilterPresented = true
                } label: {
                    Image(systemName: viewModel.selectedSort == .initial && viewModel.selectedFilter == .initial
                          ? "line.3.horizontal.decrease.circle"
                          : "line.3.horizontal.decrease.circle.fill")
                }
                .accessibilityLabel("Sort and filter")

                Button {
                    withAnimation {
                        isSearching.toggle()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search")
            }
        }
        .chcklstNavigationBar()
        .alert(isPresented: $viewModel.isAlertVisible) { viewModel.alert }
        .sheet(
            item: Binding(
                get: { viewModel.presentedSheet },
                set: viewModel.updatePresentedSheet
            ),
            onDismiss: viewModel.didDismissPresentedSheet
        ) { presentation in
            switch presentation {
            case .sortAndFilter:
                SortAndFilterView(
                    selectedSort: $viewModel.selectedSort,
                    selectedFilter: $viewModel.selectedFilter
                )
                .presentationDetents([.medium])
            case .actions:
                BottomActionSheet(title: viewModel.actionSheet.title) {
                    viewModel.actionSheet.buttons(onSelection: viewModel.dismissActionSheet)
                }
            case .content:
                viewModel.sheet
            }
        }
    }

    @ViewBuilder
    private var dashboardContent: some View {
        if viewModel.isEmptyListViewVisible {
            EmptyListView(
                message: "Your list is empty",
                actionTitle: "+ create new",
                onActionTappedSubject: viewModel.onCreateNewChecklist
            )
        } else if viewModel.isNoSearchResultsVisible {
            EmptyListView(message: "No results found", actionTitle: nil, onActionTappedSubject: nil)
        } else if viewModel.isNoFilterResulrsVisible {
            EmptyListView(
                message: "No results found",
                actionTitle: "Clear filter",
                onActionTappedSubject: viewModel.onClearFilter
            )
        } else {
            ScrollView {
                ScrollViewReader { reader in
                    LazyVStack {
                        ForEach(viewModel.checklistCells, id: \.id) { cell in
                            DashboardChecklistCell(viewModel: cell)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 7)
                        }
                    }
                    .onChange(of: viewModel.scrollToId) { newValue in
                        guard let newValue else { return }
                        withAnimation { reader.scrollTo(newValue, anchor: .top) }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

private struct SortAndFilterView: View {

    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSort: SortDataModel
    @Binding var selectedFilter: FilterDataModel

    var body: some View {
        NavigationStack {
            List {
                Section("Sort by") {
                    ForEach(SortDataModel.allCases) { sort in
                        selectionRow(title: sort.title, isSelected: selectedSort == sort) {
                            selectedSort = sort
                        }
                    }
                }
                Section("Filter by") {
                    ForEach(FilterDataModel.allCases) { filter in
                        selectionRow(title: filter.title, isSelected: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .navigationTitle("Sort & Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        selectedSort = .initial
                        selectedFilter = .initial
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .chcklstNavigationBar()
        }
    }

    private func selectionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected { Image(systemName: "checkmark") }
            }
        }
        .accessibilityValue(isSelected ? "Selected" : "")
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView(
                viewModel: DashboardViewModel(
                    checklistDataSource: MockChecklistDataSource(),
                    templateDataSource: MockTemplateDataSource(),
                    scheduleDataSource: MockScheduleDataSource(),
                    navigationHelper: NavigationHelper(),
                    checklistFilterAndSort: ChecklistFilterAndSortImpl(dataSource: MockChecklistDataSource()),
                    notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource()),
                    restrictionManager: MockRestrictionManager()
                )
            )
        }
    }
}
