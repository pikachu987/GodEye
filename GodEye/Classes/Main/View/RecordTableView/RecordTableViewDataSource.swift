//
//  RecordTableView.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

protocol RecordTableViewDelegate: AnyObject {
    func recordTableViewReload(_ sender: RecordTableViewDataSource)
    func recordTableViewDidUserInteracter(_ sender: RecordTableViewDataSource)
    func recordTableViewAutoBottomScrollIfNeeded(_ sender: RecordTableViewDataSource, isAuto: Bool)
    func recordTableViewDidScroll(_ sender: RecordTableViewDataSource)
    func recordTableViewScrollToBottom(_ sender: RecordTableViewDataSource)
    func recordTableView(_ sender: RecordTableViewDataSource, share indexPath: IndexPath)
    func recordTableView(_ sender: RecordTableViewDataSource, didShowMoreCell cell: RecordTableViewCell)
    func recordTableView(_ sender: RecordTableViewDataSource, selectCell cell: RecordTableViewCell)
    func recordTableView(_ sender: RecordTableViewDataSource, preview model: RecordORMProtocol)
    func recordTableView(_ sender: RecordTableViewDataSource, previewProvider model: RecordORMProtocol) -> UIViewController
}

final class RecordTableViewDataSource: NSObject {
    private(set) var recordData: [RecordORMProtocol] = [] {
        didSet {
            delegate?.recordTableViewReload(self)
        }
    }

    weak var delegate: RecordTableViewDelegate?

    private let type: RecordType
    private let maxLogItems: Int = 1000
    private var logIndex: Int = 0
    private(set) var filterType: RecordORMFilterType
    private(set) var filterText = ""
    private(set) var isRequesting = false
    private(set) var noMoreData: Bool = false

    private var scrollTimer: Timer?
    private var isScrollDummy: Bool = false
    private var isScroll: Bool = false {
        didSet {
            guard isScrollDummy != isScroll else { return }
            isScrollDummy = isScroll
            scrollTimer?.invalidate()
            scrollTimer = nil
            if !isScroll {
                scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [weak self] _ in
                    guard let self = self else { return }
                    self.scrollTimer?.invalidate()
                    self.scrollTimer = nil
                    self.delegate?.recordTableViewAutoBottomScrollIfNeeded(self, isAuto: true)
                })
            } else {
                delegate?.recordTableViewAutoBottomScrollIfNeeded(self, isAuto: false)
            }
        }
    }

    init(type: RecordType, filterType: RecordORMFilterType) {
        self.type = type
        self.filterType = filterType
        super.init()

        refresh()
    }
}

extension RecordTableViewDataSource {
    func changeFilterText(_ filterText: String?) {
        self.filterText = filterText ?? ""
        refresh()
    }

    func changeFilterType(_ filterType: RecordORMFilterType) {
        self.filterType = filterType
        refresh()
    }

    func refresh() {
        guard !isRequesting else { return }
        isRequesting = true
        logIndex = 0
        noMoreData = false
        type.model()?.addCount = 0
        recordData = currentPageModel
        delegate?.recordTableViewScrollToBottom(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isRequesting = false
        }
    }

    func loadPrePage(_ callback: ((Int) -> Void)? = nil) {
        guard !isRequesting || !noMoreData else { return }
        isRequesting = true
        logIndex += 1
        let models = currentPageModel
        guard !models.isEmpty else { 
            noMoreData = true
            isRequesting = false
            return
        }
        recordData.insert(contentsOf: models, at: 0)
        callback?(models.count)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isRequesting = false
        }
    }

    func addRecord(model: RecordORMProtocol) {
        if recordData.count != 0 && Swift.type(of: model).type != type { return }

        recordData.append(model)
        if recordData.count > maxLogItems {
            recordData.remove(at: 0)
        }
        addCount()
    }

    func cleanRecord() {
        recordData.removeAll()
    }
}

extension RecordTableViewDataSource {
    private var currentPageModel: [RecordORMProtocol] {
        switch type {
        case .log: return LogRecordModel.select(at: logIndex, filterType: filterType, filterText: filterText) ?? []
        case .crash: return CrashRecordModel.select(at: logIndex, filterType: filterType, filterText: filterText) ?? []
        case .network: return NetworkRecordModel.select(at: logIndex, filterType: filterType, filterText: filterText) ?? []
        case .anr: return ANRRecordModel.select(at: logIndex, filterType: filterType, filterText: filterText) ?? []
        case .leak: return LeakRecordModel.select(at: logIndex, filterType: filterType, filterText: filterText) ?? []
        case .command: return CommandRecordModel.select(at: logIndex, filterType: filterType, filterText: filterText) ?? []
        }
    }

    private func addCount() {
        type.model()?.addCount += 1
    }
}

extension RecordTableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        delegate?.recordTableViewDidUserInteracter(self)
        return true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.recordTableViewDidScroll(self)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.recordTableViewDidUserInteracter(self)
        isScroll = true
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isScroll = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScroll = false
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScroll = false
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard recordData.indices ~= indexPath.row else { return false }
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard recordData.indices ~= indexPath.row else { return nil }
        let share = UIContextualAction(style: .normal, title: "Share") { [weak self] (action, sourceView, completionHandler) in
            completionHandler(true)
            guard let self = self else { return }
            self.delegate?.recordTableView(self, share: indexPath)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [share])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recordData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell({ (cell: RecordTableViewCell) in })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard recordData.indices ~= indexPath.row else { return }
        let model = recordData[indexPath.row]
        let cell = cell as? RecordTableViewCell
        let attributeString = model.attributeString(type: .preview, filterType: filterType, filterText: filterText)
        cell?.bind(attributeString)
        cell?.delegate = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard recordData.indices ~= indexPath.row, let tableView = tableView as? RecordTableView else { return 0 }
        let width = tableView.bounds.size.width - 10
        let model = recordData[indexPath.row]
        let attributeString = model.attributeString(type: .preview, filterType: filterType, filterText: filterText)
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
        guard recordData.indices ~= indexPath.row else { return nil }
        let model = recordData[indexPath.row]
        guard model.isPreview else { return nil }
        let previewProvider: (() -> UIViewController?) = { [weak self] in
            guard let self = self else { return nil }
            self.delegate?.recordTableViewDidUserInteracter(self)
            return self.delegate?.recordTableView(self, previewProvider: model)
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { suggestedActions in
            let inspectAction = UIAction(title: NSLocalizedString("View", comment: ""), image: nil) { [weak self] action in
                guard let self = self else { return }
                self.delegate?.recordTableViewDidUserInteracter(self)
                self.delegate?.recordTableView(self, preview: model)
            }
            return UIMenu(title: "", children: [inspectAction])
        }
    }
}

extension RecordTableViewDataSource: RecordTableViewCellDelete {
    func recordTableViewCellTapped(_ sender: RecordTableViewCell) {
        delegate?.recordTableViewDidUserInteracter(self)
        delegate?.recordTableView(self, selectCell: sender)
    }

    func recordTableViewCellMoreTapped(_ sender: RecordTableViewCell) {
        delegate?.recordTableViewDidUserInteracter(self)
        delegate?.recordTableView(self, didShowMoreCell: sender)
    }
}
