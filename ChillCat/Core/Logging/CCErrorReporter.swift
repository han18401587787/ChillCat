//
//  CCErrorReporter.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCErrorReporterProtocol {
    func report(_ error: CCAppError, context: [String: Any]?)
    func report(_ error: Error, context: [String: Any]?)
    func reportMessage(_ message: String, level: CCLogLevel, context: [String: Any]?)
}

final class CCErrorReporter: CCErrorReporterProtocol {
    static let shared = CCErrorReporter()

    private var reporters: [CCErrorReporterProtocol] = []
    private var isEnabled: Bool = true
    private var sampleRate: Double = 1.0

    private init() {}

    func addReporter(_ reporter: CCErrorReporterProtocol) { reporters.append(reporter) }
    func setSampleRate(_ rate: Double) { sampleRate = max(0.0, min(1.0, rate)) }
    func setEnabled(_ enabled: Bool) { isEnabled = enabled }

    func report(_ error: CCAppError, context: [String: Any]? = nil) {
        guard isEnabled, shouldSample() else { return }
        var enrichedContext = context ?? [:]
        enrichedContext["errorCode"] = error.code
        enrichedContext["isRetryable"] = error.isRetryable
        reporters.forEach { $0.report(error, context: enrichedContext) }

        #if DEBUG
        CCDiagnosticCollector.shared.record(
            level: .error,
            message: error.errorDescription ?? "\(error)",
            module: "ErrorReporter",
            category: "Reported",
            errorDescription: error.errorDescription,
            traceID: nil
        )
        #endif
    }

    func report(_ error: Error, context: [String: Any]? = nil) {
        report(error.asCCAppError, context: context)
    }

    func reportMessage(_ message: String, level: CCLogLevel, context: [String: Any]? = nil) {
        guard isEnabled, shouldSample() else { return }
        CCLogger.shared.info(message, module: .default, category: "ErrorReporter")
    }

    private func shouldSample() -> Bool {
        guard sampleRate < 1.0 else { return true }
        return Double.random(in: 0...1) < sampleRate
    }
}
