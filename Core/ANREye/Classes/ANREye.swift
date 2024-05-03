//
//  ANREye.swift
//  Pods
//
//  Created by zixun on 16/12/24.
//
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - ANREyeDelegate
//--------------------------------------------------------------------------
@objc public protocol ANREyeDelegate: AnyObject {
    @objc optional func anrEye(anrEye: ANREye,
                               catchWithThreshold threshold: Double,
                               mainThreadBacktrace: String?,
                               allThreadBacktrace: String?)
}

//--------------------------------------------------------------------------
// MARK: - ANREye
//--------------------------------------------------------------------------
open class ANREye: NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: OPEN PROPERTY
    //--------------------------------------------------------------------------
    open weak var delegate: ANREyeDelegate?
    
    open var isOpening: Bool {
        get {
            guard let pingThread = pingThread else { return false }
            return !pingThread.isCancelled
        }
    }
    //--------------------------------------------------------------------------
    // MARK: OPEN FUNCTION
    //--------------------------------------------------------------------------
    
    open func open(with threshold:Double) {
        if Thread.current.isMainThread {
            AppBacktrace.main_thread_id = mach_thread_self()
        } else {
            DispatchQueue.main.async {
                AppBacktrace.main_thread_id = mach_thread_self()
            }
        }
        
        pingThread = AppPingThread()
        pingThread?.start(threshold: threshold, handler: { [weak self] in
            guard let self = self else { return }

            let main = AppBacktrace.mainThread()
            let all = AppBacktrace.allThread()
            self.delegate?.anrEye?(anrEye: self,
                                   catchWithThreshold: threshold,
                                   mainThreadBacktrace: main,
                                   allThreadBacktrace: all)
            
        })
    }
    
    open func close() {
        pingThread?.cancel()
    }
    
    //--------------------------------------------------------------------------
    // MARK: LIFE CYCLE
    //--------------------------------------------------------------------------
    deinit {
        pingThread?.cancel()
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    private var pingThread: AppPingThread?
    
}

//--------------------------------------------------------------------------
// MARK: - GLOBAL DEFINE
//--------------------------------------------------------------------------
public typealias AppPingThreadCallBack = () -> Void

//--------------------------------------------------------------------------
// MARK: - AppPingThread
//--------------------------------------------------------------------------
private class AppPingThread: Thread {
    
    func start(threshold:Double, handler: @escaping AppPingThreadCallBack) {
        self.handler = handler
        self.threshold = threshold
        start()
    }
    
    override func main() {
        
        while !isCancelled {
            isMainThreadBlock = true
            DispatchQueue.main.async {
                self.isMainThreadBlock = false
                self.semaphore.signal()
            }
            
            Thread.sleep(forTimeInterval: threshold)
            if isMainThreadBlock  {
                handler?()
            }
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var isMainThreadBlock = false
    
    private var threshold: Double = 0.4
    
    fileprivate var handler: (() -> Void)?
}
