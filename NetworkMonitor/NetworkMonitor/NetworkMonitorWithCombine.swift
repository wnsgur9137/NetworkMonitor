//
//  NetworkMonitorWithCombine.swift
//  NetworkMonitor
//
//  Created by JunHyeok Lee on 12/16/24.
//

import Foundation
import Network
import Combine

/// with Combine
public final class NetworkMonitorWithCombine {
    
    public static let shared = NetworkMonitorWithCombine()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public let isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    public let interfaceType: CurrentValueSubject<NetworkInterface?, Never> = .init(nil)
    
    public enum NetworkInterface: String {
        case wifi
        case cellular
        case wiredEthernet
        case loopback
        case other
    }
    
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    private func getUsesInterfaceType(_ path: NWPath) -> NetworkInterface {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else if path.usesInterfaceType(.loopback) {
            return .loopback
        } else {
            return .other
        }
    }
    
}
    
extension NetworkMonitorWithCombine {
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected.value = path.status == .satisfied
            self?.interfaceType.value = self?.getUsesInterfaceType(path)
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}
