<h1>NetworkMonitor</h1>

네트워크 상황 감지 코드

* Combine
* RxSwift

<br>
<br>
<br>

<h1>How to use</h1>

<h2>AppDelegate.swift</h2>

``` swift
// AppDelegate.swift

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// Combine, RxSwift 모두 사용하지 않는 경우
        NetworkMonitor.shared.startMonitoring()

        /// Combine
        NetworkMonitorWithCombine.shared.startMonitoring()

        /// RxSwift
        NetworkMonitorWithRxSwift.shared.startMonitoring()
        return true
    }

    ...
}
```

<h2>ViewController</h2>

``` swift
import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let isConnected = NetworkMonitor.shared.isConnected
        let type = networkMonitor.shared.interfaceType
        print("isConnected: \(isConnected)") // true or false
        print("type: \(type)") // wifi, cellular, wiredEthernet, loopback, other
    }

}
```

<h2>ViewController with Combine</h2>

``` swift
import UIKit
import Combine

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkMonitorWithCombine.shared.isConnected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                print("isConnected: \(isConnected)")
            }
            .store(in: &cancellables)

        NetworkMonitorWithCombine.shared.interfaceType
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                print("type: \(type)")
            }
            .store(in: &cancellables)
    }

}
```

<br>
<br>
<br>

<h1>NetworkMonitor Code</h1>

``` swift
// NetworkMonitor.swift

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
```

<h2>NetworkMonitor with Combine</h2>

``` swift
// NetworkMonitorWithCombine.swift

import Foundation
import Network
import Combine

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
```

<h2>NetworkMonitor with RxSwift</h2>

``` swift
// NetworkMonitorWithRxSwift.swift

import Foundation
import Network
import RxSwift

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
```