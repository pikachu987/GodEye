//
//  MonitorContainerView.swift
//  Pods
//
//  Created by zixun on 17/1/6.
//
//

import UIKit

final class MonitorContainerView: UIScrollView {
    private lazy var deviceView: MonitorDeviceView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MonitorDeviceView())

    private lazy var sysNetView: MonitorSysNetFlowView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MonitorSysNetFlowView(type: .sysNET))

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            makeLineHStackView(lineCount: 1),
            makeHStackView(subviews: [appCPUView, appRAMView]),
            makeLineHStackView(lineCount: 2),
            makeHStackView(subviews: [appFPSView, appNetView]),
            makeLineHStackView(lineCount: 1),
            makeHStackView(subviews: [sysCPUView, sysRAMView]),
            makeLineHStackView(lineCount: 1),
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var appCPUView = MonitorBaseView(type: .appCPU)
    private lazy var appRAMView = MonitorBaseView(type: .appRAM)
    private lazy var appFPSView = MonitorBaseView(type: .appFPS)
    private lazy var appNetView = MonitorBaseView(type: .appNET)
    private lazy var sysCPUView = MonitorBaseView(type: .sysCPU)
    private lazy var sysRAMView = MonitorBaseView(type: .sysRAM)

    private let monitoring = Monitoring()
    private let networkFlow = NetworkFlow()

    init() {
        super.init(frame: .zero)

        setupViews()
        bind()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonitorContainerView {
    func viewWillAppear() {
        monitoring.start()
    }

    func viewDidDisappear() {
        monitoring.stop()
    }
}

extension MonitorContainerView {
    private func setupViews() {
        addSubview(deviceView)
        addSubview(stackView)
        addSubview(sysNetView)

        NSLayoutConstraint.activate([
            appCPUView.heightAnchor.constraint(equalToConstant: 100),
            appRAMView.heightAnchor.constraint(equalToConstant: 100),
            appFPSView.heightAnchor.constraint(equalToConstant: 100),
            appNetView.heightAnchor.constraint(equalToConstant: 100),
            sysCPUView.heightAnchor.constraint(equalToConstant: 100),
            sysRAMView.heightAnchor.constraint(equalToConstant: 100),
        ])

        NSLayoutConstraint.activate([
            deviceView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            deviceView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            deviceView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: deviceView.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            sysNetView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            sysNetView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            sysNetView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            sysNetView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        networkFlow.delegate = self
    }

    private func bind() {
        deviceView.bind(nameString: System.hardware.deviceModel, osString: System.hardware.systemName + " " + System.hardware.systemVersion)
        networkFlow.open()

        monitoring.appCPU = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appCPUView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.sysCPU = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.sysCPUView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.appRAM = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appRAMView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.sysRAM = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.sysRAMView.bind(model.value, unit: model.unit)
            }
        }
        
        monitoring.appFPS = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appFPSView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.appNET = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appNetView.bind(model.value, unit: model.unit)
            }
        }
    }
}

extension MonitorContainerView {
    private func makeLineHStackView(lineCount: Int) -> UIStackView {
        var arrangedSubviews = [UIView]()
        let subviews = Array(0..<lineCount).map { _ in makeLineView(isVertical: false) }
        return makeHStackView(subviews: subviews, isAppendCenterLine: false)
    }

    private func makeHStackView(subviews: [UIView], isAppendCenterLine: Bool = true) -> UIStackView {
        var arrangedSubviews: [UIView] = []
        arrangedSubviews.append(makeSpaceView(isVertical: true))
        subviews.enumerated().forEach {
            arrangedSubviews.append($0.element)
            if $0.offset < subviews.count - 1 {
                arrangedSubviews.append(makeSpaceView(isVertical: true))
                if isAppendCenterLine {
                    arrangedSubviews.append(makeLineView(isVertical: true))
                }
                arrangedSubviews.append(makeSpaceView(isVertical: true))
            }
        }
        arrangedSubviews.append(makeSpaceView(isVertical: true))
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        subviews.enumerated()
            .filter { $0.offset != 0 }
            .forEach {
                $0.element.widthAnchor.constraint(equalTo: subviews[$0.offset - 1].widthAnchor, multiplier: 1).isActive = true
            }
        stackView.axis = .horizontal
        return stackView
    }

    private func makeLineView(isVertical: Bool) -> UIView {
        let lineConstainerView = UIView()
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .white
        lineConstainerView.addSubview(lineView)
        let sizeDimension: NSLayoutDimension = isVertical ? lineView.widthAnchor : lineView.heightAnchor
        NSLayoutConstraint.activate([
            sizeDimension.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: lineConstainerView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: lineConstainerView.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: lineConstainerView.topAnchor, constant: isVertical ? 16 : 0),
            lineView.bottomAnchor.constraint(equalTo: lineConstainerView.bottomAnchor, constant: isVertical ? -16 : 0),
        ])
        return lineConstainerView
    }

    private func makeSpaceView(isVertical: Bool) -> UIView {
        let view = UIView()
        (isVertical ? view.widthAnchor : view.heightAnchor).constraint(equalToConstant: 20).isActive = true
        return view
    }
}

extension MonitorContainerView: NetDelegate {
    func networkFlow(_ sender: NetworkFlow, catchWithWifiSend wifiSend: UInt64, wifiReceived: UInt64, wwanSend: UInt64, wwanReceived: UInt64) {
        DispatchQueue.main.async { [weak self] in
            self?.sysNetView.bind(wifiSend: wifiSend, wifiReceived: wifiReceived, wwanSend: wwanSend, wwanReceived: wwanReceived)
        }
    }
}
