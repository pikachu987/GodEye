//
//  AppDelegate.swift
//  GodEye
//
//  Created by zixun on 03/03/2019.
//  Copyright (c) 2019 zixun. All rights reserved.
//

import UIKit
import GodEye

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    static var rootViewController: UIViewController? {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //        GodEye.makeEye(with: self.window!)
        //
        
        
        let configuration = Configuration()
        configuration.command.add(command: "test", description: "test command") { () -> (String) in
            return "this is test command result"
        }
        configuration.command.add(command: "info", description: "print test info") { () -> (String) in
            return "info"
        }
        
        GodEye.makeEye(with: self.window!, configuration: configuration)
        return true
    }

    static func showAlert(t: String, m: String) {
        let alertController = UIAlertController(title: t, message: m, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        rootViewController?.present(alertController, animated: true)
    }
}
