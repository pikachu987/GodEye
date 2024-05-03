//
//  FPS.swift
//  Pods
//
//  Created by zixun on 16/12/26.
//
//

import Foundation

@objc public protocol FPSDelegate: class {
    @objc optional func fps(_ sender: FPS, fps: Double)
}

open class FPS: NSObject {
    
    open var isEnable: Bool = true
    
    open var updateInterval: Double = 1.0
    
    open weak var delegate: FPSDelegate?

    open var isOpen: Bool {
        !displayLink.isPaused
    }

    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActiveNotification),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    open func open() {
        guard isEnable else { return }
        displayLink.isPaused = false
    }
    
    open func close() {
        guard isEnable else { return }
        displayLink.isPaused = true
    }
    
    
    @objc private func applicationWillResignActiveNotification() {
        guard isEnable else { return }
        displayLink.isPaused = true
    }
    
    @objc private func applicationDidBecomeActiveNotification() {
        guard isEnable else { return }
        displayLink.isPaused = false
    }
    
    @objc private func displayLinkHandler() {
        count += displayLink.frameInterval
        let interval = displayLink.timestamp - lastTime
        
        guard interval >= updateInterval else { return }

        lastTime = displayLink.timestamp
        let fps = Double(count) / interval
        count = 0
       
        delegate?.fps?(self, fps: round(fps))

    }
    
    private lazy var displayLink: CADisplayLink = {
        $0.isPaused = true
        $0.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        return $0
    }(CADisplayLink(target: self, selector: #selector(displayLinkHandler)))

    private var count: Int = 0
    private var lastTime: CFTimeInterval = 0.0
}
