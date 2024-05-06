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
        viewController.show()
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
}
