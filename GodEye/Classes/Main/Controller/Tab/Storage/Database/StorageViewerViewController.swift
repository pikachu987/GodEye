//
//  StorageViewerViewController.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import UIKit

final class StorageViewerViewController: UIViewController {
    private lazy var topStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        return $0
    }(UIStackView(arrangedSubviews: [searchBar, filterView]))

    private lazy var searchBar: UISearchBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.searchBarStyle = .minimal
        $0.backgroundColor = .niceBlack
        $0.returnKeyType = .done
        $0.enablesReturnKeyAutomatically = false
        $0.placeholder = "Search Text"
        return $0
    }(UISearchBar())

    private lazy var filterView: FilterView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(FilterView())

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
        $0.rowHeight = columnHeight
        $0.backgroundColor = .clear
        $0.separatorInset = .zero
        $0.isScrollEnabled = false
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

    private let indicatorView: UIView = {
        $0.alpha = 0
        return $0
    }(UIView())

    private let columnHeight: CGFloat = 32
    private let lineHeight: CGFloat = 1
    private var viewerModel: StorageViewable
    private var isPrevPopGestureEnabled: Bool = true
    private var indicatorHideTimer: Timer?

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

        view.addSubview(topStackView)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollWidthView)
        scrollView.addSubview(columnTableView)
        scrollView.addSubview(lineView)
        scrollView.addSubview(tableView)
        tableView.addSubview(indicatorView)

        NSLayoutConstraint.activate([
            topStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topStackView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
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

        NSLayoutConstraint.activate([
            columnTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            columnTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            columnTableView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            columnTableView.heightAnchor.constraint(equalToConstant: columnHeight)
        ])

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

        scrollView.delegate = self
        searchBar.delegate = self
        filterView.updateTitle(viewerModel.filterList.first ?? "")
        viewerModel.filterType = viewerModel.filterList.first ?? ""
        filterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterTapped(_:))))
    }

    @objc private func filterTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else { return }
        searchBar.resignFirstResponder()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        viewerModel.filterList.forEach { filterType in
            alertController.addAction(.init(title: filterType, style: .default, handler: { [weak self] _ in
                self?.viewerModel.changeFilterType(filterType, completion: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                })
                self?.filterView.updateTitle(filterType)
            }))
        }
        present(alertController, animated: true)
    }

    private func showIndicator() {
        if indicatorView.alpha != 1 {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.indicatorView.alpha = 1
            }
        }
        indicatorHideTimer?.invalidate()
        indicatorHideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hideIndicator(_:)), userInfo: nil, repeats: false)
    }

    @objc private func hideIndicator(_ sender: Timer? = nil) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.indicatorView.alpha = 0
        }
        sender?.invalidate()
        indicatorHideTimer?.invalidate()
        indicatorHideTimer = nil
    }
}

extension StorageViewerViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewerModel.changeFilterText(searchBar.text ?? "", completion: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        })
        searchBar.resignFirstResponder()
    }
}

extension StorageViewerViewController: UITableViewDataSource, UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.subviews
            .filter { NSStringFromClass(type(of: $0)) == "_UIScrollViewScrollIndicator" }
            .filter { $0.frame.size.height > $0.frame.size.width }
            .first.map {
                indicatorView.backgroundColor = $0.subviews.first?.backgroundColor
                indicatorView.frame = .init(origin: .init(x: self.scrollView.contentOffset.x + self.scrollView.bounds.width - 6, y: $0.frame.origin.y), size: $0.frame.size)
                if self.scrollView.contentOffset.x + self.scrollView.bounds.width < self.scrollView.contentSize.width - 30 {
                    showIndicator()
                } else {
                    hideIndicator()
                }

            }

        if scrollView == tableView {
            let maxY = max(scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height, 0)
            if maxY <= scrollView.contentOffset.y {
                viewerModel.loadMore { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == columnTableView {
            return 1
        } else {
            return viewerModel.rowCount
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .default, identifier: StorageRowCell.identifier, { (cell: StorageRowCell) in
            cell.delegate = self
            if tableView == columnTableView {
                cell.bind(model: viewerModel.columnModel)
            } else {
                 guard viewerModel.rowModels.indices ~= indexPath.row, tableView.numberOfRows(inSection: 0) > indexPath.row else { return }
                cell.bind(model: viewerModel.rowModels[indexPath.row])
            }
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == columnTableView { return }
        viewerModel.toggleTap(index: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension StorageViewerViewController: StorageRowCellDelete {
    func storageRowColumnTap(_ sender: StorageRowCell, index: Int) {
        searchBar.resignFirstResponder()
        viewerModel.columnTap(index: index) { [weak self] in
            self?.tableView.reloadData()
        }
        columnTableView.reloadData()
    }
}
