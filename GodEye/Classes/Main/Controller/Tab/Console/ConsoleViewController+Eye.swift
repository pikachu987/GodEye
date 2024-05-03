//
//  ConsoleViewController+Eye.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

extension ConsoleViewController {
    /// open god's eyes
    func openEyes() {
        EyesManager.shared.delegate = self
        guard let defaultSwitch = GodEyeTabBarController.shared.configuration?.defaultSwitch else { return }
        if defaultSwitch.asl { EyesManager.shared.openASLEye() }
        if defaultSwitch.log4g { EyesManager.shared.openLog4GEye() }
        if defaultSwitch.crash { EyesManager.shared.openCrashEye() }
        if defaultSwitch.network { EyesManager.shared.openNetworkEye() }
        if defaultSwitch.anr { EyesManager.shared.openANREye() }
        if defaultSwitch.leak { EyesManager.shared.openLeakEye() }
    }
    
    func addRecord(model:RecordORMProtocol) {
        if let pc = printViewController {
            pc.addRecord(model: model)
        } else {
            let type = Swift.type(of: model).type
            type.addUnread()
            reloadRow(of: type)
        }
    }
}

extension ConsoleViewController: Log4GDelegate {
    fileprivate func openLog4GEye() {
        Log4G.add(delegate: self)
    }
    
    func log4gDidRecord(with model: LogModel) {
        let recordModel = LogRecordModel(model: model)
        recordModel.insert(complete: { [weak self] _ in
            self?.addRecord(model: recordModel)
        })
    }
}

//MARK: - NetworkEye
extension ConsoleViewController: NetworkEyeDelegate {
    /// god's network eye callback
    func networkEyeDidCatch(with request: URLRequest?, response: URLResponse?, data: Data?) {
        Store.shared.addNetworkByte(response?.expectedContentLength ?? 0)
        let model = NetworkRecordModel(request: request, response: response as? HTTPURLResponse, data: data)
        model.insert(complete:  { [weak self] _ in
            self?.addRecord(model: model)
        })
    }
}
//MARK: - CrashEye
extension ConsoleViewController: CrashEyeDelegate {
    /// god's crash eye callback
    func crashEyeDidCatchCrash(with model: CrashModel) {
        let model = CrashRecordModel(model: model)
        model.insertSync(complete: { [weak self] _ in
            self?.addRecord(model: model)
        })
    }
}

//MARK: - ASLEye
extension ConsoleViewController: ASLEyeDelegate {
    /// god's asl eye callback
    func aslEye(aslEye: ASLEye, catchLogs logs: [String]) {
        logs.forEach {
            let model = LogRecordModel(type: .asl, message: $0)
            model.insert(complete: { [weak self] _ in
                self?.addRecord(model: model)
            })
        }
    }
}

extension ConsoleViewController: LeakEyeDelegate {
    func leakEye(leakEye: LeakEye, didCatchLeak object: NSObject) {
        let model = LeakRecordModel(obj: object)
        model.insert { [weak self] _ in
            self?.addRecord(model: model)
        }
    }
}

//MARK: - ANREye
extension ConsoleViewController: ANREyeDelegate {
    /// god's anr eye callback
    func anrEye(anrEye:ANREye,
                catchWithThreshold threshold: Double,
                mainThreadBacktrace: String?,
                allThreadBacktrace: String?) {
        let model = ANRRecordModel(threshold: threshold,
                                   mainThreadBacktrace: mainThreadBacktrace,
                                   allThreadBacktrace: allThreadBacktrace)
        model.insert(complete:  { [weak self] _ in
            self?.addRecord(model: model)
        })
    }
}
