//
//  CropImageView.swift
//  AppSeed
//
//  Created by Claude on 02.05.2026.
//

import UIKit
import SnapKit

final class CropImageView: UIView {

    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.bouncesZoom = true
        scroll.alwaysBounceVertical = false
        scroll.alwaysBounceHorizontal = false
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.delaysContentTouches = false
        scroll.clipsToBounds = true
        scroll.decelerationRate = .fast
        return scroll
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()

    // MARK: - State
    private var pendingImage: UIImage?
    private(set) var image: UIImage?
    private var configuredForBoundsSize: CGSize = .zero
    private var configuredForImageSize: CGSize = .zero
    private(set) var hasUserInteracted = false

    // MARK: - Closure
    var onUserInteraction: EmptyClosure?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureZoomIfNeeded()
    }

    // MARK: - Public

    // Total state wipe on every set — re-pick scenarios get a clean slate.
    // pendingImage stored separately; funnel consumes it once bounds are real.
    func setImage(_ image: UIImage) {
        pendingImage = image.normalizingOrientation()
        self.image = nil
        configuredForBoundsSize = .zero
        configuredForImageSize = .zero
        hasUserInteracted = false

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = 1
        scrollView.contentInset = .zero
        scrollView.contentOffset = .zero
        scrollView.contentSize = .zero
        imageView.image = nil

        setNeedsLayout()
        layoutIfNeeded()
    }

    // Returns cropped image — forces configuration if Save was tapped pre-layout; bounce guard prevents mid-gesture capture.
    var croppedImage: UIImage? {
        layoutIfNeeded()
        configureZoomIfNeeded()

        guard let image, let cgImage = image.cgImage else { return nil }
        guard configuredForBoundsSize == scrollView.bounds.size,
              scrollView.bounds.width > 0,
              scrollView.zoomScale > 0 else { return nil }

        if scrollView.isZooming || scrollView.isTracking || scrollView.isDecelerating {
            scrollView.setZoomScale(scrollView.zoomScale, animated: false)
        }

        let zoom = scrollView.zoomScale
        let visiblePoints = CGRect(
            x: scrollView.contentOffset.x / zoom,
            y: scrollView.contentOffset.y / zoom,
            width: scrollView.bounds.width / zoom,
            height: scrollView.bounds.height / zoom
        )

        let imageRect = CGRect(origin: .zero, size: image.size)
        let clampedPoints = visiblePoints.intersection(imageRect).integral
        guard !clampedPoints.isNull, !clampedPoints.isEmpty else { return nil }

        let s = image.scale
        let pixelRect = CGRect(
            x: clampedPoints.origin.x * s,
            y: clampedPoints.origin.y * s,
            width: clampedPoints.size.width * s,
            height: clampedPoints.size.height * s
        ).integral

        guard let cropped = cgImage.cropping(to: pixelRect) else { return nil }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: .up)
    }

    // MARK: - Funnel
    // Single entry point from layoutSubviews and setImage's layout pass; idempotent for the same (image, bounds).
    private func configureZoomIfNeeded() {
        let candidate = pendingImage ?? image
        guard let candidate else { return }
        let bounds = scrollView.bounds.size
        guard bounds.width > 0, bounds.height > 0,
              candidate.size.width > 0, candidate.size.height > 0 else { return }

        if configuredForBoundsSize == bounds,
           configuredForImageSize == candidate.size,
           imageView.image === candidate {
            return
        }

        applyImageAndZoom(candidate, in: bounds)

        image = candidate
        pendingImage = nil
        configuredForBoundsSize = bounds
        configuredForImageSize = candidate.size
    }

    // Order matters — contentSize → minMax → zoomScale → contentOffset; UIScrollView clamps offset synchronously.
    private func applyImageAndZoom(_ image: UIImage, in boundsSize: CGSize) {
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size

        let widthScale = boundsSize.width / image.size.width
        let heightScale = boundsSize.height / image.size.height
        let minScale = max(widthScale, heightScale) // aspect-fill

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = max(minScale * 4.0, 1.0)
        scrollView.zoomScale = minScale

        let content = scrollView.contentSize
        let offsetX = max((content.width - boundsSize.width) * 0.5, 0)
        let offsetY = max((content.height - boundsSize.height) * 0.5, 0)
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
}

// MARK: - UIScrollViewDelegate
extension CropImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hasUserInteracted = true
        onUserInteraction?()
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        hasUserInteracted = true
        onUserInteraction?()
    }
}

// MARK: - Draw
extension CropImageView {
    private func draw() {
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UIImage Orientation Normalize
// PHPicker portrait photos arrive with .right orientation — CGImage is rotated 90°; re-render so cgImage matches the scrollView.
private extension UIImage {
    func normalizingOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
