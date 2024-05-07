//
//  AppDelegate.swift
//  GodEye
//
//  Created by zixun on 03/03/2019.
//  Copyright (c) 2019 zixun. All rights reserved.
//

import UIKit
import GodEye
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    static var rootViewController: UIViewController? {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = Configuration()
        configuration.command.add(command: "test", description: "test command") { () -> (String) in
            return "this is test command result"
        }
        configuration.command.add(command: "info", description: "print test info") { () -> (String) in
            return "info"
        }
        configuration.storage.databasePaths.append(FMDBManager.shared.databasePath)
        configuration.storage.coreDataNames.append(contentsOf: ["CoreData", "Test"])

        GodEye.makeEye(with: self.window!, configuration: configuration)

        return true
    }

    static func showAlert(t: String? = nil, m: String = "Action Complete") {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: t, message: m, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            rootViewController?.present(alertController, animated: true)
        }
    }
}
