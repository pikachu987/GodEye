//
//  DemoModel.swift
//  GodEye
//
//  Created by zixun on 17/1/10.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import GodEye
import FMDB
import CoreData

class DemoModel: NSObject {
    let title: String
    let action: (() -> ())

    init(title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
        super.init()
    }
}

class DemoSection: NSObject {
    let header: String
    let model: [DemoModel]

    init(header: String, model: [DemoModel]) {
        self.header = header
        self.model = model
        super.init()
    }
}

class DemoModelFactory: NSObject {
    private static let shared = DemoModelFactory()

    static var sectionModels: [DemoSection] = {
        var sectionModels = [DemoSection]()
        sectionModels.append(logSection)
        sectionModels.append(fileSection)
        sectionModels.append(userDefaultsSection)
        sectionModels.append(coreDataSection)
        sectionModels.append(dbSection)

        return sectionModels
    }()

    override init() {}
}

// MARK: Log
extension DemoModelFactory {
    private static var logSection: DemoSection {
        var models = [DemoModel]()
        models.append(logAslModel)
        models.append(logDefaultModel)
        models.append(logMultipleModel)
        models.append(logTimeIntervalModel)
        models.append(logExceptionCrashModel)
        models.append(logNetworkModel)
        models.append(logARNModel)
        models.append(logLeakModel)
        return DemoSection(header: "Log", model: models)
    }

    private static var logAslModel: DemoModel {
        DemoModel(title: "ASL NSLog") {
            NSLog("test")
            AppDelegate.showAlert()
        }
    }

    private static var logDefaultModel: DemoModel {
        DemoModel(title: "Default Log4G") {
            Log4G.log("just log")
            Log4G.warning("just warning")
            Log4G.error("just error")
            AppDelegate.showAlert()
        }
    }

    private static var logMultipleModel: DemoModel {
        DemoModel(title: "Send log 1~100") {
            let alertController = UIAlertController(title: nil, message: "log prefix", preferredStyle: .alert)
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addTextField { textField in
                textField.placeholder = "Prefix text"
            }
            alertController.addAction(.init(title: "Send", style: .default, handler: { _ in
                let text = alertController.textFields?.first?.text ?? ""
                Array(0..<100).forEach {
                    Log4G.log("\(text)-\($0)")
                }
                AppDelegate.showAlert()
            }))
            AppDelegate.rootViewController?.present(alertController, animated: true)
        }
    }

    private static var logTimeIntervalModel: DemoModel {
        DemoModel(title: "Recursion timeInterval 100") {
            recursionLog(maxIndex: 100){
                AppDelegate.showAlert()
            }
        }
    }

    private static var logExceptionCrashModel: DemoModel {
        DemoModel(title: "Exception Crash") { let array = Array<Int>(); _ = array[2] }
    }

    private static var logNetworkModel: DemoModel {
        DemoModel(title: "Send Network") {
            let url = "https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc"
            URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!), completionHandler: { _, _, _ in
                AppDelegate.showAlert()
            }).resume()
        }
    }

    private static var logARNModel: DemoModel {
        DemoModel(title: "Simulate ANR") {
            sleep(4)
            AppDelegate.showAlert()
        }
    }

    private static var logLeakModel: DemoModel {
        DemoModel(title: "Leak ViewController") {
            let leak1 = LeakTest()
            let leak2 = LeakTest()
            leak1.test = leak2
            leak2.test = leak1
        }
    }

    private static func recursionLog(_ index: Int = 0, maxIndex: Int, completion: (() -> Void)? = nil) {
        if index >= maxIndex {
            completion?()
            return
        }
        timeInterval(1, queue: .global()) {
            Log4G.log("timeInterval-\(index)")
            recursionLog(index + 1, maxIndex: maxIndex, completion: completion)
        }
    }

    private static func timeInterval(_ time: TimeInterval, queue: DispatchQueue, callback: (() -> Void)? = nil) {
        queue.asyncAfter(deadline: .now() + time) {
            callback?()
        }
    }

    class LeakTest {
        deinit {
            print("????")
        }
        var test: LeakTest?
    }
}

// MARK: File
extension DemoModelFactory {
    private static let fileManager = FileManager.default
    private static var documentURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private static var tempDocumentURL: URL {
        if #available(iOS 10.0, *) {
            return fileManager.temporaryDirectory
        } else {
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }

    private static var fileSection: DemoSection {
        var models = [DemoModel]()
        models.append(fileDirectoryModel)
        models.append(fileTemporaryDirectoryModel)
        models.append(fileJSONModel)
        models.append(fileImageModel)
        models.append(fileVideoModel)
        return DemoSection(header: "File", model: models)
    }

    private static var fileDirectoryModel: DemoModel {
        DemoModel(title: "Add Directory") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
            let currentTimeFormatter = formatter.string(from: Date())
            let path: URL
            if #available(iOS 16.0, *) {
                path = documentURL.appending(path: currentTimeFormatter)
            } else {
                path = documentURL.appendingPathComponent(currentTimeFormatter)
            }
            try? fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            AppDelegate.showAlert()
        }
    }

    private static var fileTemporaryDirectoryModel: DemoModel {
        DemoModel(title: "Add Temporary Directory") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
            let currentTimeFormatter = formatter.string(from: Date())
            let path: URL
            if #available(iOS 16.0, *) {
                path = tempDocumentURL.appending(path: currentTimeFormatter)
            } else {
                path = tempDocumentURL.appendingPathComponent(currentTimeFormatter)
            }
            try? fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            AppDelegate.showAlert()
        }
    }

    private static var fileJSONModel: DemoModel {
        DemoModel(title: "Add JSON file") {
            let jsonStr = "{'test': 'test'}"
            guard let data = jsonStr.data(using: .utf8) else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
            let currentTimeFormatter = formatter.string(from: Date())
            let path: URL
            if #available(iOS 16.0, *) {
                path = documentURL.appending(path: currentTimeFormatter.appending(".json"))
            } else {
                path = documentURL.appendingPathComponent(currentTimeFormatter.appending(".json"))
            }
            try? data.write(to: path, options: .atomic)
            AppDelegate.showAlert()
        }
    }

    private static var fileImageModel: DemoModel {
        DemoModel(title: "Add Image file") {
            let url = URL(string: "https://raw.githubusercontent.com/zixun/GodEye/master/design/image/logo.png")!
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
                guard let data = data else { return }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
                let currentTimeFormatter = formatter.string(from: Date())
                let path: URL
                if #available(iOS 16.0, *) {
                    path = documentURL.appending(path: currentTimeFormatter.appending(".png"))
                } else {
                    path = documentURL.appendingPathComponent(currentTimeFormatter.appending(".png"))
                }
                try? data.write(to: path, options: .atomic)
                AppDelegate.showAlert()
            }
            task.resume()
        }
    }

    private static var fileVideoModel: DemoModel {
        DemoModel(title: "Add Video file") {
            let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
                guard let data = data else { return }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
                let currentTimeFormatter = formatter.string(from: Date())
                let path: URL
                if #available(iOS 16.0, *) {
                    path = documentURL.appending(path: currentTimeFormatter.appending(".mp4"))
                } else {
                    path = documentURL.appendingPathComponent(currentTimeFormatter.appending(".mp4"))
                }
                try? data.write(to: path, options: .atomic)
                AppDelegate.showAlert()
            }
            task.resume()
        }
    }
}

// MARK: UserDefaults
extension DemoModelFactory {
    static var userDefaultsSection: DemoSection {
        var models = [DemoModel]()
        models.append(userDefaultsModel)
        return DemoSection(header: "UserDefaults", model: models)
    }

    private static var userDefaultsModel: DemoModel {
        DemoModel(title: "Add UserDefaults") {
            UserDefaults.standard.setValue(makeDummyArray(), forKey: "test1")
            UserDefaults.standard.setValue(makeDummyDict(), forKey: "test2")
            UserDefaults.standard.setValue("test", forKey: "test3")
            UserDefaults.standard.setValue(123123123, forKey: "test4")
            UserDefaults.standard.setValue(true, forKey: "test5")
            UserDefaults.standard.setValue(1.232213134538954, forKey: "test6")
            AppDelegate.showAlert()
        }
    }

    private static func makeDummyArray() -> [Any] {
        var array = [Any]()
        var dict = [String: Any]()
        dict.updateValue("test1", forKey: "test1")
        dict.updateValue("test2", forKey: "test2")
        dict.updateValue(543242.23424242, forKey: "test3")
        var dict2 = [String: Any]()
        dict2.updateValue("test1", forKey: "test1")
        dict2.updateValue("test2", forKey: "test2")
        dict2.updateValue(["test1", "test2", "test3", 4, 5, 6], forKey: "test3")
        dict2.updateValue(false, forKey: "test4")
        array.append(dict)
        array.append(dict2)
        array.append([String: Any]())
        return array
    }

    private static func makeDummyDict() -> [String: Any] {
        var dict = [String: Any]()
        dict.updateValue(makeDummyArray(), forKey: "test1")
        dict.updateValue("test", forKey: "test2")
        dict.updateValue(123132313, forKey: "test3")
        dict.updateValue(123.132313, forKey: "test4")
        dict.updateValue(false, forKey: "test5")
        dict.updateValue(true, forKey: "test6")
        return dict
    }
}

// MARK: CoreData
extension DemoModelFactory {
    static var coreDataSection: DemoSection {
        var models = [DemoModel]()
        models.append(coreDataInsertModel)
        return DemoSection(header: "CoreData", model: models)
    }

    private static var coreDataInsertModel: DemoModel {
        DemoModel(title: "Insert Rows") {
            CoreDataManager().testInsert()
            AppDelegate.showAlert()
        }
    }
}

// MARK: Database
extension DemoModelFactory {
    static var dbSection: DemoSection {
        var models = [DemoModel]()
        models.append(dbCreateTableModel)
        models.append(dbInsertRowsModel)
        return DemoSection(header: "Database", model: models)
    }

    private static var dbCreateTableModel: DemoModel {
        DemoModel(title: "Create Table IfNeeded") {
            FMDBManager.shared.testCreate()
            AppDelegate.showAlert()
        }
    }

    private static var dbInsertRowsModel: DemoModel {
        DemoModel(title: "Insert Rows") {
            FMDBManager.shared.testInsert()
            AppDelegate.showAlert()
        }
    }
}

class CoreDataManager {
    private lazy var persistentContainerWithCoreData: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores { NSPersistentStoreDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    private lazy var persistentContainerWithTest: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Test")
        container.loadPersistentStores { NSPersistentStoreDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func testInsert() {
        testInsertTest1()
        testInsertTest2()
        testInsertTest3()
    }

    private func testInsertTest1() {
        if let entity = NSEntityDescription.entity(forEntityName: "EntityTest1", in: persistentContainerWithCoreData.viewContext) {
            for i in 0...1000 {
                let entityTest1Model1 = NSManagedObject(entity: entity, insertInto: persistentContainerWithCoreData.viewContext)
                entityTest1Model1.setValue(Date(), forKey: "date")
                entityTest1Model1.setValue("text-\(i)", forKey: "text")
                entityTest1Model1.setValue(Double(i) * 1.2313, forKey: "valueTest")
            }
            try? persistentContainerWithCoreData.viewContext.save()
        }
    }

    private func testInsertTest2() {
        if let entity = NSEntityDescription.entity(forEntityName: "Entity2", in: persistentContainerWithCoreData.viewContext) {
            for i in 0...1000 {
                let entityTest1Model1 = NSManagedObject(entity: entity, insertInto: persistentContainerWithCoreData.viewContext)
                entityTest1Model1.setValue("test1: \(i)", forKey: "test1")
                entityTest1Model1.setValue("valueTest: \(i)", forKey: "valueTest")
            }
            try? persistentContainerWithCoreData.viewContext.save()
        }
    }

    private func testInsertTest3() {
        if let entity = NSEntityDescription.entity(forEntityName: "TestData", in: persistentContainerWithTest.viewContext) {
            for i in 0...10000 {
                let entityTest1Model1 = NSManagedObject(entity: entity, insertInto: persistentContainerWithTest.viewContext)
                entityTest1Model1.setValue("test1: \(i)", forKey: "test1")
                entityTest1Model1.setValue("test2: \(i)", forKey: "test2")
                entityTest1Model1.setValue("test3: \(i)", forKey: "test3")
                entityTest1Model1.setValue("test4: \(i)", forKey: "test4")
                entityTest1Model1.setValue("test5: \(i)", forKey: "test5")
            }
            try? persistentContainerWithTest.viewContext.save()
        }
    }
}

class FMDBManager {
    static let shared = FMDBManager()

    private let resourceName = "GodEye.db"

    lazy var databasePath: String = {
        AppPathForDocumentsResource(relativePath: resourceName)
    }()

    private lazy var database: FMDatabase = {
        FMDatabase(path: databasePath)
    }()

    func testCreate() {
        execute(query: testCreateTable(tableName: "DBTest1"))
        execute(query: testCreateTable(tableName: "DBTest2"))
        execute(query: testCreateTable(tableName: "DBTest3"))
    }

    func testInsert() {
        for i in 0...100 {
            execute(query: testInsertRow(tableName: "DBTest1", title: "Test\(i)"))
        }
        for i in 0...1000 {
            execute(query: testInsertRow(tableName: "DBTest2", title: "Test\(i)"))
        }
    }

    private func testCreateTable(tableName: String) -> String {
        "CREATE TABLE IF NOT EXISTS \(tableName) (" +
            "SEQ INTEGER PRIMARY KEY AUTOINCREMENT," +
            "TITLE VARCHAR," +
            "CREATE_DATE DOUBLE" +
            ");"
    }

    private func testInsertRow(tableName: String, title: String) -> String {
        "INSERT INTO \(tableName) (TITLE, CREATE_DATE) VALUES (\"\(title)\", \"\(Date())\");"
    }

    private func execute(query: String) {
        if !database.isOpen && !database.open() { return }
        database.executeStatements(query)
    }
}
