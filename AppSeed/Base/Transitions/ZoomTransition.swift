//
//  ZoomTransition.swift
//  AppSeed
//
//  Created by Claude on 15.04.2026.
//

import UIKit

// MARK: - Transition Delegate
final class ZoomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let sourceFrame: CGRect
    let sourceSnapshot: UIView
    let sourceCornerRadius: CGFloat
    let targetCornerRadius: CGFloat
    let backgroundColor: UIColor
    let targetFrameProvider: (CGSize, UIView) -> CGRect
    private let dismissEnabled: Bool
    // nil → use full fromView (PhotoViewer behavior).
    let contentFrameProvider: ((UIView) -> CGRect)?
    // nil → snapshot the presented view. A caller with a shape of its own supplies a view
    // carrying it as layer properties, so the shrink does not stretch baked pixels.
    let dismissSnapshotProvider: (() -> UIView?)?

    init(
        sourceFrame: CGRect,
        sourceSnapshot: UIView,
        sourceCornerRadius: CGFloat = 10,
        targetCornerRadius: CGFloat = 12,
        backgroundColor: UIColor = .black,
        targetFrame: @escaping (CGSize, UIView) -> CGRect,
        enableDismiss: Bool = false,
        contentFrame: ((UIView) -> CGRect)? = nil,
        dismissSnapshot: (() -> UIView?)? = nil
    ) {
        self.sourceFrame = sourceFrame
        self.sourceSnapshot = sourceSnapshot
        self.sourceCornerRadius = sourceCornerRadius
        self.targetCornerRadius = targetCornerRadius
        self.backgroundColor = backgroundColor
        self.targetFrameProvider = targetFrame
        self.dismissEnabled = enableDismiss
        self.contentFrameProvider = contentFrame
        self.dismissSnapshotProvider = dismissSnapshot
        super.init()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ZoomPresentAnimator(
            sourceFrame: sourceFrame,
            sourceSnapshot: sourceSnapshot,
            sourceCornerRadius: sourceCornerRadius,
            targetCornerRadius: targetCornerRadius,
            backgroundColor: backgroundColor,
            targetFrameProvider: targetFrameProvider
        )
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard dismissEnabled else { return nil }
        return ZoomDismissAnimator(
            destinationFrame: sourceFrame,
            destinationCornerRadius: sourceCornerRadius,
            startCornerRadius: targetCornerRadius,
            backgroundColor: backgroundColor,
            contentFrameProvider: contentFrameProvider,
            snapshotProvider: dismissSnapshotProvider
        )
    }
}

// MARK: - Convenience — Photo Viewer
extension ZoomTransitionDelegate {
    static func photoViewer(sourceFrame: CGRect, sourceImage: UIImage?) -> ZoomTransitionDelegate {
        let snapshot = UIImageView(image: sourceImage)
        snapshot.contentMode = .scaleAspectFill
        snapshot.clipsToBounds = true

        let imageSize = sourceImage?.size ?? CGSize(width: 1, height: 1)

        return ZoomTransitionDelegate(
            sourceFrame: sourceFrame,
            sourceSnapshot: snapshot,
            sourceCornerRadius: 10,
            backgroundColor: .black,
            targetFrame: { containerSize, _ in
                aspectFitFrame(imageSize: imageSize, containerSize: containerSize)
            }
        )
    }

    private static func aspectFitFrame(imageSize: CGSize, containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGRect(origin: .zero, size: containerSize)
        }
        let aspectRatio = imageSize.width / imageSize.height
        let targetSize: CGSize
        if aspectRatio > containerSize.width / containerSize.height {
            targetSize = CGSize(width: containerSize.width, height: containerSize.width / aspectRatio)
        } else {
            targetSize = CGSize(width: containerSize.height * aspectRatio, height: containerSize.height)
        }
        let x = (containerSize.width - targetSize.width) / 2
        let y = (containerSize.height - targetSize.height) / 2
        return CGRect(x: x, y: y, width: targetSize.width, height: targetSize.height)
    }
}

// MARK: - Present Animator
final class ZoomPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let sourceFrame: CGRect
    private let sourceSnapshot: UIView
    private let sourceCornerRadius: CGFloat
    private let targetCornerRadius: CGFloat
    private let backgroundColor: UIColor
    private let targetFrameProvider: (CGSize, UIView) -> CGRect

    init(
        sourceFrame: CGRect,
        sourceSnapshot: UIView,
        sourceCornerRadius: CGFloat,
        targetCornerRadius: CGFloat,
        backgroundColor: UIColor,
        targetFrameProvider: @escaping (CGSize, UIView) -> CGRect
    ) {
        self.sourceFrame = sourceFrame
        self.sourceSnapshot = sourceSnapshot
        self.sourceCornerRadius = sourceCornerRadius
        self.targetCornerRadius = targetCornerRadius
        self.backgroundColor = backgroundColor
        self.targetFrameProvider = targetFrameProvider
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.45
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        // Add toView and force layout so child VCs are sized —
        // targetFrameProvider may read subview frames.
        toView.frame = finalFrame
        toView.alpha = 0
        container.addSubview(toView)
        toView.layoutIfNeeded()

        // Position snapshot at source
        let snapshot = sourceSnapshot
        snapshot.frame = sourceFrame
        snapshot.layer.cornerRadius = sourceCornerRadius
        snapshot.clipsToBounds = true
        snapshot.layer.masksToBounds = true

        let backgroundView = UIView(frame: finalFrame)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.alpha = 0
        container.addSubview(backgroundView)
        container.addSubview(snapshot)

        let targetFrame = targetFrameProvider(finalFrame.size, toView)
        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut
        ) {
            snapshot.frame = targetFrame
            snapshot.layer.cornerRadius = self.targetCornerRadius
            backgroundView.alpha = 1
        } completion: { _ in
            toView.alpha = 1
            snapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK: - Dismiss Animator
final class ZoomDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let destinationFrame: CGRect
    private let destinationCornerRadius: CGFloat
    private let startCornerRadius: CGFloat
    private let backgroundColor: UIColor
    private let contentFrameProvider: ((UIView) -> CGRect)?
    private let snapshotProvider: (() -> UIView?)?

    init(
        destinationFrame: CGRect,
        destinationCornerRadius: CGFloat,
        startCornerRadius: CGFloat = 12,
        backgroundColor: UIColor,
        contentFrameProvider: ((UIView) -> CGRect)? = nil,
        snapshotProvider: (() -> UIView?)? = nil
    ) {
        self.destinationFrame = destinationFrame
        self.destinationCornerRadius = destinationCornerRadius
        self.startCornerRadius = startCornerRadius
        self.backgroundColor = backgroundColor
        self.contentFrameProvider = contentFrameProvider
        self.snapshotProvider = snapshotProvider
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView

        // For .fullScreen, the presenting VC's view was removed on present —
        // re-add it so it's visible behind the dismiss animation.
        if let toView = transitionContext.view(forKey: .to) {
            container.insertSubview(toView, at: 0)
        }

        // Determine content area to animate
        let contentFrame = contentFrameProvider?(fromView) ?? fromView.frame
        let useContentFrame = contentFrameProvider != nil

        // Snapshot just the content area (paper square) or full screen
        let snapshot: UIView
        if let provided = snapshotProvider?() {
            snapshot = provided
            snapshot.frame = contentFrame
        } else if useContentFrame {
            snapshot = fromView.resizableSnapshotView(
                from: contentFrame,
                afterScreenUpdates: false,
                withCapInsets: .zero
            ) ?? fromView.snapshotView(afterScreenUpdates: false) ?? UIView()
            snapshot.frame = contentFrame
            snapshot.layer.cornerRadius = startCornerRadius
        } else {
            snapshot = fromView.snapshotView(afterScreenUpdates: false) ?? UIView()
            snapshot.frame = fromView.frame
            snapshot.layer.cornerRadius = 0
        }
        snapshot.clipsToBounds = true

        let backgroundView = UIView(frame: container.bounds)
        backgroundView.backgroundColor = backgroundColor

        fromView.isHidden = true
        container.addSubview(backgroundView)
        container.addSubview(snapshot)

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.3,
            options: .curveEaseInOut
        ) {
            snapshot.frame = self.destinationFrame
            snapshot.layer.cornerRadius = self.destinationCornerRadius
            backgroundView.alpha = 0
        } completion: { _ in
            snapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            fromView.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
