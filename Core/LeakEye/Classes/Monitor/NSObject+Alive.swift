//
//  NSObject+Alive.swift
//  Pods
//
//  Created by zixun on 16/12/13.
//
//

import Foundation
//--------------------------------------------------------------------------
// MARK: - NSObject+Alive
// DESCRIPTION: NSObject extension for judge if the instance is alive
//--------------------------------------------------------------------------
extension NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: INTERNAL FUNCTION
    //--------------------------------------------------------------------------
    func judgeAlive() -> Bool {
        if isKind(of: UIViewController.classForCoder()) {
            return judge(self as? UIViewController)
        } else if isKind(of: UIView.classForCoder()) {
            return judge(self as? UIView )
        } else {
            return judge(self)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTION
    //--------------------------------------------------------------------------
    
    /// judeg a comman instance is alive
    fileprivate func judge(_ common: NSObject) -> Bool {
        var alive = true
        if common.agent?.host == nil {
            alive = false
        }
        
        return alive
    }
    
    /// judge the controller instance is alive
    fileprivate func judge(_ controller: UIViewController?) -> Bool {
        //1. self.view is not in the window
        //2. self is not in the navigation controllers
        
        var visiable = false
        
        var view = controller?.view

        while ((view?.superview) != nil) {
            view = view?.superview
        }
        
        if view?.isKind(of: UIWindow.self) == true {
            visiable = true
        }
        
        var holdable = false
        if controller?.navigationController != nil || controller?.presentingViewController != nil {
            holdable = true
        }
        
        if visiable == false && holdable == false {
            return false
        } else {
            return true
        }
    }
    
    /// judge the view instance is alive
    fileprivate func judge(_ view: UIView?) -> Bool {

        var alive = true
        var onUIStack = false
        var v = view
        
        while v?.superview != nil {
            if let superview = v?.superview {
                v = superview
            }
        }
        
        if v?.isKind(of: UIWindow.classForCoder()) == true {
            onUIStack = true
        }
        
        if view?.agent?.responder == nil {
            var r = view?.next
            while r != nil {
                guard let dummyR = r else { break }
                if dummyR.next == nil {
                    break
                } else {
                    r = dummyR.next
                }
                
                if (r?.isKind(of: UIViewController.classForCoder())) == true {
                    break
                }
            }
            view?.agent?.responder = r
        }
        
        if onUIStack == false {
            alive = false
            if let r = view?.agent?.responder  {
                alive = r.isKind(of: UIViewController.classForCoder())
            }
        }
        return alive
    }
}
