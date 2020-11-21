
import SwiftUI

extension Button where Label == Image {

    init(systemImage name: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Image(systemName: name)
        }
    }
}
