//
//  ConsolePrintViewController.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import UIKit

final class ConsolePrintViewController: UIViewController {
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private lazy var searchBar: UISearchBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.searchBarStyle = .minimal
        $0.backgroundColor = .niceBlack
        $0.returnKeyType = .done
        $0.enablesReturnKeyAutomatically = false
        $0.placeholder = "Search Text"
        return $0
    }(UISearchBar())

    private lazy var stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = 6
        return $0
    }(UIStackView(arrangedSubviews: [topStackView, recordTableView, inputField, keyboardView]))

    private lazy var topStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        return $0
    }(UIStackView(arrangedSubviews: [searchContainerView, filterView]))

    private lazy var filterView: FilterView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(FilterView())

    private lazy var searchContainerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var recordTableView: RecordTableView = {
        $0.delegate = dataSource
        $0.dataSource = dataSource
        return $0
    }(RecordTableView())

    private lazy var inputField: UITextField = {
        $0.borderStyle = .roundedRect
        $0.font = .courier(with: 12)
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.returnKeyType = .done
        $0.enablesReturnKeyAutomatically = false
        $0.clearButtonMode = .whileEditing
        $0.contentVerticalAlignment = .center
        $0.placeholder = "Enter command..."
        $0.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        $0.isHidden = type != .command
        $0.delegate = self
        return $0
    }(UITextField(frame: .zero))

    private lazy var keyboardView = UIView()

    private var keyboardHeightConstraint: NSLayoutConstraint?

    private let dataSource: RecordTableViewDataSource
    private let type: RecordType

    init(type: RecordType) {
        self.type = type
        self.dataSource = RecordTableViewDataSource(type: type, filterType: type.filterTypes.first ?? .init(title: "", value: nil))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = type.title
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .trash,
                                                              target: self,
                                                              action: #selector(handleDeleteButtonTap)),
                                              UIBarButtonItem(barButtonSystemItem: .action,
                                                              target: self,
                                                              action: #selector(handleSharedButtonTap))]
    }
}

extension ConsolePrintViewController {
    func addRecord(model: RecordORMProtocol) {
        dataSource.addRecord(model: model)
    }
}

extension ConsolePrintViewController {
    private func setupViews() {
        view.backgroundColor = .niceBlack
        view.clipsToBounds = true
        
        view.addSubview(stackView)
        searchContainerView.addSubview(searchBar)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor)
        ])

        inputField.heightAnchor.constraint(equalToConstant: 34).isActive = true

        keyboardHeightConstraint = keyboardView.heightAnchor.constraint(equalToConstant: 0)
        keyboardHeightConstraint?.isActive = true

        dataSource.delegate = self
        searchBar.delegate = self

        filterView.updateTitle(type.filterTypes.first?.title ?? "")

        filterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterTapped(_:))))

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}

extension ConsolePrintViewController {
    private func share(text: String) {
        searchBar.resignFirstResponder()
        inputField.resignFirstResponder()
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activity.popoverPresentationController {
            popover.sourceView = view
            popover.permittedArrowDirections = .up
        }
        present(activity, animated: true, completion: nil)
    }

    @objc private func handleSharedButtonTap() {
        searchBar.resignFirstResponder()
        inputField.resignFirstResponder()
        recordTableView.didUserInteraction()
        let text = dataSource.recordData.map { $0.attributeString(type: .detail).string }.joined(separator: "\n")
        share(text: text)
    }

    @objc private func handleDeleteButtonTap() {
        searchBar.resignFirstResponder()
        inputField.resignFirstResponder()
        recordTableView.didUserInteraction()
        type.model()?.delete(complete: { [weak self] _ in
            self?.dataSource.cleanRecord()
        })
    }

    @objc private func filterTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else { return }
        searchBar.resignFirstResponder()
        inputField.resignFirstResponder()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        type.filterTypes.forEach { filterType in
            alertController.addAction(.init(title: filterType.title, style: .default, handler: { [weak self] _ in
                self?.dataSource.changeFilterType(filterType)
                self?.filterView.updateTitle(filterType.title)
            }))
        }
        present(alertController, animated: true)
    }
}

extension ConsolePrintViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else { return }

        GodEye
            .configuration?
            .command
            .execute(command: text) { [weak self] model in
                model.insert(complete: { [weak self] _ in
                    self?.addRecord(model: model)
                })
        }
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        true
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: NSNotification) {
        guard inputField.isFirstResponder else { return }
        guard let userInfo = notification.userInfo else { return }
        guard let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        keyboardHeightConstraint?.constant = frame.height - (tabBarController?.tabBar.bounds.height ?? view.safeAreaInsets.bottom) ?? 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: NSNotification) {
        guard inputField.isFirstResponder else { return }
        guard let userInfo = notification.userInfo else { return }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return}
        keyboardHeightConstraint?.constant = 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

extension ConsolePrintViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dataSource.changeFilterText(searchBar.text)
        searchBar.resignFirstResponder()
    }
}

extension ConsolePrintViewController: RecordTableViewDelegate {
    func recordTableViewReload(_ sender: RecordTableViewDataSource) {
        recordTableView.reloadData()
    }

    func recordTableViewDidUserInteracter(_ sender: RecordTableViewDataSource) {
        recordTableView.didUserInteraction()
    }

    func recordTableViewAutoBottomScrollIfNeeded(_ sender: RecordTableViewDataSource, isAuto: Bool) {
        recordTableView.autoScrollBottomIfNeeded(isAuto: isAuto)
    }

    func recordTableViewDidScroll(_ sender: RecordTableViewDataSource) {
        guard !dataSource.isRequesting else { return }
        if recordTableView.isScrollToTop {
            dataSource.loadPrePage { [weak self] index in
                self?.recordTableView.scrollToRow(at: .init(row: index, section: 0), at: .top, animated: false)
            }
        }
    }

    func recordTableViewScrollToBottom(_ sender: RecordTableViewDataSource) {
        DispatchQueue.main.async { [weak self] in
            self?.recordTableView.refreshAutoFirstScrollBottom()
        }
    }

    func recordTableView(_ sender: RecordTableViewDataSource, share indexPath: IndexPath) {
        let recordData = dataSource.recordData
        guard recordData.indices ~= indexPath.row else { return }
        let text = recordData[indexPath.row].attributeString(type: .detail).string
        share(text: text)
    }

    func recordTableView(_ sender: RecordTableViewDataSource, didShowMoreCell cell: RecordTableViewCell) {
        guard let indexPath = recordTableView.indexPath(for: cell) else { return }
        let recordData = dataSource.recordData
        guard recordData.indices ~= indexPath.row else { return }
        let model = recordData[indexPath.row]
        model.isAllShow = !model.isAllShow
        recordTableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func recordTableView(_ sender: RecordTableViewDataSource, selectCell cell: RecordTableViewCell) {
        guard let indexPath = recordTableView.indexPath(for: cell) else { return }
        let recordData = dataSource.recordData
        guard recordData.indices ~= indexPath.row else { return }
        guard let html = recordData[indexPath.row].attributeString(type: .detail).toHTML else { return }
        let viewController = WebViewViewContoller(title: "Console", html: html, searchText: dataSource.filterText, shareItem: [html])
        navigationController?.pushViewController(viewController, animated: true)
    }

    func recordTableView(_ sender: RecordTableViewDataSource, preview model: RecordORMProtocol) {
        guard let html = model.attributeString(type: .detail).toHTML else { return }
        let viewController = WebViewViewContoller(title: "Console", html: html, searchText: dataSource.filterText, shareItem: [html])
        navigationController?.pushViewController(viewController, animated: true)
    }

    func recordTableView(_ sender: RecordTableViewDataSource, previewProvider model: RecordORMProtocol) -> UIViewController {
        let html = model.attributeString(type: .detail).toHTML ?? ""
        return WebViewViewContoller(title: "Console", html: html, searchText: dataSource.filterText, shareItem: [html])
    }
}
