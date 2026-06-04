import Foundation

// A selected care note (a Caution or an Addition) while it's being edited.
// Carries a stable id so SwiftUI's ForEach tracks each row by identity, not by
// array index — editing or removing a row never reads a stale/out-of-range
// position (the old index-based ForEach crashed on remove).
struct TagItem: Identifiable, Hashable {
    let id = UUID()
    var text: String
}
