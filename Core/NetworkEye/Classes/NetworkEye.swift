//
//  NetworkEye.swift
//  Pods
//
//  Created by zixun on 16/12/26.
//
//

import Foundation

public protocol NetworkEyeDelegate: NSObjectProtocol {
    func networkEyeDidCatch(with request: URLRequest?, response: URLResponse?, data: Data?)
}

class WeakNetworkEyeDelegate: NSObject {
    weak var delegate: NetworkEyeDelegate?
    init(delegate: NetworkEyeDelegate) {
        self.delegate = delegate
        super.init()
    }
}


public class NetworkEye: NSObject {
    public static var isWatching: Bool  {
        get {
            !EyeProtocol.delegates.isEmpty
        }
    }
    
    public class func add(observer: NetworkEyeDelegate) {
        if EyeProtocol.delegates.isEmpty {
            EyeProtocol.open()
            URLSession.open()
        }
        EyeProtocol.add(delegate: observer)
    }
    
    public class func remove(observer: NetworkEyeDelegate) {
        EyeProtocol.remove(delegate: observer)
        if EyeProtocol.delegates.isEmpty {
            EyeProtocol.close()
            URLSession.close()
        }
    }
}
