
import SwiftUI

extension Binding {
    public var context: Context<Value> { Context(source: self) }
}

@propertyWrapper
@dynamicMemberLookup
public struct Context<Value>: DynamicProperty {

    @Binding private var source: Value
    @State private var past: [Value]
    @State private var future: [Value]
    @State private var current: Value

    fileprivate init(source: Binding<Value>) {
        self._source = source
        self._current = State(wrappedValue: source.wrappedValue)
        self._past = State(wrappedValue: [])
        self._future = State(wrappedValue: [])
    }

    public var wrappedValue: Value {
        get { current }
        nonmutating set { setValue(newValue) }
    }

    public var projectedValue: Self { self }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        binding[dynamicMember: keyPath]
    }

    private func setValue(_ value: Value) {
        past.append(current)
        future = []
        current = value
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
        future = []
        past = []
    }
}

// MARK: - Undo Support

extension Context {

    public var canUndo: Bool { !past.isEmpty }
    public func undo() {
        let previous = past.removeLast()
        future.append(current)
        current = previous
    }

    public var canRedo: Bool { !future.isEmpty }
    public func redo() {
        let next = future.removeLast()
        past.append(current)
        current = next
    }
}

// MARK: - Child Context

extension Context {

    public var child: Self { binding.context }
}
