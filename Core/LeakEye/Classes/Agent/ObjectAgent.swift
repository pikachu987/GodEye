//
//  ObjectAgent.swift
//  Pods
//
//  Created by zixun on 16/12/12.
//
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - ObjectAgent
// DESCRIPTION: the agent of object instance
//--------------------------------------------------------------------------
class ObjectAgent: NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: INTERNAL PROPERTY
    //--------------------------------------------------------------------------
    weak var object: NSObject?
    
    weak var host: NSObject?
    
    weak var responder: NSObject?
    
    //--------------------------------------------------------------------------
    // MARK: LIFE CYCLE
    //--------------------------------------------------------------------------
    init(object: NSObject) {
        super.init()
        self.object = object
        
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.scan,
                                                  object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleScan),
                                               name: NSNotification.Name.scan,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.scan,
                                                  object: nil)
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTION
    //--------------------------------------------------------------------------
    @objc private func handleScan() {
        if object == nil { return }
        if didNotified { return }

        let alive = object?.isAlive()
        if alive == false {
            leakCheckFailCount += 1
        }
        
        if leakCheckFailCount >= 5 {
            notifyPossibleLeak()
        }
    }
    
    private func notifyPossibleLeak() {
        if didNotified { return }

        didNotified = true
        NotificationCenter.default.post(name: NSNotification.Name.receive, object: object)
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    private var didNotified: Bool = false
    
    fileprivate var leakCheckFailCount: Int = 0
}
