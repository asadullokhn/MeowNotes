import Foundation

// Matches serializeUser() on the server.
struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let name: String
    let avatar: String?
    let location: String?
}

// Subset of serializeCat() needed to hydrate the session. The server sends more
// fields; decoding ignores keys we don't model, so this stays robust as the cat
// schema grows.
struct Cat: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let breed: String?
    let age: Int?
    let photo: String?
    let personalitySummary: String?
    let sharedLinks: [SharedLink]?
    let medical: Medical?

    // First active share link, if any — used to build the sitter guide URL.
    var shareToken: String? {
        (sharedLinks?.first { $0.status == "active" } ?? sharedLinks?.first)?.token
    }
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
