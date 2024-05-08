//
//  GodEyeTabBarController+Show.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import UIKit

extension GodEyeTabBarController {
    var animating: Bool {
        get { objc_getAssociatedObject(self, &Define.Key.Associated.Animation) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Define.Key.Associated.Animation, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    var showing: Bool {
        get { objc_getAssociatedObject(self, &Define.Key.Associated.Showing) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Define.Key.Associated.Showing, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }

    static func toggle() {
        if shared.showing {
            hide()
        } else {
            show()
        }
    }

    static func show() {
        shared.showConsole()
    }
    
    static func hide() {
        shared.hideConsole()
    }
    private func hideConsole() {
        guard showing && !animating else { return }
        animating = true
        dismiss(animated: true, completion: { [weak self] in
            self?.showing = false
            self?.animating = false
        })
    }
    
    private func showConsole() {
        guard !showing && !animating else { return }
        animating = true
        modalPresentationStyle = .fullScreen
        GodEye.visibleViewController?.present(self, animated: true, completion: { [weak self] in
            self?.showing = true
            self?.animating = false
        })
    }
}
