//
//  GodEyeTabBarController.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import UIKit

final class GodEyeTabBarController: UITabBarController {

    static let shared = GodEyeTabBarController()
    
    lazy var consoleVC: UINavigationController = {
        $0.tabBarItem = UITabBarItem(title: "Console", image: .init(systemName: "apple.terminal"), selectedImage: nil)
        return $0
    }(UINavigationController(rootViewController: ConsoleViewController()))

    lazy var monitorVC: UINavigationController = {
        $0.tabBarItem = UITabBarItem(title: "Monitor", image: .init(systemName: "laptopcomputer"), selectedImage: nil)
        return $0
    }(UINavigationController(rootViewController: MonitorViewController()))

    lazy var fileVC: UINavigationController = {
        $0.tabBarItem = UITabBarItem(title: "File", image: .init(systemName: "folder.fill"), selectedImage: nil)
        return $0
    }(UINavigationController(rootViewController: FileViewController()))

    lazy var storageVC: UINavigationController = {
        $0.tabBarItem = UITabBarItem(title: "Storage", image: .init(systemName: "archivebox.fill"), selectedImage: nil)
        return $0
    }(UINavigationController(rootViewController: StorageViewController()))

    lazy var settingVC: UINavigationController = {
        $0.tabBarItem = UITabBarItem(title: "Setting", image: .init(systemName: "gearshape.fill"), selectedImage: nil)
        return $0
    }(UINavigationController(rootViewController: SettingViewController()))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        selectedIndex = 0
        tabBar.barTintColor = .black

        viewControllers = [consoleVC, monitorVC, fileVC, storageVC, settingVC]
    }

    func addRecord(model: RecordORMProtocol) {
        (consoleVC.viewControllers.first as? ConsoleViewController)?.addRecord(model: model)
    }
}
