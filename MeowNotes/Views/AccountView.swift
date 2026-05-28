// Owner: Asad
//
// Account / profile / settings. Shows the signed-in user and hosts the
// signed-in auth actions: Change Password and Logout.

import SwiftUI

struct AccountView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @State private var showChangePassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader

                    VStack(spacing: 0) {
                        row(icon: "key.fill", title: "Change password") {
                            showChangePassword = true
                        }
                        Divider().padding(.leading, 56)
                        row(icon: "rectangle.portrait.and.arrow.right",
                            title: "Log out", tint: Color(red: 0.79, green: 0.44, blue: 0.42)) {
                            auth.logout()
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color("BubbleBorder"), lineWidth: 1)
                    )
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("TextColor"))
                }
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color("XBtnBg"))
            Text(auth.user?.name ?? "MeowNotes")
                .font(.title2.weight(.bold))
                .foregroundColor(Color("TextColor"))
            if let email = auth.user?.email {
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(Color("TextColor").opacity(0.6))
            }
            if !auth.cats.isEmpty {
                Text("^[\(auth.cats.count) cat](inflect: true)")
                    .font(.caption)
                    .foregroundColor(Color("TextColor").opacity(0.5))
            }
        }
        .padding(.top, 12)
    }

    private func row(icon: String, title: String, tint: Color = Color("TextColor"),
                     action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(tint)
                    .frame(width: 40, height: 40)
                    .background(Color("AppBg"))
                    .clipShape(Circle())
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(tint)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color("TextColor").opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountView()
        .environment(AuthManager())
}
