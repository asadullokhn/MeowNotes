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
// fields (personality, medical, etc.); decoding ignores keys we don't model, so
// this stays robust as the cat schema grows.
struct Cat: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let breed: String?
    let age: Int?
    let photo: String?
    let personalitySummary: String?
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
