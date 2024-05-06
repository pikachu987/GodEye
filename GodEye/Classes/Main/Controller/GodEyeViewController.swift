//
//  GodEyeViewController.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import UIKit

final class GodEyeViewController: UIViewController {
    private var godWindow: UIWindow?

    private enum Constant {
        static let viewWidth: CGFloat = 46
        static let lineHeight: CGFloat = 44
        static let marign: CGFloat = 2
    }

    private lazy var panGesture: UIPanGestureRecognizer = {
        $0.minimumNumberOfTouches = 1
        $0.maximumNumberOfTouches = 1
        return $0
    }(UIPanGestureRecognizer(target: self, action: #selector(drag(_:))))

    private lazy var tapGesture: UITapGestureRecognizer = {
        return $0
    }(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))

    private let dimView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.backgroundColor = .black.withAlphaComponent(0.3)
        return $0
    }(UIView())

    private let borderView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 2
        $0.backgroundColor = .white
        return $0
    }(UIView())

    private lazy var stackView: UIStackView = {
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIStackView(arrangedSubviews: [makeHSTackView([appCPUView, appRAMView, appFPS]),
                                     makeHSTackView([appNETView, sysCPUView, sysRAMView])]))

    private lazy var appCPUView = MonitoringLiteView(type: .appCPU)
    private lazy var appRAMView = MonitoringLiteView(type: .appRAM)
    private lazy var appFPS = MonitoringLiteView(type: .appFPS)
    private lazy var appNETView = MonitoringLiteView(type: .appNET)
    private lazy var sysCPUView = MonitoringLiteView(type: .sysCPU)
    private lazy var sysRAMView = MonitoringLiteView(type: .sysRAM)

    private lazy var monitoring = Monitoring()

    init() {
        super.init(nibName: nil, bundle: nil)

        setupViews()
        bind()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { [weak self] context in
            self?.updateRotateGodWindow(context.transitionDuration)
        }
    }

    private func makeHSTackView(_ subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .horizontal
        return stackView
    }
}

extension GodEyeViewController {
    private func setupViews() {
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.addSubview(borderView)
        view.addSubview(dimView)
        borderView.addSubview(stackView)

        let borderLeading = borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constant.marign)
        let borderBottom = borderView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constant.marign)
        borderLeading.priority = .defaultHigh
        borderBottom.priority = .defaultHigh
        NSLayoutConstraint.activate([
            borderLeading,
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constant.marign),
            borderView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.marign),
            borderBottom
        ])

        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: Constant.marign),
            stackView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -Constant.marign),
            stackView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: Constant.marign),
            stackView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -Constant.marign)
        ])

        NSLayoutConstraint.activate([
            appCPUView.widthAnchor.constraint(equalToConstant: Constant.viewWidth),
            appRAMView.widthAnchor.constraint(equalToConstant: Constant.viewWidth),
            appFPS.widthAnchor.constraint(equalToConstant: Constant.viewWidth),
            appNETView.widthAnchor.constraint(equalToConstant: Constant.viewWidth),
            sysCPUView.widthAnchor.constraint(equalToConstant: Constant.viewWidth),
            sysRAMView.widthAnchor.constraint(equalToConstant: Constant.viewWidth)
        ])

        stackView.arrangedSubviews.forEach {
            $0.heightAnchor.constraint(equalToConstant: Constant.lineHeight).isActive = true
        }

        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(tapGesture)
    }

    private func bind() {
        monitoring.appCPU = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appCPUView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.appRAM = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appRAMView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.appFPS = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appFPS.bind(model.value, unit: model.unit)
            }
        }

        monitoring.appNET = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.appNETView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.sysCPU = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.sysCPUView.bind(model.value, unit: model.unit)
            }
        }

        monitoring.sysRAM = { [weak self] model in
            DispatchQueue.main.async { [weak self] in
                self?.sysRAMView.bind(model.value, unit: model.unit)
            }
        }
    }
}

extension GodEyeViewController {
    var isShowing: Bool {
        !(godWindow?.isHidden ?? true)
    }

    func show() {
        makeWindow()
        godWindow?.isHidden = false
        monitoring.start()
    }

    func hide() {
        godWindow?.isHidden = true
        monitoring.stop()
    }

    private func enabled() {
        godWindow?.isUserInteractionEnabled = true
        dimView.isHidden = true
    }

    private func disabled() {
        godWindow?.isUserInteractionEnabled = false
        dimView.isHidden = false
    }
}

extension GodEyeViewController {
    @objc private func drag(_ sender: UIPanGestureRecognizer) {
        guard [.began, .changed].contains(sender.state) else { return }
        guard let window = godWindow else { return }
        let translation = sender.translation(in: window)
        window.center = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
        sender.setTranslation(.zero, in: window)
    }

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        guard [.recognized].contains(sender.state) else { return }
        GodEyeTabBarController.toggle()
    }
}

extension GodEyeViewController {
    private var godWindowSize: CGSize {
        let itemWidth = Constant.viewWidth * 3
        let itemHeight = Constant.lineHeight * 2
        let margin = Constant.marign * 4
        let width = itemWidth + margin
        let height = itemHeight + margin
        return .init(width: width, height: height)
    }

    private func makeWindow() {
        if godWindow != nil { return }

        godWindow = UIWindow(frame: .init(origin: .init(x: UIScreen.main.bounds.width - godWindowSize.width - 20, y: 80), size: godWindowSize))
        godWindow?.backgroundColor = .clear
        godWindow?.windowLevel = .alert
        godWindow?.rootViewController = self
    }

    private func updateRotateGodWindow(_ duration: TimeInterval) {
        guard let godWindow = godWindow else { return }
        let center = godWindow.center
        UIView.animate(withDuration: duration) { [self] in
            godWindow.frame.size = godWindowSize
            godWindow.center = center
        }
    }
}
