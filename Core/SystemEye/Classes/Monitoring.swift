//
//  CPU.swift
//  Pods
//
//  Created by zixun on 2016/12/5.
//
//

import Foundation

open class Monitoring {
    private let identifier: String = {
        "\(Date().timeIntervalSince1970)_\(UUID().uuidString)"
    }()

    public typealias DataValue = (value: Double, unit: String)

    open var appCPU: ((DataValue) -> Void)?
    open var sysCPU: ((DataValue) -> Void)?
    open var appRAM: ((DataValue) -> Void)?
    open var sysRAM: ((DataValue) -> Void)?
    open var appFPS: ((DataValue) -> Void)?
    open var appNET: ((DataValue) -> Void)?

    public init() {}

    open func start() {
        MonitoringManager.shared.append(self)
    }

    open func stop() {
        MonitoringManager.shared.remove(self)
    }
}

extension Monitoring: Equatable {
    public static func == (lhs: Monitoring, rhs: Monitoring) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension Monitoring: MonitoringManagerDelegate {
    func monitorManager(_ sender: MonitoringManager, appCPU: Double, unit: String) {
        self.appCPU?((appCPU, unit))
    }

    func monitorManager(_ sender: MonitoringManager, sysCPU: Double, unit: String) {
        self.sysCPU?((sysCPU, unit))
    }

    func monitorManager(_ sender: MonitoringManager, appRAM: Double, unit: String) {
        self.appRAM?((appRAM, unit))
    }

    func monitorManager(_ sender: MonitoringManager, sysRAM: Double, unit: String) {
        self.sysRAM?((sysRAM, unit))
    }

    func monitorManager(_ sender: MonitoringManager, appFPS: Double, unit: String) {
        self.appFPS?((appFPS, unit))
    }

    func monitorManager(_ sender: MonitoringManager, appNET: Double, unit: String) {
        self.appNET?((appNET, unit))
    }
}
