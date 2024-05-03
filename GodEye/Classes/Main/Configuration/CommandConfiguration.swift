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
