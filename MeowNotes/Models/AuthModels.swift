import Foundation

// Matches serializeUser() on the server. `email` is null and `isGuest` is true
// for anonymous guest accounts.
struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String?
    let name: String
    let phone: String?
    let avatar: String?
    let location: String?
    let isGuest: Bool?
}

// Subset of serializeCat() needed to hydrate the session. The server sends more
// fields; decoding ignores keys we don't model, so this stays robust as the cat
// schema grows.
struct Cat: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let breed: String?
    let age: CatAge?
    let photo: String?
    let personalitySummary: String?
    let sharedLinks: [SharedLink]?
    let medical: Medical?
    let personality: [String]?
    let feedingRoutine: [CountItem]?
    let checks: [CountItem]?
    let notes: [Note]?
    let deceased: Bool?
    let deceasedDate: String?

    // First active share link, if any — used to build the sitter guide URL.
    var shareToken: String? {
        (sharedLinks?.first { $0.status == "active" } ?? sharedLinks?.first)?.token
    }

    // Per-section counts shown on the home grid (mirrors Home.vue).
    var traitCount: Int { personality?.count ?? 0 }
    var routineCount: Int { feedingRoutine?.count ?? 0 }
    var checkCount: Int { checks?.count ?? 0 }
    var cautionCount: Int { notes?.lazy.filter { $0.urgent == true }.count ?? 0 }
    var noteCount: Int { notes?.lazy.filter { $0.urgent != true }.count ?? 0 }
    var vetName: String? {
        guard let name = medical?.vet.name, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return name
    }
}

// Age is stored loosely server-side: legacy cats have an integer (years), but
// we now also accept free text like "8 months". Decodes either into a display
// string and re-encodes as a string.
struct CatAge: Codable, Equatable {
    let display: String

    init(_ display: String) { self.display = display }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let s = try? c.decode(String.self) {
            display = s
        } else if let i = try? c.decode(Int.self) {
            display = i > 0 ? String(i) : ""
        } else if let d = try? c.decode(Double.self) {
            display = d > 0 ? String(Int(d)) : ""
        } else {
            display = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(display)
    }
}

// Opaque array element: lets us decode (and count) lists whose item shape we
// don't otherwise model, like feedingRoutine and checks.
struct CountItem: Codable, Equatable {}

// A care-guide note. `urgent` notes are surfaced as "Caution"; the rest are
// "Additions" — matching the web's split of the single notes array.
struct Note: Codable, Equatable {
    let urgent: Bool?
}

// A cat's medical record. Stored server-side as the JSON `medical` blob and
// PATCHed back whole. Missing sections decode to sensible empties, so a cat
// with `medical: {}` is valid.
struct Medical: Codable, Equatable {
    var vet: Vet
    var vaccines: [Vaccine]
    var medications: [Medication]

    init(vet: Vet = Vet(), vaccines: [Vaccine] = [], medications: [Medication] = []) {
        self.vet = vet
        self.vaccines = vaccines
        self.medications = medications
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        vet = try c.decodeIfPresent(Vet.self, forKey: .vet) ?? Vet()
        vaccines = try c.decodeIfPresent([Vaccine].self, forKey: .vaccines) ?? []
        medications = try c.decodeIfPresent([Medication].self, forKey: .medications) ?? []
    }

    struct Vet: Codable, Equatable {
        var name: String
        var clinic: String
        var phone: String
        var address: String

        init(name: String = "", clinic: String = "", phone: String = "", address: String = "") {
            self.name = name
            self.clinic = clinic
            self.phone = phone
            self.address = address
        }
    }

    struct Vaccine: Codable, Equatable {
        var name: String
        var last: String
        var next: String
    }

    struct Medication: Codable, Equatable {
        var name: String
        var dose: String
        var schedule: String
    }
}

// Subset of a cat's share link (server sends more fields, which decoding ignores).
struct SharedLink: Codable, Identifiable, Equatable {
    let id: String
    let token: String
    let label: String?
    let status: String?
}

// GET /api/me  and  POST /api/auth/{login,register}
struct MeResponse: Codable {
    let user: User
    let cats: [Cat]
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
}

// POST /api/auth/guest — anonymous sign-in (needs the X-App-Key header).
struct GuestRequest: Encodable {
    let name: String?
}

// POST /api/auth/claim — converts the current guest into a full account.
struct ClaimRequest: Encodable {
    let email: String
    let name: String
    let password: String
}
