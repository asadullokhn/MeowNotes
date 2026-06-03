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

    // On launch: hydrate a stored session. With no stored token we show the auth
    // landing (sign in / create account / continue as guest) and let the user
    // pick how to start, rather than silently creating a guest.
    func boot() async {
        guard TokenStore.token != nil else {
            phase = .unauthenticated
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

    // Anonymous sign-in, triggered by "Continue as guest" on the auth screen.
    // Throws so the caller can surface a failure. A guest has no cats yet, so
    // ContentView routes to onboarding next. The token (365-day) is stored like
    // any other; cat, photo, sharing, etc. all work against a guest the same way.
    func continueAsGuest() async throws {
        let auth: AuthResponse = try await API.post(
            "/api/auth/guest", GuestRequest(name: nil), headers: ["X-App-Key": API.appKey]
        )
        TokenStore.token = auth.token
        try await loadMe()
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
        // Clear device-local preferences tied to the session so the next person
        // (or a fresh guest) starts clean — appearance otherwise persists in
        // UserDefaults. Reset to System rather than removing the key so the
        // @AppStorage binding in ContentView picks up the change immediately.
        UserDefaults.standard.set(AppAppearance.system.rawValue, forKey: "appearance")
    }

    // PATCH /api/me — update the owner's profile (works for guests too). The
    // server ignores a blank name and clears phone sent as "".
    func updateProfile(name: String, phone: String) async throws {
        let updated: User = try await API.patch(
            "/api/me", ProfilePatch(name: name, phone: phone)
        )
        user = updated
    }

    private struct ProfilePatch: Encodable {
        let name: String
        let phone: String
    }

    // DELETE /api/me — permanently remove the account and everything it owns
    // (cats + share links). Works for guests and registered users. Drops the
    // local session afterward so the app returns to the unauthenticated state.
    func deleteAccount() async throws {
        try await API.delete("/api/me")
        logout()
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
    func addCat(name: String, photo: String?, dob: String? = nil, gender: String? = nil) async throws {
        let created: Cat = try await API.post(
            "/api/cats", CatDraft(name: name, photo: photo, dob: dob, gender: gender)
        )
        cats.append(created)
        selectedCatID = created.id
    }

    private struct CatDraft: Encodable {
        let name: String
        let photo: String?
        let dob: String?
        let gender: String?
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
    func updateBasics(catID: String, name: String, photo: String?, breed: String?, dob: String?, gender: String?) async throws {
        let updated: Cat = try await API.patch(
            "/api/cats/\(catID)",
            BasicsPatch(name: name, photo: photo, breed: breed, dob: dob, gender: gender)
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

    // MARK: - Care sections
    // Each PATCHes a single section's full array; the server only touches the
    // keys it receives, and the response replaces the cached cat so the home
    // grid counts and other views reflect the save immediately.

    func updateRoutine(catID: String, _ feedingRoutine: [RoutineItem]) async throws {
        let updated: Cat = try await API.patch("/api/cats/\(catID)", RoutinePatch(feedingRoutine: feedingRoutine))
        replaceCachedCat(updated)
    }

    func updateChecks(catID: String, _ checks: [CheckItem]) async throws {
        let updated: Cat = try await API.patch("/api/cats/\(catID)", ChecksPatch(checks: checks))
        replaceCachedCat(updated)
    }

    // Caution and Additions both live in `notes` (split by `urgent`), so callers
    // pass the full recombined array to avoid clobbering the other half.
    func updateNotes(catID: String, _ notes: [Note]) async throws {
        let updated: Cat = try await API.patch("/api/cats/\(catID)", NotesPatch(notes: notes))
        replaceCachedCat(updated)
    }

    func updatePersonality(catID: String, traits: [String], summary: String) async throws {
        let updated: Cat = try await API.patch(
            "/api/cats/\(catID)",
            PersonalityPatch(personality: traits, personalitySummary: summary)
        )
        replaceCachedCat(updated)
    }

    // POST /api/generate/personality — server-side note generation (a local model
    // over the tunnel). Returns the summary text and throws on any non-2xx so the
    // caller can fall back to an on-device template. 35s client timeout matches
    // the web (the server aborts at 30s).
    func generatePersonality(name: String, traits: [String]) async throws -> String {
        let result: GeneratedPersonality = try await API.post(
            "/api/generate/personality",
            GeneratePersonalityRequest(name: name, traits: traits),
            timeout: 35
        )
        return result.summary
    }

    private struct RoutinePatch: Encodable { let feedingRoutine: [RoutineItem] }
    private struct ChecksPatch: Encodable { let checks: [CheckItem] }
    private struct NotesPatch: Encodable { let notes: [Note] }
    private struct PersonalityPatch: Encodable { let personality: [String]; let personalitySummary: String }

    // MARK: - Sharing

    // GET /api/cats/:id/share — fetch the cat's active sitter-guide link,
    // creating one server-side if it doesn't exist yet. A freshly-added cat has
    // no share row, so this is what turns the bare domain into a real
    // /#/g/<token> link (the reason guests saw no link before).
    func shareLink(catID: String) async throws -> String {
        let link: SharedLink = try await API.get("/api/cats/\(catID)/share")
        return link.token
    }

    // POST /api/cats/:id/shares — expire the current link and mint a fresh one
    // (the "Refresh" action), cutting off anyone holding the old URL.
    func rotateShareLink(catID: String) async throws -> String {
        let link: SharedLink = try await API.post("/api/cats/\(catID)/shares", Empty())
        return link.token
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

    // dob is sent explicitly (string or null) so clearing it clears on the
    // server; the rest only encode when present (blank = leave unchanged).
    private struct BasicsPatch: Encodable {
        let name: String
        let photo: String?
        let breed: String?
        let dob: String?
        let gender: String?

        enum CodingKeys: String, CodingKey { case name, photo, breed, dob, gender }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(name, forKey: .name)
            try c.encodeIfPresent(photo, forKey: .photo)
            try c.encodeIfPresent(breed, forKey: .breed)
            try c.encode(dob, forKey: .dob)
            try c.encodeIfPresent(gender, forKey: .gender)
        }
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
