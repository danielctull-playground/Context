
import SwiftUI

extension Binding {
    public var context: Context<Value> { Context(source: self) }
}

/// A property wrapper to track changes to a value.
@propertyWrapper
@dynamicMemberLookup
public struct Context<Value>: DynamicProperty {

    @Binding private var source: Value
    @UndoManaged private var value: Value

    fileprivate init(source: Binding<Value>) {
        _source = source
        _value = UndoManaged(wrappedValue: source.wrappedValue)
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

    /// Saves the changes to the source provided in the initializer.
    public func save() {
        source = value
    }

    /// Discards all changes made and reverts back to the value for the source.
    ///
    /// This function leaves the undo stack in place. If you wish to reset the
    /// undo stack as well, use `rollback()`.
    public func reset() {
        value = source
    }

    /// Discards all changes made and reverts back to the value for the source.
    ///
    /// This restores the value to its last saved state and removes everything
    /// from the undo stack. Use `reset()` if you do not wish to lose the
    /// contents of the undo stack.
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
