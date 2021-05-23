import Combine
import SwiftUI


class CheckboxViewModel: ObservableObject, Identifiable, Equatable {
    
    var id: String { title }
    let title: String
    let data: Any?
    @Published var isChecked: Bool
    var checked: AnyPublisher<Bool, Never>  {
        $isChecked.eraseToAnyPublisher()
    }
    
    init(title: String, isChecked: Bool, data: Any? = nil) {
        self.title = title
        self.isChecked = isChecked
        self.data = data
    }
    
    static func == (lhs: CheckboxViewModel, rhs: CheckboxViewModel) -> Bool {
        lhs.id == rhs.id && lhs.isChecked == rhs.isChecked
    }
}
