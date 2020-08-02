
import SwiftUI

@propertyWrapper
@dynamicMemberLookup
struct UndoManaged<Value>: DynamicProperty {

    @StateObject private var container: Container<Value>

    init(wrappedValue value: Value) {
        let container = Container(value: value, undoManager: UndoManager())
        self._container = StateObject(wrappedValue: container)
    }

    var projectedValue: UndoManaged<Value> { self }

    var wrappedValue: Value {
        get { container.value }
        nonmutating set { container.value = newValue }
    }

    subscript<T>(dynamicMember keyPath: KeyPath<UndoManager, T>) -> T {
        container.undoManager[keyPath: keyPath]
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

// MARK: - Exposing UndoManager Functions

extension UndoManaged {
    func undo() { container.undoManager.undo() }
    func redo() { container.undoManager.redo() }
    func removeAllActions() { container.undoManager.removeAllActions() }
}

// MARK: - Undo Buttons

extension UndoManaged {

    var undoButton: some View {
        Button(action: undo, label: {
            Image(systemName: "arrow.uturn.left")
        })
        .disabled(!self.canUndo)
    }

    var redoButton: some View {
        Button(action: redo, label: {
            Image(systemName: "arrow.uturn.right")
        })
        .disabled(!self.canRedo)
    }
}
