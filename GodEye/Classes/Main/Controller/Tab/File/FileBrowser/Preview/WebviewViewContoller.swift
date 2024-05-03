//
//  WebviewViewContoller.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 16/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import WebKit

final class WebviewViewContoller: UIViewController {
    private let webView: WKWebView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(WKWebView())

    private let titleText: String
    private let htmlText: String
    private let shareItem: [Any]

    //MARK: Lifecycle

    init(title: String, html: String, shareItem: [Any] = []) {
        self.titleText = title
        self.htmlText = html
        self.shareItem = shareItem
        super.init(nibName: nil, bundle: nil)
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension WebviewViewContoller {
    private func setupViews() {
        view.clipsToBounds = true
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension WebviewViewContoller {
    @objc private func shareFile(_ sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: shareItem, applicationActivities: nil)

        if UIDevice.current.userInterfaceIdiom == .pad &&
            activityViewController.responds(to: #selector(getter: popoverPresentationController)) {
            activityViewController.popoverPresentationController?.barButtonItem = sender
        }

        present(activityViewController, animated: true, completion: nil)
    }
}

extension WebviewViewContoller {
    private func processForDisplay() {
        let bodyText = htmlText.convertSpecialCharacters
        let viewport = "<meta name='viewport' content='width=device-width, initial-scale=1'> "
        let style = "<style>p {margin: 0px; padding: 0px;} span {margin: 0px; padding: 0px;}</style> "
        let head = "<head>\(viewport)\(style)</head>"
        let bodyStyle = "'margin: 0px; padding: 0px; background-color: black; color: white;'"
        let body = "<body style=\(bodyStyle)>\(bodyText)</body>"
        let html = "<html>\(head)\(body)</html>"
        webView.loadHTMLString(html, baseURL: nil)
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
