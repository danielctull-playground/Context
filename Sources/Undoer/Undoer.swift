
import SwiftUI

extension Binding {
    public var undoer: Undoer<Value> { Undoer(source: self) }
}

@propertyWrapper
@dynamicMemberLookup
public struct Undoer<Value>: DynamicProperty {

    @State private var past: [Value]
    @State private var future: [Value]
    @Binding private var current: Value

    fileprivate init(source: Binding<Value>) {
        self._past = State(wrappedValue: [])
        self._current = source
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

    public var binding: Binding<Value> {
        Binding(get: { current },
                set: { newValue in
                    past.append(current)
                    future = []
                    current = newValue
                })
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
