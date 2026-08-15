import SwiftUI

struct DashboardView: View {

    @StateObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            Color.mainBackground.ignoresSafeArea()
            dashboardContent
        }
        .navigationTitle("Checklists")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $viewModel.searchText,
            prompt: Text("title, description or item")
        )
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isSortAndFilterPresented = true
                } label: {
                    Image(systemName: viewModel.selectedSort == .initial && viewModel.selectedFilter == .initial
                          ? "line.3.horizontal.decrease.circle"
                          : "line.3.horizontal.decrease.circle.fill")
                }
                .accessibilityLabel("Sort and filter")

                Button { viewModel.onCreateNewChecklist.send() } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create new checklist")
            }
        }
        .chcklstNavigationBar()
        .sheet(isPresented: $viewModel.isSortAndFilterPresented) {
            SortAndFilterView(
                selectedSort: $viewModel.selectedSort,
                selectedFilter: $viewModel.selectedFilter
            )
            .presentationDetents([.medium])
        }
        .alert(isPresented: $viewModel.isAlertVisible) { viewModel.alert }
        .sheet(
            isPresented: Binding(
                get: { viewModel.isActionSheetPresented },
                set: { if !$0 { viewModel.dismissActionSheet() } }
            )
        ) {
            BottomActionSheet(title: viewModel.actionSheet.title) {
                viewModel.actionSheet.buttons(onSelection: viewModel.dismissActionSheet)
            }
        }
        .sheet(isPresented: $viewModel.isSheetVisible) { viewModel.sheet }
    }

    @ViewBuilder
    private var dashboardContent: some View {
        if viewModel.isEmptyListViewVisible {
            EmptyListView(
                message: "Your list is empty",
                actionTitle: "New Checklist",
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
