import SwiftUI
import UIKit

// Shared building blocks for the auth screens, styled to match the team's
// named-color palette (AppBg cream / SaveBg ink / BubbleBorder ring / XBtnBg sage).

// Labeled text field: uppercase "eyebrow" caption + white rounded input,
// mirroring the web's `.eyebrow` + rounded-2xl input.
struct AuthField: View {
    let label: String
    var placeholder: String = ""
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var submitLabel: SubmitLabel = .next
    var onSubmit: () -> Void = {}
    var limit: Int = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(0.8)
                .foregroundColor(Color("TextColor").opacity(0.55))

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
            .autocorrectionDisabled(keyboard == .emailAddress)
            .keyboardType(keyboard)
            .textContentType(textContentType)
            .submitLabel(submitLabel)
            .onSubmit(onSubmit)
            .characterLimit(limit, $text)
            .foregroundColor(Color("TextColor"))
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color("BubbleBg"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("BubbleBorder"), lineWidth: 1)
            )
        }
    }
}

// Full-width dark primary button with a loading state, mirroring the web's
// `bg-ink` pill button.
struct AuthPrimaryButton: View {
    let title: String
    var loading: Bool = false
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if loading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color("SaveBg"))
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .opacity(disabled || loading ? 0.5 : 1)
        }
        .disabled(disabled || loading)
    }
}

// Inline error banner, mirroring the web's rose-tinted error box.
// A translucent rose tint keeps the same look in light mode and stays legible
// in dark mode (the page background shows through instead of a bright box).
struct AuthErrorBanner: View {
    private static let rose = Color(red: 0.79, green: 0.44, blue: 0.42)
    let message: String
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundColor(Self.rose)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Self.rose.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Self.rose.opacity(0.4), lineWidth: 1)
            )
    }
}

// Shared validation used across login / register / reset / change.
enum AuthValidation {
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        // Minimal "x@y.z" check — boundary validation, the server is authoritative.
        return trimmed.contains("@") && trimmed.split(separator: "@").count == 2
            && trimmed.split(separator: "@").last?.contains(".") == true
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }
}
