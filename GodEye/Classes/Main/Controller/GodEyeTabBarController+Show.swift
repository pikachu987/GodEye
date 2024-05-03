//
//  GodEyeTabBarController+Show.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import Foundation

extension GodEyeTabBarController {
    var animating: Bool {
        get { objc_getAssociatedObject(self, &Define.Key.Associated.Animation) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Define.Key.Associated.Animation, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    var showing: Bool {
        get { objc_getAssociatedObject(self, &Define.Key.Associated.Showing) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Define.Key.Associated.Showing, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    static func show() {
        shared.showConsole()
    }
    
    static func hide() {
        shared.hideConsole()
    }
    
    private var window: UIWindow? {
        GodEye.window ?? UIApplication.shared.mainWindow()
    }

    private func hideConsole() {
        guard showing && !animating else { return }
        animating = true
        GodEye.show()
        dismiss(animated: true, completion: { [weak self] in
            self?.showing = false
            self?.animating = false
        })
    }
    
    private func showConsole() {
        guard !showing && !animating else { return }
        animating = true
        GodEye.hide()
        modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(self, animated: true, completion: { [weak self] in
            self?.showing = true
            self?.animating = false
        })
    }
}
