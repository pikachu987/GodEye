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
    private var metas: String {
        let viewport = "<meta name='viewport' content='width=device-width, initial-scale=1'>"
        let metas = "\(viewport) "
        return metas
    }

    private var cssStyle: String {
        let cssBody = "body {margin: 0px; padding: 0px; background-color: black; color: white;}"
        let cssP = "p {margin: 0px; padding: 0px;}"
        let cssSpan = "span {margin: 0px; padding: 0px;}"
        let cssHighlight = ".highlight { background-color: \(UIColor.highlightBG.hexString()); color: \(UIColor.highlightFG.hexString())}"
        let style = "<style>\(cssBody) \(cssP) \(cssSpan) \(cssHighlight)</style> "
        return style
    }

    private var script: String {
        let removeHighlight = "document.body.innerHTML = document.body.innerHTML.replace(new RegExp('</?span[^>]*>', 'g'), '');"
        let insertHighlight = "document.body.innerHTML = document.body.innerHTML.replace(new RegExp(text, 'gi'), '<span class=\"highlight\">$&</span>');"
        let initialHighlight = (searchBar.text ?? "") == "" ? "" : "highlight('\(searchBar.text ?? "")');"
        let highlightScript = "function highlight(text) { \(removeHighlight) if(text != '') { \(insertHighlight) } }"
        let script = "<script>\(highlightScript) \(initialHighlight)</script>"
        return script
    }

    private func processForDisplay() {
        let content = htmlText.convertSpecialCharacters
        let head = "<head>\(metas)\(cssStyle)</head>"
        let body = "<body>\(content)\(script)</body>"
        let html = "<html>\(head)\(body)</html>"
        webView.loadHTMLString(html, baseURL: nil)
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
}
