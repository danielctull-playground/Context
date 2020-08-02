
import SwiftUI

extension Binding {
    public var context: Context<Value> { Context(source: self) }
}

@propertyWrapper
@dynamicMemberLookup
public struct Context<Value>: DynamicProperty {

    private final class Container: ObservableObject {

        let undoManager: UndoManager

        init(value: Value, undoManager: UndoManager) {
            self.value = value
            self.undoManager = undoManager
        }

        var value: Value {
            willSet { objectWillChange.send() }
            didSet { undoManager.registerUndo(withTarget: self) { $0.value = oldValue } }
        }
    }

    @Binding private var source: Value
    @StateObject private var container: Container

    fileprivate init(source: Binding<Value>) {
        self._source = source
        let container = Container(value: source.wrappedValue, undoManager: UndoManager())
        self._container = StateObject(wrappedValue: container)
    }

    public var wrappedValue: Value {
        get { container.value }
        nonmutating set { container.value = newValue }
    }

    public var projectedValue: Self { self }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        binding[dynamicMember: keyPath]
    }

    private var binding: Binding<Value> {
        Binding(get: { container.value },
                set: { container.value = $0 })
    }
}

// MARK: - Managing Changes

extension Context where Value: Equatable {
    public var hasChanges: Bool { source != container.value }
}

extension Context {

    public func save() {
        source = container.value
    }

    public func rollback() {
        container.value = source
        container.undoManager.removeAllActions()
    }
}

// MARK: - Undo Support

extension Context {

    public var canUndo: Bool { container.undoManager.canUndo }
    public func undo() { container.undoManager.undo() }

    public var canRedo: Bool { container.undoManager.canRedo }
    public func redo() { container.undoManager.redo() }
}

// MARK: - Child Context

extension Context {

    public var child: Self { binding.context }
}
