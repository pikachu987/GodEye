//
//  LeakEye.swift
//  Pods
//
//  Created by zixun on 16/12/12.
//
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - LeakEyeDelegate
//--------------------------------------------------------------------------
@objc public protocol LeakEyeDelegate: NSObjectProtocol {
   @objc optional func leakEye(_ leakEye: LeakEye, didCatchLeak object: NSObject)
}

//--------------------------------------------------------------------------
// MARK: - LeakEye
//--------------------------------------------------------------------------
open class LeakEye: NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: OPEN PROPERTY
    //--------------------------------------------------------------------------
    open weak var delegate: LeakEyeDelegate?
    
    open var isOpening: Bool {
        get {
            timer?.isValid ?? false
        }
    }
    //--------------------------------------------------------------------------
    // MARK: LIFE CYCLE
    //--------------------------------------------------------------------------
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(receive), name: NSNotification.Name.receive, object: nil)
    }
    
    //--------------------------------------------------------------------------
    // MARK: OPEN FUNCTION
    //--------------------------------------------------------------------------
    open func open() {
        Preparer.binding()
        startPingTimer()
    }
    
    open func close() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startPingTimer() {
        if Thread.isMainThread == false {
            DispatchQueue.main.async {
                self.startPingTimer()
                return
            }
        }
        close()

        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(scan),
                                     userInfo: nil,
                                     repeats: true)

    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTION
    //--------------------------------------------------------------------------
    @objc private func scan()  {
        NotificationCenter.default.post(name: NSNotification.Name.scan, object: nil)
    }
    
    @objc private func receive(notif: NSNotification) {
        guard let leakObj = notif.object as? NSObject else {
            return
        }
        delegate?.leakEye?(self, didCatchLeak: leakObj)
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPEERTY
    //--------------------------------------------------------------------------
    private var timer: Timer?
}
