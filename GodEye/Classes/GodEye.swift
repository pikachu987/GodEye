//
//  GodEye.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import Foundation

open class GodEye: NSObject {
    private static var window: UIWindow?

    static var configuration: Configuration?

    open class func makeEye(with window: UIWindow, configuration: Configuration = Configuration()) {
        LogRecordModel.create()
        CrashRecordModel.create()
        NetworkRecordModel.create()
        ANRRecordModel.create()
        CommandRecordModel.create()
        LeakRecordModel.create()
        
        self.window = window
        self.window?.hook()
        self.configuration = configuration
        show()
    }

    open class func show() {
        viewController.show()
    }

    open class func hide() {
        viewController.hide()
    }
}

extension GodEye {
    private static let viewController: GodEyeViewController = {
        GodEyeViewController()
    }()

    static var visibleViewController: UIViewController? {
        (window ?? UIApplication.shared.mainWindow())?.rootViewController.map { getVisibleViewController($0) }
    }

    private static func getVisibleViewController(_ viewController: UIViewController) -> UIViewController {
        if let tabBarController = viewController as? UITabBarController, let visibleViewController = tabBarController.selectedViewController {
            return getVisibleViewController(visibleViewController)
        } else if let navigationController = viewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController  {
            return getVisibleViewController(visibleViewController)
        } else if let visibleViewController = viewController.presentedViewController {
            return getVisibleViewController(visibleViewController)
        }
        return viewController
    }
}
