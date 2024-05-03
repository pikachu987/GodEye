//
//  PreviewTransitionViewController.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 16/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit


/// Preview Transition View Controller was created because of a bug in QLPreviewController. It seems that QLPreviewController has issues being presented from a 3D touch peek-pop gesture and is produced an unbalanced presentation warning. By wrapping it in a container, we are solving this issue.
final class PreviewTransitionViewController: UIViewController {
    lazy var previewController = FBFilePreviewController(filePath: filePath)

    private lazy var containerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private let file: FBFile

    private var filePath: URL {
        file.filePath
    }

    init(file: FBFile) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        view.clipsToBounds = true
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        addChild(previewController)
        containerView.addSubview(previewController.view)
        previewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            previewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            previewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            previewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        previewController.didMove(toParent: self)
    }
}
