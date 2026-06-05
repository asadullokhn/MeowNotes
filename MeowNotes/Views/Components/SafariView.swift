// Owner: TBD (claim by editing this line)
//
// Thin SwiftUI wrapper around SFSafariViewController so we can show a web page
// (the shared sitter guide) in an in-app browser without leaving MeowNotes.
// The controller brings its own Done button and an "Open in Safari" handoff.

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.dismissButtonStyle = .done
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
