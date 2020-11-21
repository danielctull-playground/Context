
import SwiftUI

/// A property wrapper to track changes to a value.
@propertyWrapper
@dynamicMemberLookup
public struct Context<Value>: DynamicProperty {

    @Binding private var source: Value
    @UndoManaged private var value: Value

    public init(_ source: Binding<Value>) {
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
        undoManager.removeAllActions()
    }
}

// MARK: - Undo Support

extension Context {

    fileprivate var undoManager: UndoManager { $value }

    public var canUndo: Bool { undoManager.canUndo }
    public func undo() { undoManager.undo() }

    public var canRedo: Bool { undoManager.canRedo }
    public func redo() { undoManager.redo() }
}

// MARK: - Child Context

extension Context {

    public var child: Self { Context(binding) }
}
