//
//  CCLogger.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import OSLog

@MainActor
protocol CCLoggerProtocol {
    func debug(_ message: String, module: CCLogModule, category: String,
               file: String, function: String, line: Int)
    func info(_ message: String, module: CCLogModule, category: String,
              file: String, function: String, line: Int)
    func warning(_ message: String, module: CCLogModule, category: String,
                 file: String, function: String, line: Int)
    func error(_ message: String, module: CCLogModule, category: String,
               file: String, function: String, line: Int, error: Error?)
}

extension CCLoggerProtocol {
    func debug(_ message: String, module: CCLogModule = .default,
               category: String = "General", file: String = #file,
               function: String = #function, line: Int = #line) {
        self.debug(message, module: module, category: category, file: file, function: function, line: line)
    }
    func info(_ message: String, module: CCLogModule = .default,
              category: String = "General", file: String = #file,
              function: String = #function, line: Int = #line) {
        self.info(message, module: module, category: category, file: file, function: function, line: line)
    }
    func warning(_ message: String, module: CCLogModule = .default,
                 category: String = "General", file: String = #file,
                 function: String = #function, line: Int = #line) {
        self.warning(message, module: module, category: category, file: file, function: function, line: line)
    }
    func error(_ message: String, module: CCLogModule = .default,
               category: String = "General", file: String = #file,
               function: String = #function, line: Int = #line, error: Error? = nil) {
        self.error(message, module: module, category: category, file: file, function: function, line: line, error: error)
    }
}

final class CCLogger: CCLoggerProtocol {
    static let shared = CCLogger()

    private let osLog: OSLog
    private let queue: DispatchQueue
    private let traceManager: CCTraceManager
    private var moduleLevelOverrides: [CCLogModule: CCLogLevel] = [:]

    init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.chillcat",
         traceManager: CCTraceManager = .shared) {
        self.osLog = OSLog(subsystem: subsystem, category: "App")
        self.queue = DispatchQueue(label: "com.chillcat.logger", qos: .utility)
        self.traceManager = traceManager
    }

    func setLevel(_ level: CCLogLevel, for module: CCLogModule) {
        queue.sync { moduleLevelOverrides[module] = level }
    }

    @MainActor
    func debug(_ message: String, module: CCLogModule = .default, category: String = "General",
               file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, module: module, category: category,
            file: file, function: function, line: line, error: nil)
    }

    @MainActor
    func info(_ message: String, module: CCLogModule = .default, category: String = "General",
              file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, module: module, category: category,
            file: file, function: function, line: line, error: nil)
    }

    @MainActor
    func warning(_ message: String, module: CCLogModule = .default, category: String = "General",
                 file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, module: module, category: category,
            file: file, function: function, line: line, error: nil)
    }

    @MainActor
    func error(_ message: String, module: CCLogModule = .default, category: String = "General",
               file: String = #file, function: String = #function, line: Int = #line, error: Error? = nil) {
        log(level: .error, message: message, module: module, category: category,
            file: file, function: function, line: line, error: error)
    }

    @MainActor
    private func log(level: CCLogLevel, message: String, module: CCLogModule, category: String,
                     file: String, function: String, line: Int, error: Error?) {
        let minLevel = moduleLevelOverrides[module] ?? CCAppEnvironment.current.logLevel
        guard level >= minLevel else { return }

        let fileName = (file as NSString).lastPathComponent
        let traceID = traceManager.currentTraceID
        let spanID = traceManager.currentSpan?.spanID

        var errorInfo: CCLogEntry.CCLogErrorInfo? = nil
        if let err = error {
            let appError = err.asCCAppError
            errorInfo = CCLogEntry.CCLogErrorInfo(
                domain: "App",
                code: appError.code,
                description: appError.errorDescription ?? err.localizedDescription,
                stackTrace: nil
            )
        }

        let entry = CCLogEntry(
            timestamp: Date(), level: level.label, module: module.rawValue,
            category: category, message: message, traceID: traceID, spanID: spanID,
            file: fileName, function: function, line: line,
            tags: traceManager.currentSpan?.tags, metadata: nil, error: errorInfo
        )

        os_log("%{public}@", log: osLog, type: level.osLogType, entry.toReadableString())

        // 桥接到诊断收集器（仅 WARNING 和 ERROR 级别）
        #if DEBUG
        if level >= .warning {
            CCDiagnosticCollector.shared.record(from: entry)
        }
        #endif
    }
}

// MARK: - Global Log Functions

@MainActor
func LogD(_ message: @autoclosure () -> String, module: CCLogModule = .default,
          category: String = "General", file: String = #file,
          function: String = #function, line: Int = #line) {
    CCLogger.shared.debug(message(), module: module, category: category,
                           file: file, function: function, line: line)
}

@MainActor
func LogI(_ message: @autoclosure () -> String, module: CCLogModule = .default,
          category: String = "General", file: String = #file,
          function: String = #function, line: Int = #line) {
    CCLogger.shared.info(message(), module: module, category: category,
                          file: file, function: function, line: line)
}

@MainActor
func LogW(_ message: @autoclosure () -> String, module: CCLogModule = .default,
          category: String = "General", file: String = #file,
          function: String = #function, line: Int = #line) {
    CCLogger.shared.warning(message(), module: module, category: category,
                            file: file, function: function, line: line)
}

@MainActor
func LogE(_ message: @autoclosure () -> String, module: CCLogModule = .default,
          category: String = "General", file: String = #file,
          function: String = #function, line: Int = #line, error: Error? = nil) {
    CCLogger.shared.error(message(), module: module, category: category,
                          file: file, function: function, line: line, error: error)
}
