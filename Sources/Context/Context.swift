
import SwiftUI

extension Binding {
    public var context: Context<Value> { Context(source: self) }
}

@propertyWrapper
@dynamicMemberLookup
public struct Context<Value>: DynamicProperty {

    final class Box: ObservableObject {
        init(value: Value) {
            self.value = value
        }
        var value: Value {
            willSet { objectWillChange.send() }
        }
    }

    @Binding private var source: Value
    @StateObject private var current: Box
    private let undoManager: UndoManager

    fileprivate init(source: Binding<Value>) {
        self._source = source
        self._current = StateObject(wrappedValue: Box(value: source.wrappedValue))
        self.undoManager = UndoManager()
    }

    public var wrappedValue: Value {
        get { current.value }
        nonmutating set { setValue(newValue) }
    }

    public var projectedValue: Self { self }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        binding[dynamicMember: keyPath]
    }

    private func setValue(_ newValue: Value) {
        let oldValue = current.value
        current.value = newValue
        undoManager.registerUndo(withTarget: current) { $0.value = oldValue }
    }

    private var binding: Binding<Value> {
        Binding(get: { current.value },
                set: setValue)
    }
}

// MARK: - Managing Changes

extension Context where Value: Equatable {
    public var hasChanges: Bool { source != current.value }
}

extension Context {

    public func save() {
        source = current.value
    }

    public func rollback() {
        current.value = source
        undoManager.removeAllActions()
    }
}

// MARK: - Undo Support

extension Context {

    public var canUndo: Bool { undoManager.canUndo }
    public func undo() { undoManager.undo() }

    public var canRedo: Bool { undoManager.canRedo }
    public func redo() { undoManager.redo() }
}

// MARK: - Child Context

extension Context {

    public var child: Self { binding.context }
}
