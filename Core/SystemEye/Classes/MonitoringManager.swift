//
//  CPU.swift
//  Pods
//
//  Created by zixun on 2016/12/5.
//
//

import Foundation

protocol MonitoringManagerDelegate where Self: Monitoring {
    func monitorManager(_ sender: MonitoringManager, appCPU: Double, unit: String)
    func monitorManager(_ sender: MonitoringManager, sysCPU: Double, unit: String)
    func monitorManager(_ sender: MonitoringManager, appRAM: Double, unit: String)
    func monitorManager(_ sender: MonitoringManager, sysRAM: Double, unit: String)
    func monitorManager(_ sender: MonitoringManager, appFPS: Double, unit: String)
    func monitorManager(_ sender: MonitoringManager, appNET: Double, unit: String)
}

extension MonitoringManagerDelegate where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs == rhs
    }
}

final class MonitoringManager {
    private var delegates = [MonitoringManagerDelegate]()
    private var timer: Timer?
    private lazy var fpsModel = FPS()

    static let shared = MonitoringManager()

    var appCPU: Double = 0 {
        didSet { sendAppCPU() }
    }

    var sysCPU: Double = 0 {
        didSet { sendSysCPU() }
    }

    var appRAM: Double = 0 {
        didSet { sendAppRAM() }
    }

    var sysRAM: Double = 0 {
        didSet { sendSysRAM() }
    }

    var appFPS: Double = 0 {
        didSet { sendAppFPS() }
    }

    var appNET: Double = 0 {
        didSet { sendAppNET() }
    }

    private init() {
        bind()
    }
}

extension MonitoringManager {
    func append(_ delegate: MonitoringManagerDelegate) {
        delegates.append(delegate)
        if !fpsModel.isOpen {
            fpsModel.open()
        }
        if timer == nil {
            timerHandler()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler(_:)), userInfo: nil, repeats: true)
        }
        sendAppNET()
    }

    func remove(_ delegate: MonitoringManagerDelegate) {
        guard let index = delegates.firstIndex(where: { $0 == delegate }) else { return }
        delegates.remove(at: index)
        if delegates.isEmpty {
            fpsModel.close()
            timer?.invalidate()
            timer = nil
        }
    }
}

extension MonitoringManager {
    private func bind() {
        fpsModel.delegate = self

        Store.shared.networkByteDidChange { [weak self] in
            self?.appNET = $0
        }
    }
}

extension MonitoringManager {
    @objc private func timerHandler(_ sender: Timer? = nil) {
        appCPU = System.cpu.applicationUsage()

        let cpuSystemUsage = System.cpu.systemUsage()
        sysCPU = cpuSystemUsage.system + cpuSystemUsage.user + cpuSystemUsage.nice

        appRAM = System.memory.applicationUsage().used

        let ramSysUsage = System.memory.systemUsage()
        let percent = (ramSysUsage.active + ramSysUsage.inactive + ramSysUsage.wired) / ramSysUsage.total
        sysRAM = percent * 100.0
    }
}

extension MonitoringManager {
    private func sendAppCPU() {
        delegates.forEach { $0.monitorManager(self, appCPU: appCPU, unit: "%") }
    }

    private func sendSysCPU() {
        delegates.forEach { $0.monitorManager(self, sysCPU: sysCPU, unit: "%") }
    }

    private func sendAppRAM() {
        let storageCapacity = appRAM.storageCapacity()
        delegates.forEach { $0.monitorManager(self, appRAM: storageCapacity.capacity, unit: storageCapacity.unit) }
    }

    private func sendSysRAM() {
        delegates.forEach { $0.monitorManager(self, sysRAM: sysRAM, unit: "%") }
    }

    private func sendAppFPS() {
        delegates.forEach { $0.monitorManager(self, appFPS: appFPS, unit: "FPS") }
    }

    private func sendAppNET() {
        let storageCapacity = appNET.storageCapacity()
        delegates.forEach { $0.monitorManager(self, appNET: storageCapacity.capacity, unit: storageCapacity.unit) }
    }
}

extension MonitoringManager: FPSDelegate {
    func fps(_ sender: FPS, fps: Double) {
        appFPS = fps
    }
}
