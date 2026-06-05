import Foundation
import Security

// Web persists the JWT in localStorage; on iOS we keep it in the Keychain.
// Two items keyed by `service` + account: the active session token, and the
// last guest token (kept across logout so a guest can return to their data).
enum TokenStore {
    private static let service = "app.meownotes.auth"
    private static let account = "jwt"
    private static let guestAccount = "guest-jwt"

    static var token: String? {
        get { read(account) }
        set { write(newValue, account) }
    }

    // The last guest session's token. Survives logout so "Continue as guest"
    // resumes the same anonymous account (and its cats) instead of minting a
    // brand-new empty guest. Cleared when the guest claims an account or deletes.
    static var guestToken: String? {
        get { read(guestAccount) }
        set { write(newValue, guestAccount) }
    }

    private static func write(_ value: String?, _ account: String) {
        if let value, !value.isEmpty { save(value, account) } else { delete(account) }
    }

    private static func read(_ account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func save(_ value: String, _ account: String) {
        let data = Data(value.utf8)
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(base as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var insert = base
            insert[kSecValueData as String] = data
            SecItemAdd(insert as CFDictionary, nil)
        }
    }

    private static func delete(_ account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
