//
//  MonitorViewController.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import Foundation

final class MonitorViewController: UIViewController {
    private let scrollView: UIScrollView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIScrollView())

    private let containerView: MonitorContainerView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MonitorContainerView())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = "Monitor"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(leftBarButtonItemTapped(_:)))

        containerView.viewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        containerView.viewDidDisappear()
    }
}

extension MonitorViewController {
    private func setupViews() {
        view.backgroundColor = .niceBlack
        view.clipsToBounds = true

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let heightAnchor = containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightAnchor.priority = .defaultLow
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            heightAnchor
        ])
    }

    @objc private func leftBarButtonItemTapped(_ sender: UIBarButtonItem) {
        GodEyeTabBarController.hide()
    }
}
