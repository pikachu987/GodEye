//
//  EyesManager.swift
//  Pods
//
//  Created by zixun on 17/1/18.
//
//

import Foundation

final class EyesManager: NSObject {

    static let shared = EyesManager()
    
    weak var delegate: ConsoleViewController? {
        didSet {
            aslEye.delegate = delegate
            anrEye.delegate = delegate
            leakEye.delegate = delegate
        }
    }

    fileprivate lazy var aslEye = ASLEye()
    fileprivate lazy var anrEye = ANREye()
    fileprivate lazy var leakEye = LeakEye()
}

//--------------------------------------------------------------------------
// MARK: - ASL EYE
//--------------------------------------------------------------------------
extension EyesManager {
    
    func isASLEyeOpening() -> Bool {
        return aslEye.isOpening
    }
    
    /// open asl eye
    func openASLEye() {
        aslEye.delegate = delegate
        aslEye.open(with: 1)
    }
    
    /// close asl eys
    func closeASLEye() {
        aslEye.close()
    }
}

//--------------------------------------------------------------------------
// MARK: - LOG4G
//--------------------------------------------------------------------------
extension EyesManager {
    
    func isLog4GEyeOpening() -> Bool {
        Log4G.delegateCount > 0
    }
    
    func openLog4GEye() {
        guard let delegate = delegate else { return }
        Log4G.add(delegate: delegate)
    }
    
    func closeLog4GEye() {
        guard let delegate = delegate else { return }
        Log4G.remove(delegate: delegate)
    }
}

//--------------------------------------------------------------------------
// MARK: - CRASH
//--------------------------------------------------------------------------
extension EyesManager {
    
    func isCrashEyeOpening() -> Bool {
        return CrashEye.isOpen
    }
    
    func openCrashEye() {
        guard let delegate = delegate else { return }
        CrashEye.add(delegate: delegate)
    }
    
    func closeCrashEye() {
        guard let delegate = delegate else { return }
        CrashEye.remove(delegate: delegate)
    }
}

//--------------------------------------------------------------------------
// MARK: - NETWORK
//--------------------------------------------------------------------------
extension EyesManager {
    
    func isNetworkEyeOpening() -> Bool {
        return NetworkEye.isWatching
    }
    
    func openNetworkEye() {
        guard let delegate = delegate else { return }
        NetworkEye.add(observer: delegate)
    }
    
    func closeNetworkEye() {
        guard let delegate = delegate else { return }
        NetworkEye.remove(observer: delegate)
    }
}

//--------------------------------------------------------------------------
// MARK: - ANREye
//--------------------------------------------------------------------------
extension EyesManager {
    func isANREyeOpening() -> Bool {
        anrEye.isOpening
    }
    
    func openANREye() {
        anrEye.open(with: 2)
    }
    
    func closeANREye() {
        anrEye.close()
    }
}

extension EyesManager {
    
    func isLeakEyeOpening() -> Bool {
        leakEye.isOpening
    }
    
    func openLeakEye() {
        leakEye.open()
    }
    
    func closeLeakEye() {
        leakEye.close()
    }
}

//--------------------------------------------------------------------------
// MARK: - UIThreadEye
//--------------------------------------------------------------------------
extension EyesManager {
    
    func isUIThreadEyeOpening() -> Bool {
        UIThreadEye.isWatching
    }
    
    func openUIThreadEye() {
        UIThreadEye.open()
    }
    
    func closeUIThreadEye() {
        UIThreadEye.close()
    }
}
