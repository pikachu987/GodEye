//
//  UIWindow+Event.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import UIKit

extension UIWindow {
    fileprivate class var hookWindow: UIWindow? {
        get {
            objc_getAssociatedObject(self, &Define.Key.Associated.HookWindow) as? UIWindow
        }
        set {
            objc_setAssociatedObject(self, &Define.Key.Associated.HookWindow, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func hook() {
        UIWindow.hookWindow = self
        
        var orig = #selector(UIWindow.sendEvent(_:))
        var alter = #selector(UIWindow.app_sendEvent(_:))
        _ = UIWindow.swizzleInstanceMethod(origSelector: orig, toAlterSelector: alter)

        orig = #selector(UIResponder.motionEnded(_:with:))
        alter = #selector(UIResponder.app_motionEnded(_:with:))
        _ = UIResponder.swizzleInstanceMethod(origSelector: orig, toAlterSelector: alter)
    }
}

extension UIResponder {
    @objc func app_motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard let control = GodEye.configuration?.control else { return }
        if control.enabled && control.shakeToShow() {
            if event?.type == UIEvent.EventType.motion && event?.subtype == UIEvent.EventSubtype.motionShake {
                if GodEyeTabBarController.shared.showing {
                    GodEyeTabBarController.hide()
                } else {
                    GodEyeTabBarController.show()
                }
            }
        }
        app_motionEnded(motion, with: event)
    }
}

extension UIWindow {
    @objc fileprivate func app_sendEvent(_ event: UIEvent) {
        if canHandle(event: event) {
            handle(event: event)
        }
        
        app_sendEvent(event)
    }
    
    private func canHandle(event: UIEvent) -> Bool {
        guard UIWindow.hookWindow == self else { return false }
        guard let control = GodEye.configuration?.control else { return false }

        if control.enabled && event.type == .touches {
            let touches = event.allTouches
            if touches?.count == control.touchesToShow() { return true }
        }

        return false
    }
    
    private func handle(event: UIEvent) {
        guard let touches = event.allTouches else { return }

        var allUp = true
        var allDown = true
        var allLeft = true
        var allRight = true

        touches.forEach { (touch:UITouch) in
            if touch.location(in: self).y <= touch.previousLocation(in: self).y {
                allDown = false
            }
            
            if touch.location(in: self).y >= touch.previousLocation(in: self).y {
                allUp = false
            }
            
            if touch.location(in: self).x <= touch.previousLocation(in: self).x {
                allLeft = false
            }
            
            if touch.location(in: self).x >= touch.previousLocation(in: self).x {
                allRight = false
            }
        }
        
        switch UIApplication.shared.statusBarOrientation {
        case .portraitUpsideDown:
            handleConsole(show: allDown, hide: allUp)
        case .landscapeLeft:
            handleConsole(show: allRight, hide: allLeft)
        case .landscapeRight:
            handleConsole(show: allLeft, hide: allRight)
        default:
            handleConsole(show: allUp, hide: allDown)
        }
    }
    
    private func handleConsole(show: Bool, hide: Bool) {
        if show {
            GodEyeTabBarController.show()
        } else if hide {
            GodEyeTabBarController.hide()
        }
    }
}
