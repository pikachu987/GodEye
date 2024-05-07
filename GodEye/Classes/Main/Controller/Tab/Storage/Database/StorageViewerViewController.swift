//
//  StorageViewerViewController.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import UIKit

final class StorageViewerViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alwaysBounceVertical = false
        $0.showsVerticalScrollIndicator = false
        return $0
    }(UIScrollView())

    private lazy var columnTableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 64
        $0.backgroundColor = .clear
        $0.separatorInset = .zero
        return $0
    }(UITableView(frame: .zero, style: .plain))

    private lazy var lineView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        return $0
    }(UIView())

    private lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight = 64
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .clear
        $0.separatorInset = .zero
        return $0
    }(UITableView(frame: .zero, style: .plain))

    private lazy var scrollWidthView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        return $0
    }(UIView())

    private var viewerModel: StorageViewable
    private var isPrevPopGestureEnabled: Bool = true

    init(viewerModel: StorageViewable) {
        self.viewerModel = viewerModel

        super.init(nibName: nil, bundle: nil)
        isPrevPopGestureEnabled = navigationController?.interactivePopGestureRecognizer?.isEnabled ?? true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = viewerModel.title
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = isPrevPopGestureEnabled
    }
}

extension StorageViewerViewController {
    private func setupViews() {
        view.backgroundColor = .niceBlack
        view.clipsToBounds = true

        view.addSubview(scrollView)
        scrollView.addSubview(scrollWidthView)
        scrollView.addSubview(columnTableView)
        scrollView.addSubview(lineView)
        scrollView.addSubview(tableView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let contentWidthConstraint = scrollWidthView.widthAnchor.constraint(equalToConstant: viewerModel.fullWidth)
        contentWidthConstraint.priority = .defaultHigh
        contentWidthConstraint.isActive = true

        let widthViewHeightConstraint = scrollWidthView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        widthViewHeightConstraint.priority = .init(1)
        widthViewHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            scrollWidthView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollWidthView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollWidthView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollWidthView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollWidthView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor)
        ])

        let columnHeight: CGFloat = 50

        NSLayoutConstraint.activate([
            columnTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            columnTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            columnTableView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            columnTableView.heightAnchor.constraint(equalToConstant: columnHeight)
        ])

        let lineHeight: CGFloat = 1

        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: columnTableView.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: lineHeight)
        ])

        let tableWidthConstraint = tableView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        tableWidthConstraint.priority = .init(1)
        tableWidthConstraint.isActive = true

        let tableHeightConstraint = tableView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -columnHeight - lineHeight)
        tableHeightConstraint.priority = .defaultHigh
        tableHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}

extension StorageViewerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == columnTableView {
            return 1
        } else {
            return viewerModel.rowCount
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .default, identifier: StorageRowCell.identifier, { (cell: StorageRowCell) in
            if tableView == columnTableView {
                cell.bind(model: viewerModel.columnModel)
            } else {
                guard viewerModel.rowModels.indices ~= indexPath.row else { return }
                cell.bind(model: viewerModel.rowModels[indexPath.row])
            }
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == columnTableView { return }
        viewerModel.toggleTap(index: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
