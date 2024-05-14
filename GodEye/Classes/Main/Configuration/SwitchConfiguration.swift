//
//  SwitchConfiguration.swift
//  Pods
//
//  Created by zixun on 17/1/22.
//
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - SwitchConfiguration
// DESCRIPTION: all switch is default switch value, it only will 
// work while passed as argument while GodEye init.
// In an other words,after the GodEye has inited,you can't
// change the switch value to turn on or turn off the monitor eye
//--------------------------------------------------------------------------
open class SettingConfiguration: NSObject {
    /// asl switch defualt value
    open var asl: Bool = false
    /// log4g switch default value
    open var log4g: Bool = true
    /// crash switch default value
    open var crash: Bool = true
    /// network switch default value
    open var network: Bool = true
    /// anr switch default value
    open var anr: Bool = true
    /// leak switch default value
    open var leak: Bool = true

    open func add(title: String, description: String, action: @escaping () -> Void) {
        let model = ActionModel(title: title, description: description, action: action)
        actionList.append(model)
    }

    private(set) var actionList = [ActionModel]()

    //--------------------------------------------------------------------------
    // MARK: INNER CLASS
    //--------------------------------------------------------------------------
    class ActionModel: NSObject {
        let title: String
        let desc: String
        let action: (() -> Void)

        init(title: String, description: String, action: @escaping () -> Void) {
            self.title = title
            self.desc = description
            self.action = action
            super.init()
        }

    }
}
