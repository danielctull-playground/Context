
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
            HStack {
                $user.undoButton
                $user.redoButton
            }
        }
        .padding()
    }
}
