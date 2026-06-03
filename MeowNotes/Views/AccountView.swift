// Owner: Asad
//
// Account / profile / settings. Shows the signed-in user and hosts the
// signed-in auth actions: Change Password and Logout.

import SwiftUI

struct AccountView: View {
    @Environment(AuthManager.self) private var auth
    @State private var showChangePassword = false
    @State private var showClaim = false
    @State private var showDeleteConfirm = false
    @State private var showLogoutConfirm = false
    @State private var deleting = false
    @State private var deleteError: String?
    // Inline profile editing (name + phone), right here in Settings.
    @State private var name = ""
    @State private var phone = ""
    @State private var savingProfile = false
    @State private var profileError = ""
    @State private var loadedProfile = false
    @AppStorage("appearance") private var appearance = AppAppearance.system.rawValue
    @AppStorage("haptics") private var hapticsEnabled = true

    var body: some View {
        ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader

                    profileSection

                    VStack(spacing: 0) {
                        if !auth.isGuest {
                            row(icon: "key.fill", title: "Change password") {
                                showChangePassword = true
                            }
                            Divider().padding(.leading, 56)
                        }
                        row(icon: "rectangle.portrait.and.arrow.right",
                            title: "Log out", tint: Color(red: 0.79, green: 0.44, blue: 0.42)) {
                            showLogoutConfirm = true
                        }
                    }
                    .background(Color("BubbleBg"))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color("BubbleBorder"), lineWidth: 1)
                    )

                    appearanceCard

                    hapticsCard

                    if auth.isGuest {
                        guestCard
                    }

                    dangerCard
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadProfile() }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
            .sheet(isPresented: $showClaim) {
                ClaimAccountView()
            }
            .alert(auth.isGuest ? "Delete data?" : "Delete account?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { performDelete() }
            } message: {
                Text(auth.isGuest
                    ? "This permanently deletes your cats and their care guides. As a guest there's no way to recover them — create an account first if you want to keep them."
                    : "This permanently deletes your account, your cats, and their care guides. This can't be undone.")
            }
            .alert("Log out?", isPresented: $showLogoutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Log out", role: .destructive) { auth.logout() }
            } message: {
                Text(auth.isGuest
                    ? "You're using a guest account. 'Continue as guest' brings these cats back on this device — create an account to keep them safe everywhere."
                    : "You can sign back in any time.")
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

    private var hapticsCard: some View {
        Toggle(isOn: $hapticsEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Haptic feedback")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color("TextColor"))
                Text("Subtle taps on buttons and actions")
                    .font(.caption)
                    .foregroundColor(Color("TextColor").opacity(0.6))
            }
        }
        .tint(Color(.bubbleSelectedBg))
        .onChange(of: hapticsEnabled) { _, on in if on { Haptics.tap(.medium) } }
        .padding(16)
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
                .contentShape(Rectangle())
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

    // No uploaded photo — show the owner's initials (or a paw for an unnamed
    // guest) in a tinted circle.
    private var profileHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(Color(.bubbleSelectedBg))
                if initials.isEmpty {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                } else {
                    Text(initials)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 78, height: 78)

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

    private var initials: String {
        (auth.user?.name ?? "")
            .split(separator: " ").prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    private var canSaveProfile: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    private var profileChanged: Bool {
        name.trimmingCharacters(in: .whitespaces) != (auth.user?.name ?? "") ||
        phone.trimmingCharacters(in: .whitespaces) != (auth.user?.phone ?? "")
    }

    // Edit name + phone inline. "Save changes" dims until something changes.
    private var profileSection: some View {
        VStack(spacing: 12) {
            AuthField(label: "Your name", text: $name, textContentType: .name)
            AuthField(label: "Phone · optional", placeholder: "+62 812 3456 7890", text: $phone,
                      keyboard: .phonePad, textContentType: .telephoneNumber,
                      submitLabel: .done, onSubmit: saveProfile)
            if !profileError.isEmpty { AuthErrorBanner(message: profileError) }
            AuthPrimaryButton(title: "Save changes", loading: savingProfile,
                              disabled: !canSaveProfile || !profileChanged, action: saveProfile)
        }
    }

    private func loadProfile() {
        guard !loadedProfile, let user = auth.user else { return }
        name = user.name
        phone = user.phone ?? ""
        loadedProfile = true
    }

    private func saveProfile() {
        guard canSaveProfile, profileChanged, !savingProfile else { return }
        profileError = ""
        savingProfile = true
        Task {
            do {
                try await auth.updateProfile(
                    name: name.trimmingCharacters(in: .whitespaces),
                    phone: phone.trimmingCharacters(in: .whitespaces)
                )
                Haptics.success()
            } catch {
                profileError = error.localizedDescription
            }
            savingProfile = false
        }
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountView()
        .environment(AuthManager())
}
