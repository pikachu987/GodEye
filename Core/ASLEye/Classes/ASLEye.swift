//
//  ASLEye.swift
//  Pods
//
//  Created by zixun on 16/12/25.
//
//

import Foundation
import Foundation
import asl

@objc public protocol ASLEyeDelegate: class {
    @objc optional func aslEye(_ aslEye:ASLEye,catchLogs logs:[String])
}

open class ASLEye: NSObject {
    
    open weak var delegate: ASLEyeDelegate?
    
    open var isOpening: Bool {
        get {
            timer?.isValid ?? false
        }
    }
    
    open func open(with interval: TimeInterval) {
        timer = Timer.scheduledTimer(timeInterval: interval,
                                          target: self,
                                          selector: #selector(pollingLogs),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    open func close() {
        timer?.invalidate()
        timer = nil
        
    }
    
    
    @objc fileprivate func pollingLogs() {
        queue.async {
            let logs = self.retrieveLogs()
            if logs.count > 0 {
                DispatchQueue.main.async {
                    self.delegate?.aslEye?(self, catchLogs: logs)
                }
            }
        }
    }
    
    fileprivate func retrieveLogs() -> [String] {
        var logs = [String]()
        
        guard let query: aslmsg = initQuery() else { return [] }

        let response: aslresponse? = asl_search(nil, query)
        guard response != nil else { return logs }

        var message = asl_next(response)
        while (message != nil) {
            if let messageDummy = message {
                let log = parserLog(from: messageDummy)
                logs.append(log)
            }
            
            message = asl_next(response)
        }
        asl_free(response)
        asl_free(query)
        
        return logs
    }
    
    fileprivate func parserLog(from message: aslmsg) -> String {
        guard let content = asl_get(message, ASL_KEY_MSG) else { return "" }
        let msg_id = asl_get(message, ASL_KEY_MSG_ID)
        
        let m = atoi(msg_id)
        if (m != 0) {
            lastMessageID = m
        }
        
        return String(cString: content, encoding: String.Encoding.utf8) ?? ""
    }
    
    fileprivate func initQuery() -> aslmsg? {
        let query: aslmsg = asl_new(UInt32(ASL_TYPE_QUERY))
        //set BundleIdentifier to ASL_KEY_FACILITY
        guard let identifier = Bundle.main.bundleIdentifier else { return nil }
        let bundleIdentifier = (identifier as NSString).utf8String
        asl_set_query(query, ASL_KEY_FACILITY, bundleIdentifier, UInt32(ASL_QUERY_OP_EQUAL))
        
        //set pid to ASL_KEY_PID
        let pid = NSString(format: "%d", getpid()).cString(using: String.Encoding.utf8.rawValue)
        asl_set_query(query, ASL_KEY_PID, pid, UInt32(ASL_QUERY_OP_NUMERIC))
        
        if lastMessageID != 0 {
            let m = NSString(format: "%d", self.lastMessageID).utf8String
            asl_set_query(query, ASL_KEY_MSG_ID, m, UInt32(ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC))
        }
        
        return query
    }
    
    fileprivate var timer: Timer?
    fileprivate var lastMessageID: Int32 = 0
    fileprivate var queue = DispatchQueue(label: "ASLEyeQueue")
}
