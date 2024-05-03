//
//  AppNavigationController.swift
//  Pods
//
//  Created by zixun on 2016/10/24.
//
//

import UIKit

public class AppNavigationController: UINavigationController {
    
    public var enable = true
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取系统自带滑动手势的target对象
        interactivePopGestureRecognizer?.delegate.map {
            // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
            let pan = UIPanGestureRecognizer(target: $0, action: Selector("handleNavigationTransition:"))

            // 设置手势代理，拦截手势触发
            pan.delegate = self

            // 给导航控制器的view添加全屏滑动手势
            view.addGestureRecognizer(pan)
        }
        
        // 禁止使用系统自带的滑动手势
        interactivePopGestureRecognizer!.isEnabled = false
    }
    
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: UIGestureRecognizerDelegate
extension AppNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let translation: CGPoint = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: view.superview) else { return false }

        guard enable else { return false }

        if (translation.x < 0) {
            return false //往右滑返回，往左滑不做操作
        }
        
        if (viewControllers.count <= 1) {
            return false
        }
        return true
    }
}
