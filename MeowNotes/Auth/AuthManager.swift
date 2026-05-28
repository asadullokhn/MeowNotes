import Foundation
import Observation

// Mirrors src/composables/useAuth.js + the slice of useApp.js that owns `me`.
// Drives routing in ContentView via `phase`.
@MainActor
@Observable
final class AuthManager {
    enum Phase {
        case booting          // checking for a stored session on launch
        case unauthenticated
        case authenticated
    }

    private(set) var phase: Phase = .booting
    private(set) var user: User?
    private(set) var cats: [Cat] = []

    var isAuthenticated: Bool { phase == .authenticated }

    // On launch: if a token exists, hydrate from /api/me; drop it on 401.
    func boot() async {
        guard TokenStore.token != nil else {
            phase = .unauthenticated
            return
        }
        do {
            let me: MeResponse = try await API.get("/api/me")
            hydrate(user: me.user, cats: me.cats)
        } catch let error as APIError where error.isUnauthorized {
            TokenStore.token = nil
            hydrate(user: nil, cats: [])
        } catch {
            // Network/other failure on boot: keep the token, show login so the
            // user can retry rather than silently wiping a valid session.
            phase = .unauthenticated
        }
    }

    func login(email: String, password: String) async throws {
        let auth: AuthResponse = try await API.post("/api/auth/login", LoginRequest(email: email, password: password))
        TokenStore.token = auth.token
        try await loadMe()
    }

    func register(name: String, email: String, password: String) async throws {
        let auth: AuthResponse = try await API.post(
            "/api/auth/register", RegisterRequest(name: name, email: email, password: password)
        )
        TokenStore.token = auth.token
        try await loadMe()
    }

    func logout() {
        TokenStore.token = nil
        hydrate(user: nil, cats: [])
    }

    // MARK: - Placeholder flows (no backend yet — needs new API endpoints)

    // Forgot password: request a reset for an email, then submit a new password.
    // Stubbed to validate the UI flow until POST /api/auth/forgot-password and
    // POST /api/auth/reset-password exist.
    func requestPasswordReset(email: String) async throws {
        try await Task.sleep(for: .milliseconds(600))
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        try await Task.sleep(for: .milliseconds(600))
    }

    // Change password while signed in. Stubbed until POST /api/auth/change-password exists.
    func changePassword(currentPassword: String, newPassword: String) async throws {
        try await Task.sleep(for: .milliseconds(600))
    }

    // MARK: - Helpers

    private func loadMe() async throws {
        let me: MeResponse = try await API.get("/api/me")
        hydrate(user: me.user, cats: me.cats)
    }

    private func hydrate(user: User?, cats: [Cat]) {
        self.user = user
        self.cats = cats
        phase = user == nil ? .unauthenticated : .authenticated
    }
}
