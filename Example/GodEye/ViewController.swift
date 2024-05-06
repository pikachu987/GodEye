//
//  ViewController.swift
//  GodEye
//
//  Created by zixun on 12/27/2016.
//  Copyright (c) 2016 zixun. All rights reserved.
//

import UIKit
import GodEye

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "GodEye Feature List"
        view.backgroundColor = UIColor.black
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Log4G.log("just log")
        
        DispatchQueue.global().async {
            Log4G.warning("just warning")
        }
        
        Log4G.error("just error")
    }
    
    private lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView(frame: CGRect.zero, style: .grouped))

    fileprivate lazy var sections = DemoModelFactory.sectionModels
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DemoCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.textLabel?.font = UIFont(name: "Courier", size: 12)
        }
        cell!.textLabel?.text = sections[indexPath.section].model[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let label = UILabel(frame: CGRect(x: 10, y: 15, width: tableView.frame.size.width - 10, height: 20))
        label.backgroundColor = UIColor.clear
        label.font =  UIFont(name: "Courier", size: 14)
        label.text = sections[section].header
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].model[indexPath.row]
        model.action()
    }
}
