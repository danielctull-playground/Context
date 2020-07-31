
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
        nonmutating set {
            past.append(current)
            future = []
            current = newValue
        }
    }

    public var projectedValue: Self { self }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        binding[dynamicMember: keyPath]
    }

    private var binding: Binding<Value> {
        Binding(get: { current },
                set: { newValue in
                    past.append(current)
                    future = []
                    current = newValue
                })
    }

    public func save() {
        source = current
    }

    public func rollback() {
        current = source
        future = []
        past = []
    }

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

extension Context where Value: Equatable {
    public var hasChanges: Bool { source != current }
}
