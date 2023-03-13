//
//  ChidoriMenu.swift
//  Chidori
//
//  Created by Christian Selig on 2021-02-15.
//

import UIKit

open class ChidoriMenu: UIViewController {

    public enum AnchorOrientation {
        case center
        case leading
    }

    /// Where in the window the menu is being summond from
    var anchorPoint: CGPoint = .zero
    var anchorOrientation: AnchorOrientation = .center
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
    private let shadowLayer = CALayer()

    /// Stores a reference to the current tranisiton controller to share between animation and interaction roles
    var transitionController: ChidoriAnimationController?
    
    // Constants that match the iOS version
    static let width: CGFloat = 250.0
    static let cornerRadius: CGFloat = 13.0
    static let shadowRadius: CGFloat = 25.0
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented! Use init(nibName:, bundle:, anchorPoint:)")
    }

    public init(nibName: String, bundle: Bundle, anchorPoint: CGPoint, anchorOrientation: AnchorOrientation) {
        self.anchorPoint = anchorPoint
        self.anchorOrientation = anchorOrientation
        super.init(nibName: nibName, bundle: bundle)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    public init(stackView: UIStackView,
                edgeInsets: UIEdgeInsets = .zero,
                anchorPoint: CGPoint,
                anchorOrientation: AnchorOrientation) {

        self.anchorPoint = anchorPoint
        self.anchorOrientation = anchorOrientation
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: edgeInsets.top),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: edgeInsets.bottom),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: edgeInsets.left),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: edgeInsets.right)
        ]

        NSLayoutConstraint.activate(constraints)
        stackView.layoutSubviews()
    }

    /// If from == nil, will be shown on window root
    open func show(from: UIViewController? = nil) {
        let from = from ?? UIApplication.shared.windows.first.flatMap { $0.rootViewController }
        from?.present(self, animated: true)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Can't have masksToBounds = true for corner radius on the layer *and* have a drop shadow, so some extra steps are required
        setUpShadowLayer()
        
        view.layer.masksToBounds = false
        view.backgroundColor = .clear
        
        visualEffectView.layer.masksToBounds = true
        visualEffectView.layer.cornerRadius = ChidoriMenu.cornerRadius

        view.insertSubview(visualEffectView, at: 0)
    }

    open override func viewDidAppear(_ animated: Bool) {
        // Once the transition is over, we can nil out the transition controller
        // and simply dismiss this view controller as normal
        transitionController = nil
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        visualEffectView.frame = view.bounds

        // Set shadow path for better performance (note that bezier path uses continuous corner curve so no need to manually set)
        shadowLayer.frame = view.bounds
        shadowLayer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: ChidoriMenu.cornerRadius).cgPath
        setShadowMask()
    }
    
    private func setUpShadowLayer() {
        shadowLayer.masksToBounds = false
        shadowLayer.cornerRadius = ChidoriMenu.cornerRadius
        shadowLayer.cornerCurve = .continuous
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = 0.15
        shadowLayer.shadowRadius = ChidoriMenu.shadowRadius
        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale
        view.layer.addSublayer(shadowLayer)
    }
    
    private func setShadowMask() {
        // We need to do this (and jump through a lot of hoops) because UIVisualEffectView is partially tranparent, and since iOS draws the shadow underneath the view as well it would be visible if we didn't mask out the portion under the view
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        
        // Set fillRule so that the maskOutPath will actually remove from the center
        maskLayer.fillRule = .evenOdd
        
        // We want this mask to be larger than the shadow layer because the shadow layer draws outside its bounds. Make it suitably large enough to cover the shadow radius, which anecdotally seems approximately double the radius.
        let mainPath = UIBezierPath(roundedRect: CGRect(x: -ChidoriMenu.shadowRadius * 2.0, y: -ChidoriMenu.shadowRadius * 2.0, width: view.bounds.width + ChidoriMenu.shadowRadius * 4.0, height: view.bounds.height + ChidoriMenu.shadowRadius * 4.0), cornerRadius: ChidoriMenu.cornerRadius)
        
        let maskOutPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: ChidoriMenu.cornerRadius)
        mainPath.append(maskOutPath)
        maskLayer.path = mainPath.cgPath
        
        shadowLayer.mask = maskLayer
    }

    var size: CGSize {
        view.systemLayoutSizeFitting(.init(width: Self.width, height: .greatestFiniteMagnitude))
    }
}

// MARK: - Custom View Controller Presentation
extension ChidoriMenu: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionController = ChidoriAnimationController(type: .presentation)
        return transitionController
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return transitionController
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ChidoriAnimationController(type: .dismissal)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ChidoriPresentationController(presentedViewController: presented, presenting: source)
        controller.transitionDelegate = self
        return controller
    }
}

// MARK: - Presentation Controller Interactive Delegate
extension ChidoriMenu: ChidoriPresentationControllerDelegate {
    func didTapOverlayView(_ chidoriPresentationController: ChidoriPresentationController) {
        transitionController?.cancelTransition()
        dismiss(animated: true, completion: nil)
    }
}
