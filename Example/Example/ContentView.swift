
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

    var body: some View {
        VStack {
            TextField("First Name", text: $user.firstName)
            TextField("Last Name", text: $user.lastName)
            HStack {
                $user.undoButton
                $user.redoButton
                Button("Save", action: $user.save).disabled(!$user.hasChanges)
                Button("Rollback", action: $user.rollback).disabled(!$user.hasChanges)
            }
        }
        .padding()
    }
}
