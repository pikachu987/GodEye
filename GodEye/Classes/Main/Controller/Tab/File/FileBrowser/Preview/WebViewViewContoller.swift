//
//  WebViewViewContoller.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 16/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import WebKit

final class WebViewViewContoller: UIViewController {
    private lazy var searchBar: UISearchBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.searchBarStyle = .minimal
        $0.backgroundColor = .niceBlack
        $0.returnKeyType = .done
        $0.enablesReturnKeyAutomatically = false
        $0.placeholder = "Search Text"
        return $0
    }(UISearchBar())
    
    private let webView: WKWebView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(WKWebView())

    private let titleText: String
    private let htmlText: String
    private let shareItem: [Any]
    private var isPrevPopGestureEnabled: Bool = true

    //MARK: Lifecycle

    init(title: String, html: String, searchText: String = "", shareItem: [Any] = []) {
        self.titleText = title
        self.htmlText = html
        self.shareItem = shareItem
        super.init(nibName: nil, bundle: nil)
        searchBar.text = searchText
        isPrevPopGestureEnabled = navigationController?.interactivePopGestureRecognizer?.isEnabled ?? true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.clipsToBounds = true
        view.backgroundColor = .niceBlack
        setupViews()
        processForDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = titleText
        navigationItem.rightBarButtonItem = shareItem.isEmpty ? nil : UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareFile(_:)))
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = isPrevPopGestureEnabled
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


        webView.evaluateJavaScript("updateWidth();")
    }
}

extension WebViewViewContoller {
    private func setupViews() {
        view.clipsToBounds = true

        view.addSubview(searchBar)
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        searchBar.delegate = self
    }
}

extension WebViewViewContoller {
    @objc private func shareFile(_ sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: shareItem, applicationActivities: nil)

        if UIDevice.current.userInterfaceIdiom == .pad &&
            activityViewController.responds(to: #selector(getter: popoverPresentationController)) {
            activityViewController.popoverPresentationController?.barButtonItem = sender
        }

        present(activityViewController, animated: true, completion: nil)
    }
}

extension WebViewViewContoller {
    private var viewportContent: String {
        "\"width=device-width, initial-scale=1.0, minimum-scale=0.1, maximum-scale=10.0, user-scalable=yes\""
    }

    private var metas: String {
        let viewport = "<meta name=\"viewport\" content=\(viewportContent)>"
        return "\n\(viewport)\n"
    }

    private var cssStyleContent: String {
        let cssBody = "body {margin: 0px; padding: 0px; background-color: #000000; color: #ffffff;}\n"
        let cssP = "p {margin: 0px; padding: 0px;}\n"
        let cssSpan = "span {margin: 0px; padding: 0px;}\n"
        let cssHighlight = ".highlight { background-color: #\(UIColor.highlightBG.hexString()); color: #\(UIColor.highlightFG.hexString());}\n"
        let cssPre = "pre {display: inline; overflow: auto; white-space: pre-line; white-space: -moz-pre-line; white-space: -o-pre-line; white-space: -ms-pre-line;}\n"
        return "\(cssBody)\(cssP)\(cssSpan)\(cssHighlight)\(cssPre)"
    }

    private var cssStyle: String {
        "<style type=\"text/css\">\(cssStyleContent)</style>\n"
    }

    private var script: String {
        let removeHighlight = "\ndocument.body.innerHTML = document.body.innerHTML.replace(new RegExp(\"</?span class=\\\"highlight\\\"[^>]*>\", \"g\"), \"\");\n"
        let insertHighlight = "\ndocument.body.innerHTML = document.body.innerHTML.replace(new RegExp(text, \"gi\"), \"<span class=\\\"highlight\\\">$&</span>\");\n"
        let highlightScript = "\nfunction highlight(text) {\(removeHighlight)if(text != '') {\(insertHighlight)}\n}\n"
        let initialHighlight = (searchBar.text ?? "") == "" ? "" : "\nhighlight(\"\(searchBar.text ?? "")\");\n"
        let viewPortScript = "\nfunction updateWidth() {\nviewport = document.querySelector(\"meta[name=viewport]\");\nviewport.setAttribute(\"content\", \(viewportContent));\n}\nupdateWidth();\n"
        let script = "\n<script>\(highlightScript)\(viewPortScript)\(initialHighlight)\n</script>\n"
        return script
    }

    private func processForDisplay() {
        let content = htmlText.convertSpecialCharacters
        if htmlText.hasPrefix("<!DOCTYPE") || htmlText.hasPrefix("<html") {
            var html = htmlText

            if let index = html.index(of: "<style") {
                html.insert(contentsOf: metas, at: index)
            } else if let index = html.index(of: "</head") {
                html.insert(contentsOf: metas, at: index)
            }
            if let index = html.index(of: "</style") {
                html.insert(contentsOf: cssStyleContent, at: index)
            } else if let index = html.index(of: "</head") {
                html.insert(contentsOf: cssStyle, at: index)
            }
            if let index = html.index(of: "<body") {
                html.insert(contentsOf: "\n<pre>\n", at: html.index(index, offsetBy: 6))
            }
            if let index = html.index(of: "</body") {
                html.insert(contentsOf: "\n</pre>\n", at: index)
            }
            if let index = html.index(of: "</body") {
                html.insert(contentsOf: script, at: index)
            }

            let preComponents = html.components(separatedBy: "<pre>")
            let preBefore = preComponents.first ?? ""
            let preCloseComponents = (preComponents.last ?? "").components(separatedBy: "</pre>")
            let preContent = (preCloseComponents.first ?? "").replacingOccurrences(of: "\r\n", with: "").replacingOccurrences(of: "\n", with: "")
            let preAfter = preCloseComponents.last ?? ""

            let result = "\(preBefore)<pre>\(preContent)</pre>\(preAfter)"
            webView.loadHTMLString(html, baseURL: nil)
        } else {
            let head = "<head>\(metas)\(cssStyle)</head>"
            let body = "<body>\(content)\(script)</body>"
            let html = "<html>\(head)\(body)</html>"
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}

extension WebViewViewContoller: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        webView.evaluateJavaScript("highlight('\(text)');")
        searchBar.resignFirstResponder()
    }
}

extension String {
    // Make sure we convert HTML special characters
    // Code from https://gist.github.com/mikesteele/70ae98d04fdc35cb1d5f
    fileprivate var convertSpecialCharacters: String {
        var newString = self
        let char_dictionary = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'"
        ]
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: .regularExpression, range: nil)
        }
        return newString.replacingOccurrences(of: "\\/", with: "/")
    }

    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }

    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }

    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }

    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = startIndex
        while startIndex < endIndex, let range = self[startIndex...].range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound
            ? range.upperBound
            : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
