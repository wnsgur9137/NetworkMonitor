//
//  NetworkMonitorWithRxSwift.swift
//  NetworkMonitor
//
//  Created by JunHyeok Lee on 12/16/24.
//

import Foundation
import Network
import RxSwift

/// with RxSwift
public final class NetworkMonitorWithRxSwift {
    
    public static let shared = NetworkMonitorWithRxSwift()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public let isConnected: PublishSubject<Bool> = .init()
    public let interfaceType: BehaviorSubject<NetworkInterface?> = .init(value: nil)
    
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
    
extension NetworkMonitorWithRxSwift {
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected.onNext(path.status == .satisfied)
            self?.interfaceType.onNext(self?.getUsesInterfaceType(path))
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}

