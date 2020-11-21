
import SwiftUI

extension UndoManager {

    var undoButton: some View {
        Button(action: undo, label: {
            Image(systemName: "arrow.uturn.left")
        })
        .disabled(!canUndo)
    }

    var redoButton: some View {
        Button(action: redo, label: {
            Image(systemName: "arrow.uturn.right")
        })
        .disabled(!canRedo)
    }
}