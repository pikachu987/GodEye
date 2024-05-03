//
//  RecordTableView.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

final class RecordTableView: UITableView {
    private var timer: Timer?
    private var needScrollToBottom = false

    private var isUserInteraction = false
    private var dummyContentSize = CGSize.zero

    var isAutoFirstScrollBottom = false

    override var contentSize: CGSize {
        didSet {
            guard dummyContentSize != contentSize, !isUserInteraction, isAutoFirstScrollBottom else { return }
            dummyContentSize = contentSize
            scrollToBottom(animated: false)
        }
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        separatorStyle = .none
        backgroundColor = .niceBlack
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        super.reloadData()
        
        if needScrollToBottom {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToBottom(animated: true)
            }
        }
    }

    func didScroll(_ isDidScroll: Bool) {
        if isDidScroll {
            isUserInteraction = true
        }
    }

    func didUserInteraction() {
        isUserInteraction = true
    }

    func smoothReloadData(need scrollToBottom: Bool, timeInterval: TimeInterval = 0.5) {
        timer?.invalidate()
        timer = nil
        needScrollToBottom = false

        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                          target: self,
                                          selector: #selector(reloadData),
                                          userInfo: nil,
                                          repeats: false)
    }

    func scrollToBottom(animated: Bool) {
        let point = CGPoint(x: 0, y: max(contentSize.height + contentInset.bottom - bounds.size.height, 0))
        setContentOffset(point, animated: animated)
    }
}

final class RecordTableViewDataSource: NSObject {
    private let maxLogItems: Int = 1000

    fileprivate let type: RecordType
    fileprivate(set) var recordData: [RecordORMProtocol]?

    private var logIndex: Int = 0

    var shareText: ((IndexPath) -> Void)?

    var didUserInteracter: (() -> Void)?
    var isDidScrollHandler: ((Bool) -> Void)?
    var didMoreTap: ((RecordTableViewCell) -> Void)?
    var didTap: ((RecordTableViewCell) -> Void)?
    var didPreview: ((RecordORMProtocol) -> Void)?
    var previewProvider: ((RecordORMProtocol) -> UIViewController)?

    private var scrollTimer: Timer?
    private var isDidScrollDummy: Bool = false
    private var isDidScroll: Bool = false {
        didSet {
            guard isDidScrollDummy != isDidScroll else { return }
            isDidScrollDummy = isDidScroll
            scrollTimer?.invalidate()
            scrollTimer = nil
            if !isDidScrollDummy {
                scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [weak self] _ in
                    guard let self = self else { return }
                    self.scrollTimer?.invalidate()
                    self.scrollTimer = nil
                    self.isDidScrollHandler?(self.isDidScroll)
                })
            }
        }
    }

    init(type: RecordType) {
        self.type = type
        super.init()

        recordData = currentPageModel()
        type.model()?.addCount = 0
    }
    
    private func currentPageModel() -> [RecordORMProtocol]? {
        switch type {
        case .log: return LogRecordModel.select(at: logIndex)
        case .crash: return CrashRecordModel.select(at: logIndex)
        case .network: return NetworkRecordModel.select(at: logIndex)
        case .anr: return ANRRecordModel.select(at: logIndex)
        case .leak: return LeakRecordModel.select(at: logIndex)
        case .command: return CommandRecordModel.select(at: logIndex)
        }
    }
    
    private func addCount() {
        type.model()?.addCount += 1
    }
    
    func loadPrePage() -> Bool {
        logIndex += 1
        
        guard let models = currentPageModel() else { return false }
        guard models.count != 0 else { return false }

        for model in models.reversed() {
            recordData?.insert(model, at: 0)
        }
        return true
    }
    
    func addRecord(model:RecordORMProtocol) {
        if recordData?.count != 0 &&
            Swift.type(of: model).type != type {
            return
        }
        
        recordData?.append(model)
        if let recordData = recordData, recordData.count > maxLogItems {
            self.recordData?.remove(at: 0)
        }
        addCount()
    }
    
    func cleanRecord() {
        recordData?.removeAll()
    }
}

extension RecordTableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        didUserInteracter?()
        return true
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !isDidScroll {
            isDidScrollHandler?(true)
        }
        isDidScroll = true
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isDidScroll = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDidScroll = false
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDidScroll = false
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let recordData = recordData, recordData.indices ~= indexPath.row else { return false }
        return shareText != nil
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let recordData = recordData, recordData.indices ~= indexPath.row else { return nil }
        let share = UIContextualAction(style: .normal, title: "Share") { [weak self] (action, sourceView, completionHandler) in
            completionHandler(true)
            guard let self = self else { return }
            self.shareText?(indexPath)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [share])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recordData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell({ (cell: RecordTableViewCell) in })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let recordData = recordData, recordData.indices ~= indexPath.row else { return }
        let model = recordData[indexPath.row]
        let cell = cell as? RecordTableViewCell
        let attributeString = model.attributeString(type: .preview)
        cell?.bind(attributeString)
        cell?.delegate = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let recordData = recordData, recordData.indices ~= indexPath.row, let tableView = tableView as? RecordTableView else { return 0 }
        let width = tableView.bounds.size.width - 10
        let model = recordData[indexPath.row]
        let attributeString = model.attributeString(type: .preview)
        return RecordTableViewCell.boundingHeight(with: width, attributedText: attributeString)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if type == .network || type == .anr {
            return indexPath
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let recordData = recordData, recordData.indices ~= indexPath.row else { return nil }
        let model = recordData[indexPath.row]
        guard model.isPreview else { return nil }
        let previewProvider: (() -> UIViewController?) = { [weak self] in
            self?.didUserInteracter?()
            return self?.previewProvider?(model)
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { suggestedActions in
            let inspectAction = UIAction(title: NSLocalizedString("View", comment: ""), image: nil) { [weak self] action in
                self?.didUserInteracter?()
                self?.didPreview?(model)
            }
            return UIMenu(title: "", children: [inspectAction])
        }
    }
}

extension RecordTableViewDataSource: RecordTableViewCellDelete {
    func recordTableViewCellTapped(_ sender: RecordTableViewCell) {
        didUserInteracter?()
        didTap?(sender)
    }

    func recordTableViewCellMoreTapped(_ sender: RecordTableViewCell) {
        didUserInteracter?()
        didMoreTap?(sender)
    }
}
