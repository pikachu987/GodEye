//
//  ConsoleViewController.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import UIKit

final class ConsoleViewController: UIViewController {
    lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: view.bounds, style: .grouped))

    private(set) var isViewAppearOnce: Bool = false

    private(set) lazy var dataSource: [[RecordType]] = {
        var new = [[RecordType]]()
        var section1 = [RecordType]()
        section1.append(.log)
        section1.append(.crash)
        section1.append(.network)
        section1.append(.anr)
        section1.append(.leak)
        new.append(section1)

        var section2 = [RecordType]()
        section2.append(.command)
        new.append(section2)
        return new
    }()

    weak var printViewController: ConsolePrintViewController?

    init() {
        super.init(nibName: nil, bundle: nil)

        openEyes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        view.clipsToBounds = true
        view.backgroundColor = .niceBlack
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isViewAppearOnce = true
        navigationItem.title = "Console"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(leftBarButtonItemTapped(_:)))
    }

    @objc private func leftBarButtonItemTapped(_ sender: UIBarButtonItem) {
        GodEyeTabBarController.hide()
    }
}
