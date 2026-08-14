import SwiftUI

struct HelpView: View {

    @ObservedObject var viewModel: HelpViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(viewModel.items) { item in
                NavigationLink {
                    TextReaderView(
                        viewModel: .init(title: item.title, text: item.text, isBackButtonHidden: false)
                    )
                } label: {
                    Text(item.title)
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .chcklstNavigationBar()
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(viewModel: .init())
    }
}
