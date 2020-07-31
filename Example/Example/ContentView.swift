
import Undoer
import SwiftUI

struct User: Equatable {
    var firstName: String
    var lastName: String
}

struct ContentView: View {

    @State var user = User(firstName: "", lastName: "")
    @State var showEdit = false

    var body: some View {
        UserEditor(user: $user.undoer)
    }
}

struct UserEditor: View {
    @Undoer var user: User

    var body: some View {
        VStack {
            TextField("First Name", text: $user.firstName)
            TextField("Last Name", text: $user.lastName)
            Divider()
            Button("Undo", action: $user.undo).disabled(!$user.canUndo)
            Button("Redo", action: $user.redo).disabled(!$user.canRedo)
        }
    }
}
