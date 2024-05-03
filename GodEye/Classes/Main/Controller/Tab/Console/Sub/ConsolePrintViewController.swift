//
//  ConsolePrintViewController.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import UIKit

final class ConsolePrintViewController: UIViewController {
    private lazy var stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        return $0
    }(UIStackView(arrangedSubviews: [recordTableView, inputField, keyboardView]))

    private lazy var recordTableView: RecordTableView = {
        $0.delegate = dataSource
        $0.dataSource = dataSource
        $0.isAutoFirstScrollBottom = true
        return $0
    }(RecordTableView())

    private lazy var inputField: UITextField = {
        $0.borderStyle = .roundedRect
        $0.font = UIFont.courier(with: 12)
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
        self.dataSource = RecordTableViewDataSource(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bind()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        guard view.superview != nil else { return }
        recordTableView.smoothReloadData(need: false)
    }
}

extension ConsolePrintViewController {
    private func setupViews() {
        view.backgroundColor = .niceBlack
        view.clipsToBounds = true
        
        view.addSubview(stackView)
        recordTableView.refreshControl = UIRefreshControl()
        recordTableView.refreshControl?.addTarget(self, action: #selector(refreshed(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            inputField.heightAnchor.constraint(equalToConstant: 34)
        ])

        keyboardHeightConstraint = keyboardView.heightAnchor.constraint(equalToConstant: 0)
        keyboardHeightConstraint?.isActive = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        recordTableView.reloadData()
    }

    private func bind() {
        dataSource.shareText = { [weak self] indexPath in
            guard let self = self, let recordData = self.dataSource.recordData else { return }
            guard recordData.indices ~= indexPath.row else { return }
            let text = recordData[indexPath.row].attributeString(type: .detail).string
            self.share(text: text)
        }

        dataSource.isDidScrollHandler = { [weak self] in
            self?.recordTableView.didScroll($0)
        }

        dataSource.didUserInteracter = { [weak self] in
            self?.recordTableView.didUserInteraction()
        }

        dataSource.didTap = { [weak self] cell in
            guard let self = self else { return }
            guard let indexPath = self.recordTableView.indexPath(for: cell), let recordData = self.dataSource.recordData, recordData.indices ~= indexPath.row else { return }
            guard let html = recordData[indexPath.row].attributeString(type: .detail).toHTML else { return }
            let viewController = WebviewViewContoller(title: "Console", html: html, shareItem: [html])
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        dataSource.didPreview = { [weak self] model in
            guard let self = self else { return }
            guard let html = model.attributeString(type: .detail).toHTML else { return }
            let viewController = WebviewViewContoller(title: "Console", html: html, shareItem: [html])
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        dataSource.previewProvider = { [weak self] model in
            let html = model.attributeString(type: .detail).toHTML ?? ""
            return WebviewViewContoller(title: "Console", html: html, shareItem: [html])
        }

        dataSource.didMoreTap = { [weak self] cell in
            guard let self = self else { return }
            guard let indexPath = self.recordTableView.indexPath(for: cell), let recordData = self.dataSource.recordData, recordData.indices ~= indexPath.row else { return }
            let model = recordData[indexPath.row]
            model.isAllShow = !model.isAllShow
            self.recordTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ConsolePrintViewController {
    private func share(text: String) {
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activity.popoverPresentationController {
            popover.sourceView = view
            popover.permittedArrowDirections = .up
        }
        present(activity, animated: true, completion: nil)
    }

    @objc private func handleSharedButtonTap() {
        recordTableView.didUserInteraction()
        let text = dataSource.recordData.map {
            $0.map { $0.attributeString(type: .detail).string }.joined(separator: "\n")
        }
        text.map {
            share(text: $0)
        }
    }

    @objc private func handleDeleteButtonTap() {
        recordTableView.didUserInteraction()
        type.model()?.delete(complete: { [weak self] _ in
            self?.dataSource.cleanRecord()
            self?.recordTableView.reloadData()
        })
    }

    @objc private func refreshed(_ sender: UIRefreshControl) {
        recordTableView.didUserInteraction()
        let result = dataSource.loadPrePage()
        if result {
            recordTableView.reloadData()
        }
        sender.endRefreshing()
    }
}

extension ConsolePrintViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else { return }

        GodEyeTabBarController.shared
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
        guard let userInfo = notification.userInfo else { return }
        guard let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        keyboardHeightConstraint?.constant = frame.height - (tabBarController?.tabBar.bounds.height ?? view.safeAreaInsets.bottom) ?? 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return}
        keyboardHeightConstraint?.constant = 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}
