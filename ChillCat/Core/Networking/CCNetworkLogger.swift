//
//  CCNetworkLogger.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import OSLog

final class CCNetworkLogger {
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.chillcat",
                            category: "Network")

    func logRequest(_ request: URLRequest) {
        guard CCAppEnvironment.current.logLevel <= .debug else { return }

        var logMessage = """
        ╔══════════════════════════════════════════
        ║ 🌐 REQUEST
        """
        logMessage += "\n║ \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logMessage += "\n║ Headers: \(headers)"
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            logMessage += "\n║ Body: \(bodyString.prefix(500))"
        }

        logMessage += "\n╚══════════════════════════════════════════"
        os_log("%{public}@", log: log, type: .debug, logMessage)
    }

    func logResponse(_ response: URLResponse, data: Data) {
        guard CCAppEnvironment.current.logLevel <= .debug else { return }

        guard let httpResponse = response as? HTTPURLResponse else { return }

        var logMessage = """
        ╔══════════════════════════════════════════
        ║ 🌐 RESPONSE
        """
        logMessage += "\n║ Status: \(httpResponse.statusCode)"
        logMessage += "\n║ URL: \(httpResponse.url?.absoluteString ?? "")"

        if let bodyString = String(data: data, encoding: .utf8) {
            logMessage += "\n║ Body: \(bodyString.prefix(1000))"
        }

        logMessage += "\n╚══════════════════════════════════════════"
        os_log("%{public}@", log: log, type: .debug, logMessage)
    }

    func logError(_ error: Error, request: URLRequest) {
        os_log(
            "❌ Network Error: %{public}@ | URL: %{public}@",
            log: log,
            type: .error,
            error.localizedDescription,
            request.url?.absoluteString ?? ""
        )
    }
}
