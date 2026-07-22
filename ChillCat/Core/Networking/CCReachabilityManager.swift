//
//  CCReachabilityManager.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import Network
import Combine

@MainActor
@Observable
final class CCReachabilityManager {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.chillcat.reachability")

    var isConnected = true
    var connectionType: CCConnectionType = .unknown

    enum CCConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    static let shared = CCReachabilityManager()

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { @Sendable [weak self] path in
            let isConnected = path.status == .satisfied
            let connectionType: CCConnectionType = {
                if path.usesInterfaceType(.wifi) { return .wifi }
                if path.usesInterfaceType(.cellular) { return .cellular }
                if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
                return .unknown
            }()

            Task { @MainActor [weak self] in
                self?.isConnected = isConnected
                self?.connectionType = connectionType
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
