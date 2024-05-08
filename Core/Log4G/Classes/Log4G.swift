//
//  Log4G.swift
//  Pods
//
//  Created by zixun on 17/1/10.
//
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - Log4gDelegate
//--------------------------------------------------------------------------
@objc public protocol Log4GDelegate: NSObjectProtocol {
    func log4gDidRecord(with model: LogModel)
}

//--------------------------------------------------------------------------
// MARK: - Log4G
// DESCRIPTION: Simple, lightweight logging framework written in Swift
//              4G means for GodEye, it was development for GodEye at the beginning of the time
//--------------------------------------------------------------------------
open class Log4G: NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: OPEN FUNCTION
    //--------------------------------------------------------------------------
    
    /// record a log type message
    ///
    /// - Parameters:
    ///   - message: log message
    ///   - file: file which call the api
    ///   - line: line number at file which call the api
    ///   - function: function name which call the api
    open class func log(_ message: Any = "",
                        file: String = #file,
                        line: Int = #line,
                        function: String = #function) {
        shared.record(type: .log,
                      thread: Thread.current,
                      message: "\(message)",
                      file: file,
                      line: line,
                      function: function)
    }
    
    /// record a warning type message
    ///
    /// - Parameters:
    ///   - message: warning message
    ///   - file: file which call the api
    ///   - line: line number at file which call the api
    ///   - function: function name which call the api
    open class func warning(_ message: Any = "",
                            file: String = #file,
                            line: Int = #line,
                            function: String = #function) {
        shared.record(type: .warning,
                      thread: Thread.current,
                      message: "\(message)",
                      file: file,
                      line: line,
                      function: function)
    }
    
    /// record an error type message
    ///
    /// - Parameters:
    ///   - message: error message
    ///   - file: file which call the api
    ///   - line: line number at file which call the api
    ///   - function: function name which call the api
    open class func error(_ message: Any = "",
                          file: String = #file,
                          line: Int = #line,
                          function: String = #function) {
        shared.record(type: .error,
                      thread: Thread.current,
                      message: "\(message)",
                      file: file,
                      line: line,
                      function: function)
    }

    public static func network(with request: URLRequest?, response: URLResponse?, data: Data?) {
        Store.shared.addNetworkByte(response?.expectedContentLength ?? 0)
        let model = NetworkRecordModel(request: request, response: response as? HTTPURLResponse, data: data)
        model.insert(complete:  { _ in
            GodEyeTabBarController.shared.addRecord(model: model)
        })
    }

    //--------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTION
    //--------------------------------------------------------------------------
    
    /// record message base function
    ///
    /// - Parameters:
    ///   - type: log type
    ///   - thread: thread which log the messsage
    ///   - message: log message
    ///   - file: file which call the api
    ///   - line: line number at file which call the api
    ///   - function: function name which call the api
    private func record(type: Log4gType,
                     thread: Thread,
                     message: String,
                     file: String,
                     line: Int,
                     function: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let model = LogModel(type: type,
                                 thread: thread,
                                 message: message,
                                 file: self.name(of: file),
                                 line: line,
                                 function: function)
            for delegate in self.delegates.objectEnumerator()  {
                (delegate as? Log4GDelegate)?.log4gDidRecord(with: model)
            }
        }
    }
    
    /// get the name of file in filepath
    ///
    /// - Parameter file: path of file
    /// - Returns: filename
    private func name(of file: String) -> String {
        URL(fileURLWithPath: file).lastPathComponent
    }
    
    //MARK: - Private Variable
    
    /// singleton for Log4g
    fileprivate static let shared = Log4G()
    /// log queue
    private let queue = DispatchQueue(label: "Log4g")
    /// weak delegates
    fileprivate var delegates = NSHashTable<Log4GDelegate>(options: .weakMemory)
    
}

//--------------------------------------------------------------------------
// MARK: - Log4gDelegate Fucntion Extension
//--------------------------------------------------------------------------
extension Log4G {
    
    open class var delegateCount: Int {
        get {
            shared.delegates.count
        }
    }
    
    open class func add(delegate: Log4GDelegate) {
        let log4g = shared
        log4g.delegates.add(delegate)
    }
    
    open class func remove(delegate: Log4GDelegate) {
        let log4g = shared
        log4g.delegates.remove(delegate)
    }
}


