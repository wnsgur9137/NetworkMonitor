//
//  ViewController.swift
//  NetworkMonitor
//
//  Created by JunHyeok Lee on 12/16/24.
//

import UIKit
import Combine
import RxSwift

final class ViewController: UIViewController {
    
    private let networkInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8.0
        return stackView
    }()
    
    private let networkConnectionStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ConnectionStatus"
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let networkInterfaceTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "InterfaceType"
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let isConnected = NetworkMonitor.shared.isConnected
        networkConnectionStatusLabel.text = isConnected ? "Is connected" : "Is not connected"
        let type = NetworkMonitor.shared.interfaceType
        networkInterfaceTypeLabel.text = "\(String(describing: type))"
        
        subscribeNetworkMonitorWithCombine()
        subscribeNetworkMonitorWithRxSwift()
        
        addSubviews()
        setupLayoutConstraints()
    }
    
    private func subscribeNetworkMonitorWithCombine() {
        NetworkMonitorWithCombine.shared.isConnected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.networkConnectionStatusLabel.text = isConnected ? "Is connected" : "Is not connected"
            }
            .store(in: &cancellables)
        
        NetworkMonitorWithCombine.shared.interfaceType
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                self?.networkInterfaceTypeLabel.text = "\(type)"
            }
            .store(in: &cancellables)
    }
    
    private func subscribeNetworkMonitorWithRxSwift() {
        NetworkMonitorWithRxSwift.shared.isConnected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isConnected in
                self?.networkConnectionStatusLabel.text = isConnected ? "Is connected" : "Is not connected"
            })
            .disposed(by: disposeBag)
        
        NetworkMonitorWithRxSwift.shared.interfaceType
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] type in
                self?.networkInterfaceTypeLabel.text = "\(type)"
            })
            .disposed(by: disposeBag)
    }
    
}

extension ViewController {
    private func addSubviews() {
        view.addSubview(networkInfoStackView)
        networkInfoStackView.addArrangedSubview(networkConnectionStatusLabel)
        networkInfoStackView.addArrangedSubview(networkInterfaceTypeLabel)
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            networkInfoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            networkInfoStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
