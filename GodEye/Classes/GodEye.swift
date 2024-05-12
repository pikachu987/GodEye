//
//  GodEye.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import Foundation

open class GodEye: NSObject {
    static var window: UIWindow?

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
        _ = GodEyeTabBarController.shared.showing
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

    static var visibleViewControllerForProject: UIViewController? {
        let viewController = (window ?? UIApplication.shared.mainWindow())?.rootViewController.map { getVisibleViewController($0) }
        if viewController?.tabBarController == GodEyeTabBarController.shared {
            return viewController?.presentingViewController.map { getViewController($0) }
        }
        return viewController
    }

    static var visibleViewControllerForEvery: UIViewController? {
        let viewController = (window ?? UIApplication.shared.mainWindow())?.rootViewController.map { getVisibleViewController($0) }
        return viewController
    }

    private static func getViewController(_ viewController: UIViewController) -> UIViewController {
        if let tabBarController = viewController as? UITabBarController, let visibleViewController = tabBarController.selectedViewController {
            return getViewController(visibleViewController)
        } else if let navigationController = viewController as? UINavigationController, let visibleViewController = navigationController.viewControllers.last  {
            return getViewController(visibleViewController)
        } else {
            return viewController
        }
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
