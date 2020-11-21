
import Context
import SwiftUI

struct User: Equatable {
    var firstName: String
    var lastName: String
}

struct ContentView: View {

    @State var user = User(firstName: "", lastName: "")
    @State var showEdit = false

    var body: some View {
        VStack {
            Text("First Name: \(user.firstName)")
            Text("Last Name: \(user.lastName)")
            Button("Edit") { showEdit = true }
        }
        .sheet(isPresented: $showEdit) {
            UserEditor(user: $user.context)
        }
    }
}

struct UserEditor: View {
    @Context var user: User
    @State var showEdit = false

    var body: some View {
        VStack {
            TextField("First Name", text: $user.firstName)
            TextField("Last Name", text: $user.lastName)
            HStack {

                Button(systemImage: "arrow.uturn.left", action: $user.undo)
                    .disabled(!$user.canUndo)

                Button(systemImage: "arrow.uturn.right", action: $user.redo)
                    .disabled(!$user.canRedo)

                Group {
                    Button("Save", action: $user.save)
                    Button("Reset", action: $user.reset)
                    Button("Rollback", action: $user.rollback)
                }
                .disabled(!$user.hasChanges)
            }
            Button("New Editor") { showEdit = true }
        }
        .padding()
        .sheet(isPresented: $showEdit) {
            UserEditor(user: $user.child)
        }
    }
}
