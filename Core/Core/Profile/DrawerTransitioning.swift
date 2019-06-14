//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

let drawerWidth: CGFloat = 300.0
let animationDuration = 0.275

public class DrawerOpenTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
            else {
                return transitionContext.completeTransition(false)
        }

        transitionContext.containerView.insertSubview(to, belowSubview: from)

        let isRTL = UIView.userInterfaceLayoutDirection(for: from.semanticContentAttribute) == .rightToLeft

        var fromFrame = from.frame
        var toFrame = to.frame
        toFrame.size.width = drawerWidth
        toFrame.origin.x = isRTL ? fromFrame.width : -drawerWidth
        to.frame = toFrame

        fromFrame.origin.x += isRTL ? -drawerWidth : drawerWidth
        toFrame.origin.x = isRTL ? (fromFrame.width - drawerWidth) : 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            from.frame = fromFrame
            to.frame = toFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
}

class DrawerCloseTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
            else {
                return transitionContext.completeTransition(false)
        }

        let isRTL = UIView.userInterfaceLayoutDirection(for: from.semanticContentAttribute) == .rightToLeft

        var fromFrame = from.frame
        var toFrame = to.frame

        fromFrame.origin.x = isRTL ? toFrame.width : -fromFrame.width
        toFrame.origin.x = 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            from.frame = fromFrame
            to.frame = toFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
}

public class DrawerPresentationController: UIPresentationController {
    let dimmer = UIView()

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else { return }

        dimmer.backgroundColor = UIColor.named(.backgroundDarkest).withAlphaComponent(0.9)
        dimmer.alpha = 0
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dimmer)
        NSLayoutConstraint.activate([
            dimmer.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        ])
        dimmer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmer.alpha = 1
        })
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if !completed {
            dimmer.removeFromSuperview()
        }
    }

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmer.alpha = 0
        })
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            dimmer.removeFromSuperview()
        }
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        let isRTL = UIView.userInterfaceLayoutDirection(for: container.semanticContentAttribute) == .rightToLeft
        var frame = container.frame
        frame.size.width = drawerWidth
        if isRTL {
            frame.origin.x = container.frame.width - drawerWidth
        }
        return frame
    }

    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }

    @objc func tapped(gesture: UITapGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true)
    }
}

public class DrawerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public static let shared = DrawerTransitioningDelegate()

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerOpenTransitioning()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerCloseTransitioning()
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DrawerPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
