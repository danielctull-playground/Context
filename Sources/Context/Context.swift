
import SwiftUI

extension Binding {
    public var context: Context<Value> { Context(source: self) }
}

final class Classify<Value> {
    let value: Value
    init(value: Value) {
        self.value = value
    }
}

@propertyWrapper
@dynamicMemberLookup
public struct Context<Value>: DynamicProperty {

    @Binding private var source: Value
    @State private var current: Value
    private let undoManager: UndoManager

    fileprivate init(source: Binding<Value>) {
        self._source = source
        self._current = State(wrappedValue: source.wrappedValue)
        self.undoManager = UndoManager()
    }

    public var wrappedValue: Value {
        get { current }
        nonmutating set { setValue(newValue) }
    }

    public var projectedValue: Self { self }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        binding[dynamicMember: keyPath]
    }

    private func setValue(_ newValue: Value) {
        let oldValue = current
        current = newValue
        undoManager.registerUndo(withTarget: Classify(value: $current)) {
            $0.value.wrappedValue = oldValue
        }
    }

    private var binding: Binding<Value> {
        Binding(get: { current },
                set: setValue)
    }
}

// MARK: - Managing Changes

extension Context where Value: Equatable {
    public var hasChanges: Bool { source != current }
}

extension Context {

    public func save() {
        source = current
    }

    public func rollback() {
        current = source
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
