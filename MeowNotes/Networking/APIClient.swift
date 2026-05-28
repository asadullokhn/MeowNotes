import Foundation

// Mirrors src/lib/api.js — a thin fetch wrapper that attaches the JWT and
// surfaces the server's `{ error }` message.
enum API {
    static let baseURL = URL(string: "https://meownotes.teztun.uz")!

    static func get<Response: Decodable>(_ path: String) async throws -> Response {
        try await request("GET", path, body: Optional<Empty>.none)
    }

    static func post<Body: Encodable, Response: Decodable>(_ path: String, _ body: Body) async throws -> Response {
        try await request("POST", path, body: body)
    }

    private static func request<Body: Encodable, Response: Decodable>(
        _ method: String, _ path: String, body: Body?
    ) async throws -> Response {
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = TokenStore.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw APIError(status: 0, message: "Can't reach the server. Check your connection.")
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError(status: 0, message: "Unexpected server response.")
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? JSONDecoder().decode(ErrorBody.self, from: data))?.error
                ?? "request failed (\(http.statusCode))"
            throw APIError(status: http.statusCode, message: message)
        }

        if Response.self == Empty.self { return Empty() as! Response }
        return try JSONDecoder().decode(Response.self, from: data)
    }

    private struct ErrorBody: Decodable { let error: String }
}

struct APIError: LocalizedError {
    let status: Int
    let message: String
    var errorDescription: String? { message }
    var isUnauthorized: Bool { status == 401 }
}

// Placeholder Encodable/Decodable for request-less or response-less calls.
struct Empty: Codable {}
