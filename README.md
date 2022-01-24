# Context

Replicates the benefits of a managed object context in SwiftUI. This comes with support for rolling back to the original state as well as undo and redo support.

Based on [IanKeen](https://github.com/IanKeen)'s [Transaction property wrapper](https://gist.github.com/IanKeen/a85e4ed74a10a25341c44a98f43cf386).

## Usage

The following code is provided in the example app in the Example directory of this repository. 

It produces a view that shows an editor to edit the first and last name fields.

Each editor can also provide a child editor that has it's own undo stack. When that editor saves, the change is represented as a single undo step in the parent editor.

``` swift
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
            UserEditor(user: Context($user))
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

extension Button where Label == Image {

    init(systemImage name: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Image(systemName: name)
        }
    }
}
```

