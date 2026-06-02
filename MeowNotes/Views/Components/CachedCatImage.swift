//
//  CachedCatImage.swift
//  MeowNotes
//
//  Drop-in replacement for AsyncImage for cat photos. AsyncImage re-fetches the
//  remote URL (or re-decodes the base64 data URL) on every launch, so the hero
//  image flashes the placeholder each time. This caches the decoded image to
//  disk keyed by a hash of the source, and checks that cache synchronously in
//  init — so an already-seen photo paints immediately on the next launch.
//

import SwiftUI
import UIKit
import CryptoKit

// Two-tier cache (in-memory NSCache + Caches/ on disk), keyed by a stable hash
// of the photo source (works for both https URLs and base64 data: URLs).
enum CatImageCache {
    // NSCache is documented thread-safe, so the unchecked static is sound.
    nonisolated(unsafe) private static let memory = NSCache<NSString, UIImage>()

    private static var directory: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("CatImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func key(for source: String) -> String {
        SHA256.hash(data: Data(source.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    // Synchronous lookup: memory first, then disk (promoted into memory).
    static func cached(_ source: String) -> UIImage? {
        let k = key(for: source)
        if let img = memory.object(forKey: k as NSString) { return img }
        let url = directory.appendingPathComponent(k)
        guard let data = try? Data(contentsOf: url), let img = UIImage(data: data) else { return nil }
        memory.setObject(img, forKey: k as NSString)
        return img
    }

    private static func store(_ image: UIImage, for source: String) {
        let k = key(for: source)
        memory.setObject(image, forKey: k as NSString)
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: directory.appendingPathComponent(k))
        }
    }

    // Fetch (remote) or decode (data URL) off the cache, then persist it.
    static func fetchAndStore(_ source: String) async -> UIImage? {
        let image: UIImage?
        if source.hasPrefix("data:"), let comma = source.firstIndex(of: ",") {
            let b64 = String(source[source.index(after: comma)...])
            image = Data(base64Encoded: b64).flatMap(UIImage.init)
        } else if let url = URL(string: source) {
            image = (try? await URLSession.shared.data(from: url)).flatMap { UIImage(data: $0.0) }
        } else {
            image = nil
        }
        if let image { store(image, for: source) }
        return image
    }
}

struct CachedCatImage<Content: View, Placeholder: View>: View {
    private let source: String?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    @State private var uiImage: UIImage?

    init(_ source: String?,
         @ViewBuilder content: @escaping (Image) -> Content,
         @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.source = source
        self.content = content
        self.placeholder = placeholder
        // Instant first paint when the photo is already cached.
        if let source, !source.isEmpty {
            _uiImage = State(initialValue: CatImageCache.cached(source))
        }
    }

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: source) {
            guard let source, !source.isEmpty else { uiImage = nil; return }
            if let cached = CatImageCache.cached(source) { uiImage = cached; return }
            uiImage = nil   // switching cats: show the placeholder while fetching
            if let loaded = await CatImageCache.fetchAndStore(source) {
                uiImage = loaded
            }
        }
    }
}
