//
//  Net.swift
//  Pods
//
//  Created by zixun on 16/12/26.
//
//

import Foundation

@objc public protocol NetDelegate: class {
    @objc optional func networkFlow(_ sender: NetworkFlow, catchWithWifiSend wifiSend: UInt32, wifiReceived: UInt32, wwanSend: UInt32, wwanReceived: UInt32)
}

open class NetworkFlow: NSObject {
    
    open weak var delegate: NetDelegate?
    
    private var eyeThread: Thread?
    private var timeInterval: TimeInterval?

    open var isOpen: Bool {
        eyeThread != nil
    }

    open func open(with timeInterval: TimeInterval = 1) {
        self.timeInterval = timeInterval
        close()
        eyeThread = Thread(target: self, selector: #selector(eyeThreadHandler), object: nil)
        eyeThread?.name = "SystemEye_Net"
        eyeThread?.start()
    }
    
    open func close() {
        eyeThread?.cancel()
        eyeThread = nil
    }
    
    @objc private func eyeThreadHandler() {
        while true {
            if Thread.current.isCancelled {
                Thread.exit()
            }
            execute()
            timeInterval.map {
                Thread.sleep(forTimeInterval: $0)
            }
        }
    }
    
    func execute() {
        let model = NetObjc.flow()
        if let first_model = first_model {
            model.wifiSend -= first_model.wifiSend
            model.wifiReceived -= first_model.wifiReceived
            model.wwanSend -= first_model.wwanSend
            model.wwanReceived -= first_model.wwanReceived
        } else {
            first_model = model
        }
        delegate?.networkFlow?(self,
                               catchWithWifiSend: model.wifiSend,
                               wifiReceived: model.wifiReceived,
                               wwanSend: model.wwanSend,
                               wwanReceived: model.wwanReceived)
    }
    
    private var first_model: NetModel?
}
