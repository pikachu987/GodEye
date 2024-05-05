//
//  DemoModel.swift
//  GodEye
//
//  Created by zixun on 17/1/10.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import GodEye

class DemoModel: NSObject {
    
    private(set) var title: String!
    
    private(set) var action: (()->())!
    
    init(title:String,action:@escaping ()->()) {
        super.init()
        self.title = title
        self.action = action
    }
}

class DemoSection: NSObject {
    private(set) var header: String!
    private(set) var model:[DemoModel]!
    
    init(header:String,model:[DemoModel]) {
        super.init()
        self.header = header
        self.model = model
    }
}

class DemoModelFactory: NSObject {
    
    static var crashSection: DemoSection {
        var models = [DemoModel]()
        var model = DemoModel(title: "Exception Crash") {
            let array = NSArray()
            _ = array[2]
        }
        models.append(model)
        
        model = DemoModel(title: "Signal Crash") {
            let testValue = [String]()
            _ = testValue[2]
        }
        models.append(model)
        
        return DemoSection(header: "Crash", model: models)
    }
    
    static var networkSection: DemoSection {
        let url = URL(string: "https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc")
        let request = URLRequest(url: url!)
        
        var new = [DemoModel]()
        
        var title = "Send Sync Connection Network"
        var model = DemoModel(title: title) {
            let semaphore = DispatchSemaphore(value: 0)
            URLSession.shared.dataTask(with: request) { (httpData, response, error) in
                semaphore.signal()
            }.resume()
            semaphore.wait()
            DispatchQueue.main.async {
                AppDelegate.showAlert(t: "Completed", m: title)
            }
        }
        new.append(model)
        
        title = "Send Async Connection Network"
        model = DemoModel(title: title) {
            URLSession.shared.dataTask(with: request, completionHandler: { _, _, _ in
                DispatchQueue.main.async {
                    AppDelegate.showAlert(t: "Completed", m: title)
                }
            }).resume()
        }
        new.append(model)
        
        title = "Send Shared Session Network"
        model = DemoModel(title: title) {
            let session = URLSession.shared
            URLSession.shared.dataTask(with: request)
            let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
                AppDelegate.showAlert(t: "Completed", m: title)
            }
            task.resume()
        }
        new.append(model)
        
        title = "Send Configuration Session Network"
        model = DemoModel(title: title) {
            let configure = URLSessionConfiguration.default
            let session = URLSession(configuration: configure,
                                     delegate: nil,
                                     delegateQueue: OperationQueue.current)
            let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
                AppDelegate.showAlert(t: "Completed", m: title)
            }
            task.resume()
        }
        new.append(model)
        
        return DemoSection(header: "Network", model: new)
    }
    
    static var aslSection: DemoSection {
        var models = [DemoModel]()
        let model = DemoModel(title: "NSLog") {
            NSLog("test")
        }
        models.append(model)

        let model2 = DemoModel(title: "NSLog multiple") {
            let alertController = UIAlertController(title: nil, message: "log prefix", preferredStyle: .alert)
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addTextField { textField in
                textField.placeholder = "Prefix text"
            }
            alertController.addAction(.init(title: "Send", style: .default, handler: { _ in
                let text = alertController.textFields?.first?.text ?? ""
                Array(0..<100).forEach {
                    Log4G.log("\(text)-\($0)")
                }
            }))
            AppDelegate.rootViewController?.present(alertController, animated: true)
        }
        models.append(model2)

        let model3 = DemoModel(title: "NSLog timeInterval") {
            recursionLog(maxIndex: 100)
        }
        models.append(model3)

        return DemoSection(header: "ASL", model: models)
    }
    
    static var anrSection: DemoSection {
        var models = [DemoModel]()
        
        let title = "Simulate ANR"
        let model = DemoModel(title: title) {
            sleep(4)
            AppDelegate.showAlert(t: "Completed", m: title)
        }
        models.append(model)
        
        return DemoSection(header: "ANR", model: models)
    }

    private static func recursionLog(_ index: Int = 0, maxIndex: Int) {
        if index >= maxIndex { return }
        timeInterval(1, queue: .global()) {
            Log4G.log("timeInterval-\(index)")
            recursionLog(index + 1, maxIndex: maxIndex)
        }
    }

    private static func timeInterval(_ time: TimeInterval, queue: DispatchQueue, callback: (() -> Void)? = nil) {
        queue.asyncAfter(deadline: .now() + time) {
            callback?()
        }
    }
}
