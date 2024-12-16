//
//  NetworkMonitor.swift
//  NetworkMonitor
//
//  Created by JunHyeok Lee on 12/16/24.
//

import Foundation
import Network

public final class NetworkMonitor {
    
    public static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    public private(set) var interfaceType: NetworkInterface?
    
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
    
extension NetworkMonitor {
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.interfaceType = self?.getUsesInterfaceType(path)
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}
