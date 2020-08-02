
import SwiftUI

extension Binding {
    public var context: Context<Value> { Context(source: self) }
}

@propertyWrapper
@dynamicMemberLookup
public struct Context<Value>: DynamicProperty {

    @Binding private var source: Value
    @UndoManaged private var value: Value

    fileprivate init(source: Binding<Value>) {
        self._source = source
        self._value = UndoManaged(wrappedValue: source.wrappedValue)
    }

    public var projectedValue: Context<Value> { self }

    public var wrappedValue: Value {
        get { value }
        nonmutating set { value = newValue }
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        binding[dynamicMember: keyPath]
    }

    private var binding: Binding<Value> {
        Binding(get: { value },
                set: { value = $0 })
    }
}

// MARK: - Managing Changes

extension Context where Value: Equatable {
    public var hasChanges: Bool { source != value }
}

extension Context {

    public func save() {
        source = value
    }

    public func reset() {
        value = source
    }

    public func rollback() {
        value = source
        $value.removeAllActions()
    }
}

// MARK: - Undo Support

extension Context {

    public var canUndo: Bool { $value.canUndo }
    public func undo() { $value.undo() }

    public var canRedo: Bool { $value.canRedo }
    public func redo() { $value.redo() }
}

// MARK: - Child Context

extension Context {

    public var child: Self { binding.context }
}

// MARK: - Undo Buttons

extension Context {
    public var undoButton: some View { $value.undoButton }
    public var redoButton: some View { $value.redoButton }
}
