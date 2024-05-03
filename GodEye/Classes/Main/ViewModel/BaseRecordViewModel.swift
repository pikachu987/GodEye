//
//  BaseRecordViewModel.swift
//  Pods
//
//  Created by zixun on 16/12/29.
//
//

import Foundation

class BaseRecordViewModel<T: RecordORMProtocol>: NSObject {
    let model: T

    init(model: T) {
        self.model = model
    }

    func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        .init()
    }

    func headerString(with type: RecordORMAttributedType, prefix: String, content: String? = nil, color: UIColor) -> NSAttributedString {
        let header = "> \(prefix): \(content ?? "")\n"
        let result = NSMutableAttributedString(string: header, attributes: tapAttributes(with: type, fontSize: type.headerFontSize))
        let range = header.NS.range(of: prefix)
        if range.location + range.length <= header.NS.length {
            result.addAttributes([.foregroundColor: color], range: range)
        }
        return result
    }

    func contentString(with type: RecordORMAttributedType, prefix: String?, content: String?, newline:Bool = false, color: UIColor = UIColor(hex: 0x3D82C7)) -> NSAttributedString {
        let pre = prefix.map { "[\($0)]:" } ?? ""
        let line = newline == true ? "\n" : (pre == "" ? "" : " ")
        let str = "\(pre)\(line)\(content ?? "nil")\n"
        let result = NSMutableAttributedString(string: str, attributes: tapAttributes(with: type, fontSize: type.contentFontSize))
        let range = str.NS.range(of: pre)
        if range.location != NSNotFound {
            result.addAttribute(.foregroundColor, value: color, range: range)
        }
        return result
    }

    func moreLinkString(with prefix: String) -> NSAttributedString {
        let pre = "[\(prefix)]:"
        let str = "\(pre)\n"
        let result = NSMutableAttributedString(string: str, attributes: moreTapAttributes())
        return result
    }

    func tapAttributes(with type: RecordORMAttributedType, fontSize: CGFloat, color: UIColor = .white) -> [NSAttributedString.Key: Any] {
        attributes(with: type, fontSize: fontSize, color: color, link: .tap)
    }

    func moreTapAttributes() -> [NSAttributedString.Key: Any] {
        attributes(with: .preview, fontSize: 15, color: .cyan, link: .moreTap)
    }

    func attributes(with type: RecordORMAttributedType, fontSize: CGFloat = 12, color: UIColor = .white, link: LinkType? = nil) -> [NSAttributedString.Key: Any] {
        if let link = link?.link, type.isLink {
            return [.link: link,
             .foregroundColor: color,
             .font: UIFont.courier(with: fontSize)]
        }
        return [.foregroundColor: color, .font: UIFont.courier(with: fontSize)]
    }
}

extension BaseRecordViewModel {
    enum LinkType {
        case tap
        case moreTap

        var link: URL? {
            let linkStr: String = {
                switch $0 {
                case .tap: return "tap"
                case .moreTap: return "moreTap"
                }
            }(self)
            return .init(string: linkStr)
        }
    }
}

enum RecordORMAttributedType {
    case preview
    case detail

    var isLink: Bool {
        self == .preview
    }

    var headerFontSize: CGFloat {
        switch self {
        case .preview: return 12
        case .detail: return 19
        }
    }

    var contentFontSize: CGFloat {
        switch self {
        case .preview: return 12
        case .detail: return 17
        }
    }

    var contentDetailFontSize: CGFloat {
        switch self {
        case .preview: return 6
        case .detail: return 13
        }
    }
}

