//
//  RecordTableView.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

final class RecordTableView: UITableView {

    var isScrollToTop: Bool {
        contentOffset.y <= 0
    }

    var isScrollToBootom: Bool {
        contentOffset.y >= contentSize.height + contentInset.bottom - bounds.size.height
    }

    private var isAutoScrollBottom = true
    private var isUserInteraction = false
    private var dummyContentSize = CGSize.zero

    override var contentSize: CGSize {
        didSet {
            changeContentSize()
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
}

extension RecordTableView {
    func didUserInteraction() {
        isUserInteraction = true
    }

    func refreshAutoFirstScrollBottom() {
        isUserInteraction = false
        scrollToBottom()
    }

    func autoScrollBottomIfNeeded(isAuto: Bool) {
        if isAuto {
            if isScrollToBootom {
                isAutoScrollBottom = true
            }
        } else {
            isAutoScrollBottom = false
        }
    }
}

extension RecordTableView {
    private func scrollToBottom() {
        let point = CGPoint(x: contentOffset.x, y: max(contentSize.height + contentInset.bottom - bounds.size.height, 0))
        DispatchQueue.main.async { [weak self] in
            self?.setContentOffset(point, animated: false)
        }
    }

    private func changeContentSize() {
        guard dummyContentSize != contentSize else { return }
        dummyContentSize = contentSize
        if !isUserInteraction {
            scrollToBottom()
        } else if isAutoScrollBottom {
            scrollToBottom()
        }
    }
}
