//
//  CCCacheManager.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCCacheExpiry {
    case never
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)

    var timeInterval: TimeInterval {
        switch self {
        case .never: return .infinity
        case .seconds(let s): return s
        case .minutes(let m): return m * 60
        case .hours(let h): return h * 3600
        case .days(let d): return d * 86400
        }
    }
}

struct CCCacheEntry: Codable {
    let data: Data
    let expiryDate: Date
    let createdAt: Date

    var isExpired: Bool {
        Date() > expiryDate
    }

    init<T: Codable>(value: T, expiry: CCCacheExpiry) throws {
        self.data = try JSONEncoder().encode(value)
        self.expiryDate = Date().addingTimeInterval(expiry.timeInterval)
        self.createdAt = Date()
    }

    func decode<T: Codable>() throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}

protocol CCCacheManagerProtocol {
    func object<T: Codable>(for key: String) async throws -> T?
    func set<T: Codable>(_ object: T, for key: String, expiry: CCCacheExpiry) async throws
    func remove(for key: String) async
    func clear() async
    func clearExpired() async
}

final class CCCacheManager: CCCacheManagerProtocol {
    private let memoryCache = NSCache<NSString, CCCacheEntryObject>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let queue = DispatchQueue(label: "com.chillcat.cache", qos: .utility)

    init(cacheName: String = "default") {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("com.chillcat.cache.\(cacheName)", isDirectory: true)

        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 50 * 1024 * 1024

        Task { await clearExpired() }
    }

    func object<T: Codable>(for key: String) async throws -> T? {
        let sanitizedKey = sanitize(key)

        if let entry = memoryCache.object(forKey: sanitizedKey as NSString) {
            if entry.entry.isExpired {
                memoryCache.removeObject(forKey: sanitizedKey as NSString)
            } else {
                return try entry.entry.decode()
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let fileURL = self.cacheDirectory.appendingPathComponent(sanitizedKey)
                guard self.fileManager.fileExists(atPath: fileURL.path) else {
                    continuation.resume(returning: nil)
                    return
                }

                do {
                    let data = try Data(contentsOf: fileURL)
                    let entry = try self.decoder.decode(CCCacheEntry.self, from: data)

                    if entry.isExpired {
                        try? self.fileManager.removeItem(at: fileURL)
                        continuation.resume(returning: nil)
                        return
                    }

                    self.memoryCache.setObject(CCCacheEntryObject(entry: entry), forKey: sanitizedKey as NSString)
                    let result: T = try entry.decode()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func set<T: Codable>(_ object: T, for key: String, expiry: CCCacheExpiry) async throws {
        let sanitizedKey = sanitize(key)
        let entry = try CCCacheEntry(value: object, expiry: expiry)

        memoryCache.setObject(CCCacheEntryObject(entry: entry), forKey: sanitizedKey as NSString)

        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let fileURL = self.cacheDirectory.appendingPathComponent(sanitizedKey)
                    let data = try self.encoder.encode(entry)
                    try data.write(to: fileURL, options: .atomic)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func remove(for key: String) async {
        let sanitizedKey = sanitize(key)
        memoryCache.removeObject(forKey: sanitizedKey as NSString)

        await withCheckedContinuation { continuation in
            queue.async {
                let fileURL = self.cacheDirectory.appendingPathComponent(sanitizedKey)
                try? self.fileManager.removeItem(at: fileURL)
                continuation.resume()
            }
        }
    }

    func clear() async {
        memoryCache.removeAllObjects()

        await withCheckedContinuation { continuation in
            queue.async {
                try? self.fileManager.removeItem(at: self.cacheDirectory)
                try? self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
                continuation.resume()
            }
        }
    }

    func clearExpired() async {
        await withCheckedContinuation { continuation in
            queue.async {
                guard let enumerator = self.fileManager.enumerator(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: [.contentModificationDateKey]
                ) else {
                    continuation.resume()
                    return
                }

                for case let fileURL as URL in enumerator {
                    guard let data = try? Data(contentsOf: fileURL),
                          let entry = try? self.decoder.decode(CCCacheEntry.self, from: data),
                          entry.isExpired else { continue }
                    try? self.fileManager.removeItem(at: fileURL)
                }
                continuation.resume()
            }
        }
    }

    private func sanitize(_ key: String) -> String {
        key.data(using: .utf8)?
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "") ?? key
    }
}

private final class CCCacheEntryObject {
    let entry: CCCacheEntry
    init(entry: CCCacheEntry) {
        self.entry = entry
    }
}
