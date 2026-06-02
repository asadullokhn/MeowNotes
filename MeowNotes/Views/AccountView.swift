// Owner: Asad
//
// Account / profile / settings. Shows the signed-in user and hosts the
// signed-in auth actions: Change Password and Logout.

import SwiftUI

struct AccountView: View {
    @Environment(AuthManager.self) private var auth
    @State private var showChangePassword = false
    @State private var showClaim = false
    @State private var showProfileEdit = false
    @State private var showDeleteConfirm = false
    @State private var deleting = false
    @State private var deleteError: String?
    @AppStorage("appearance") private var appearance = AppAppearance.system.rawValue

    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    profileHeader

                    VStack(spacing: 0) {
                        row(icon: "person.text.rectangle", title: "Edit profile") {
                            showProfileEdit = true
                        }
                        if !auth.isGuest {
                            Divider().padding(.leading, 56)
                            row(icon: "key.fill", title: "Change password") {
                                showChangePassword = true
                            }
                            Divider().padding(.leading, 56)
                            row(icon: "rectangle.portrait.and.arrow.right",
                                title: "Log out", tint: Color(red: 0.79, green: 0.44, blue: 0.42)) {
                                auth.logout()
                            }
                        }
                    }
                    .background(Color("BubbleBg"))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color("BubbleBorder"), lineWidth: 1)
                    )

                    appearanceCard

                    if auth.isGuest {
                        guestCard
                    }

                    dangerCard
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
            .sheet(isPresented: $showClaim) {
                ClaimAccountView()
            }
            .sheet(isPresented: $showProfileEdit) {
                ProfileEditView()
            }
            .alert(auth.isGuest ? "Delete data?" : "Delete account?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { performDelete() }
            } message: {
                Text(auth.isGuest
                    ? "This permanently deletes your cats and their care guides. As a guest there's no way to recover them — create an account first if you want to keep them."
                    : "This permanently deletes your account, your cats, and their care guides. This can't be undone.")
            }
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Appearance")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color("TextColor"))
            Picker("Appearance", selection: $appearance) {
                ForEach(AppAppearance.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("BubbleBg"))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color("BubbleBorder"), lineWidth: 1)
        )
    }

    private var dangerCard: some View {
        VStack(spacing: 10) {
            Button {
                showDeleteConfirm = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.79, green: 0.44, blue: 0.42))
                        .frame(width: 40, height: 40)
                        .background(Color("AppBg"))
                        .clipShape(Circle())
                    Text(deleting ? "Deleting…" : (auth.isGuest ? "Delete data" : "Delete account"))
                        .font(.body.weight(.medium))
                        .foregroundColor(Color(red: 0.79, green: 0.44, blue: 0.42))
                    Spacer()
                    if deleting {
                        ProgressView()
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color("TextColor").opacity(0.3))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .disabled(deleting)
            .background(Color("BubbleBg"))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color("BubbleBorder"), lineWidth: 1)
            )

            if let deleteError {
                AuthErrorBanner(message: deleteError)
            }
        }
    }

    private func performDelete() {
        guard !deleting else { return }
        deleteError = nil
        deleting = true
        Task {
            do {
                // On success this logs out; ContentView swaps away from Account.
                try await auth.deleteAccount()
            } catch {
                deleteError = error.localizedDescription
            }
            deleting = false
        }
    }

    private var guestCard: some View {
        VStack(spacing: 14) {
            VStack(spacing: 6) {
                Text("You're browsing as a guest")
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                Text("Keep your cats and sign in on another device.")
                    .font(.subheadline)
                    .foregroundColor(Color("TextColor").opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            AuthPrimaryButton(title: "Create account") { showClaim = true }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color("BubbleBg"))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color("BubbleBorder"), lineWidth: 1)
        )
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
            } else if auth.isGuest {
                Text("Guest account")
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
