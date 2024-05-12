//
//  CommandConfiguration.swift
//  Pods
//
//  Created by zixun on 17/1/22.
//
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - CommandConfiguration
//--------------------------------------------------------------------------
open class CommandConfiguration: NSObject {
    public override init() {
        super.init()
        add(command: "screen", description: "UIScreen Info") { () -> (String) in
            var result = ""
            result += "UIScreen.main.bounds: \(UIScreen.main.bounds)"
            result += "\nUIScreen.main.nativeBounds: \(UIScreen.main.nativeBounds)"
            result += "\nUIScreen.main.scale: \(UIScreen.main.scale)"
            result += "\nUIScreen.main.nativeScale: \(UIScreen.main.nativeScale)"
            result += "\nUIScreen.main.availableModes: \(UIScreen.main.availableModes)"
            result += "\nUIScreen.main.maximumFramesPerSecond: \(UIScreen.main.maximumFramesPerSecond)"
            return result
        }
        add(command: "window", description: "UIWindow Info") { () -> (String) in
            var result = ""
            let window = GodEye.window
            result += "statusBarHeight: \(window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)"
            result += "\nsafeAreaInsets: \(window?.safeAreaInsets ?? .init(top: 0, left: 0, bottom: 0, right: 0))"
            result += "\nframe: \(window?.frame ?? .zero)"
            return result
        }
        add(command: "vc", description: "VisibleViewController") { () -> (String) in
            var result = ""
            let visibleViewController = GodEye.visibleViewControllerForProject
            result += "visibleViewController: \(visibleViewController)"
            result += "\nview.frame: \(visibleViewController?.view.frame)"
            result += "\nview.subviews: \(visibleViewController?.view.subviews)"
            return result
        }
        add(command: "view", description: "VisibleViewController View") { () -> (String) in
            var result = ""
            guard let visibleViewController = GodEye.visibleViewControllerForProject else { return "VisibleViewController Is Empty" }
            func recursion(view: UIView, depth: Int) -> String {
                var text = "\(Array(0...depth).map { _ in "-" }.joined()) \(view)"
                let subviewText = view.subviews.map {
                    return recursion(view: $0, depth: depth + 1)
                }.joined(separator: "\n")
                if !subviewText.isEmpty {
                    text += "\n\(subviewText)"
                }
                return text
            }
            result += recursion(view: visibleViewController.view, depth: 0)
            return result
        }
    }

    //--------------------------------------------------------------------------
    // MARK: OPEN FUNCTION
    //--------------------------------------------------------------------------

    /// Add a command with description and action
    open func add(command: String, description: String, action: @escaping () -> (String)) {
        let model = CommandModel(command: command, description: description, action: action)
        commandList.append(model)
    }
    
    //--------------------------------------------------------------------------
    // MARK: INTERNAL FUNCTION
    //--------------------------------------------------------------------------
    
    /// execute the commnad by the name,and call the callback will complete the action
    func execute(command: String, complete: (CommandRecordModel) -> ()) {
        var command = command.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var recordModel: CommandRecordModel? = nil
        if command == "help" {
            var commandDescription = ""
            for model in commandList {
                let line = "    + \(model.command)   \(model.comdDescription)\n"
                commandDescription += line
            }
            let result = "\n\n GodEye:\n    $ Automaticly disply Log,Crash,Network,ANR,Leak,CPU,RAM,FPS,NetFlow,Folder and etc with one line of code. Just like God opened his eyes \n\n Commands:\n\(commandDescription)"
            recordModel = CommandRecordModel(command: command, actionResult: result)
        } else {
            if let model = model(of: command) {
                let result = model.action()
                recordModel = CommandRecordModel(command: command, actionResult: result)
            } else {
                recordModel = CommandRecordModel(command: command, actionResult: "    \(command) not found, enter 'help' to view all commands\n")
            }
        }
        if let recordModel = recordModel {
            complete(recordModel)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTION
    //--------------------------------------------------------------------------
    
    /// get the commnad model with commnad name
    private func model(of command: String) -> CommandModel? {
        for model in commandList {
            if model.command == command {
                return model
            }
        }
        return nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    private var commandList = [CommandModel]()
    
    //--------------------------------------------------------------------------
    // MARK: INNER CLASS
    //--------------------------------------------------------------------------
    class CommandModel: NSObject {
        let command: String
        let comdDescription: String
        let action: (() -> (String))

        init(command: String, description: String, action: @escaping () -> (String)) {
            self.command = command
            self.comdDescription = description
            self.action = action
            super.init()
        }
        
    }
}
