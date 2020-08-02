
import SwiftUI

@propertyWrapper
struct UndoManaged<Value>: DynamicProperty {

    @StateObject private var container: Container<Value>

    init(wrappedValue value: Value) {
        let container = Container(value: value, undoManager: UndoManager())
        self._container = StateObject(wrappedValue: container)
    }

    var projectedValue: UndoManager { container.undoManager }

    var wrappedValue: Value {
        get { container.value }
        nonmutating set { container.value = newValue }
    }
}

// Container

private final class Container<Value>: ObservableObject {

    init(value: Value, undoManager: UndoManager) {
        self.value = value
        self.undoManager = undoManager
    }

    let undoManager: UndoManager

    var value: Value {
        willSet {
            objectWillChange.send()
        }
        didSet {
            undoManager.registerUndo(withTarget: self) { $0.value = oldValue }
        }
    }
}

// MARK: - Undo Buttons

extension UndoManager {

    var undoButton: some View {
        Button(action: undo, label: {
            Image(systemName: "arrow.uturn.left")
        })
        .disabled(!canUndo)
    }

    var redoButton: some View {
        Button(action: redo, label: {
            Image(systemName: "arrow.uturn.right")
        })
        .disabled(!canRedo)
    }
}
