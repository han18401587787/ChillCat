//
//  CCTraceManager.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCTraceContext: Sendable, Codable {
    let traceID: String
    let spanID: String
    let parentSpanID: String?
    let operationName: String
    let startTime: Date
    var tags: [String: String]

    init(
        traceID: String = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased(),
        spanID: String = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(16)),
        parentSpanID: String? = nil,
        operationName: String,
        startTime: Date = Date(),
        tags: [String: String] = [:]
    ) {
        self.traceID = traceID
        self.spanID = spanID
        self.parentSpanID = parentSpanID
        self.operationName = operationName
        self.startTime = startTime
        self.tags = tags
    }

    func makeChild(operationName: String) -> CCTraceContext {
        CCTraceContext(
            traceID: traceID,
            parentSpanID: spanID,
            operationName: operationName,
            tags: tags
        )
    }
}

@MainActor
@Observable
final class CCTraceManager {
    static let shared = CCTraceManager()

    private var traceStack: [CCTraceContext] = []
    private var completedSpans: [CCTraceContext] = []
    private let maxSpans = 1000

    private init() {}

    @discardableResult
    func startTrace(operationName: String) -> CCTraceContext {
        let trace = CCTraceContext(operationName: operationName)
        traceStack = [trace]
        return trace
    }

    @discardableResult
    func startSpan(operationName: String) -> CCTraceContext {
        guard let parent = traceStack.last else {
            return startTrace(operationName: operationName)
        }
        let child = parent.makeChild(operationName: operationName)
        traceStack.append(child)
        return child
    }

    func endSpan() {
        guard !traceStack.isEmpty else { return }
        let completed = traceStack.removeLast()
        completedSpans.append(completed)
        if completedSpans.count > maxSpans {
            completedSpans.removeFirst(completedSpans.count - maxSpans)
        }
    }

    var currentTraceID: String? { traceStack.last?.traceID }
    var currentSpan: CCTraceContext? { traceStack.last }

    func exportSpans() -> [CCTraceContext] {
        let spans = completedSpans
        completedSpans.removeAll()
        return spans
    }
}
