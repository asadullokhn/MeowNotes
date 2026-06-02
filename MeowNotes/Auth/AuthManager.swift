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
    private(set) var selectedCatID: String?

    var isAuthenticated: Bool { phase == .authenticated }
    var isGuest: Bool { user?.isGuest == true }

    // The cat currently shown across the app. Falls back to the first cat.
    var currentCat: Cat? {
        cats.first { $0.id == selectedCatID } ?? cats.first
    }

    func selectCat(_ id: String) {
        selectedCatID = id
    }

    // On launch: hydrate a stored session, or silently create a guest one so a
    // first-time user lands straight in the app without a login wall.
    func boot() async {
        guard TokenStore.token != nil else {
            await signInAsGuest()
            return
        }
        do {
            let me: MeResponse = try await API.get("/api/me")
            hydrate(user: me.user, cats: me.cats)
        } catch let error as APIError where error.isUnauthorized {
            // Stored token is no longer valid — drop it and show login so a real
            // account holder can re-authenticate (don't silently orphan them).
            TokenStore.token = nil
            hydrate(user: nil, cats: [])
        } catch {
            // Network/other failure on boot: keep the token, show login so the
            // user can retry rather than silently wiping a valid session.
            phase = .unauthenticated
        }
    }

    // Anonymous sign-in. The token (365-day) is stored like any other; the cat,
    // photo, sharing, etc. features all work against a guest the same way.
    private func signInAsGuest() async {
        do {
            let auth: AuthResponse = try await API.post(
                "/api/auth/guest", GuestRequest(name: nil), headers: ["X-App-Key": API.appKey]
            )
            TokenStore.token = auth.token
            try await loadMe()
        } catch {
            phase = .unauthenticated
        }
    }

    // Convert the current guest into a full account, keeping all their cats.
    func claim(email: String, name: String, password: String) async throws {
        let auth: AuthResponse = try await API.post(
            "/api/auth/claim", ClaimRequest(email: email, name: name, password: password)
        )
        TokenStore.token = auth.token
        try await loadMe()
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

    // PATCH /api/me — update the owner's profile (works for guests too). The
    // server ignores a blank name and clears phone/location sent as "".
    func updateProfile(name: String, phone: String, location: String) async throws {
        let updated: User = try await API.patch(
            "/api/me", ProfilePatch(name: name, phone: phone, location: location)
        )
        user = updated
    }

    private struct ProfilePatch: Encodable {
        let name: String
        let phone: String
        let location: String
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

    // MARK: - Cat updates

    // POST /api/cats with a new cat draft, then add it to the cache and select
    // it so it becomes the current cat (mirrors the web's addCat).
    func addCat(name: String, photo: String?) async throws {
        let created: Cat = try await API.post("/api/cats", CatDraft(name: name, photo: photo))
        cats.append(created)
        selectedCatID = created.id
    }

    private struct CatDraft: Encodable {
        let name: String
        let photo: String?
    }

    // PATCH /api/cats/:id with the cat's medical record, then replace the cached
    // cat with the server's response so `currentCat` reflects the save.
    func updateMedical(catID: String, _ medical: Medical) async throws {
        let updated: Cat = try await API.patch("/api/cats/\(catID)", CatPatch(medical: medical))
        replaceCachedCat(updated)
    }

    // PATCH the cat's basics. Only non-nil fields are encoded, and the server
    // only updates the keys it receives — so leaving a field blank preserves it
    // instead of overwriting it with an empty value.
    func updateBasics(catID: String, name: String, photo: String?, breed: String?, age: String?) async throws {
        let updated: Cat = try await API.patch(
            "/api/cats/\(catID)",
            BasicsPatch(name: name, photo: photo, breed: breed, age: age)
        )
        replaceCachedCat(updated)
    }

    // Mark a cat as deceased (or undo). Reversible — un-marking clears the date.
    func setDeceased(catID: String, deceased: Bool, date: String?) async throws {
        let updated: Cat = try await API.patch(
            "/api/cats/\(catID)",
            DeceasedPatch(deceased: deceased, deceasedDate: date)
        )
        replaceCachedCat(updated)
    }

    // DELETE /api/cats/:id, then drop it from the cache and reselect another cat.
    func deleteCat(catID: String) async throws {
        try await API.delete("/api/cats/\(catID)")
        cats.removeAll { $0.id == catID }
        if selectedCatID == catID {
            selectedCatID = cats.first?.id
        }
    }

    private func replaceCachedCat(_ cat: Cat) {
        if let index = cats.firstIndex(where: { $0.id == cat.id }) {
            cats[index] = cat
        }
    }

    // Partial cat updates — only the keys we send are touched server-side.
    private struct CatPatch: Encodable {
        let medical: Medical
    }

    private struct BasicsPatch: Encodable {
        let name: String
        let photo: String?
        let breed: String?
        let age: String?
    }

    // Custom encoding so `deceasedDate` is sent as an explicit null when nil
    // (to clear it on un-mark) rather than being omitted.
    private struct DeceasedPatch: Encodable {
        let deceased: Bool
        let deceasedDate: String?

        enum CodingKeys: String, CodingKey { case deceased, deceasedDate }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(deceased, forKey: .deceased)
            try c.encode(deceasedDate, forKey: .deceasedDate)
        }
    }

    // MARK: - Helpers

    private func loadMe() async throws {
        let me: MeResponse = try await API.get("/api/me")
        hydrate(user: me.user, cats: me.cats)
    }

    private func hydrate(user: User?, cats: [Cat]) {
        self.user = user
        self.cats = cats
        // Keep the selection valid; default to the first cat.
        if selectedCatID == nil || !cats.contains(where: { $0.id == selectedCatID }) {
            selectedCatID = cats.first?.id
        }
        phase = user == nil ? .unauthenticated : .authenticated
    }
}
