//
//  PhotoStackAnnotationView.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import MapKit

// Frames by hand: MKAnnotationView is sized before the map lays it out, so constraints resolve too late.
final class PhotoStackAnnotationView: MKAnnotationView {

    // MARK: - Constants
    static let reuseID = "PhotoStackAnnotationView"
    static let clusteringIdentifier = "photoStack"
    private let photoSize: CGFloat = 58
    private let cornerRadius: CGFloat = 10
    private let borderWidth: CGFloat = 2.5
    private let pointerSize: CGFloat = 8

    // MARK: - UI
    private lazy var backLeftWrapper: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var backLeftImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = ColorBackground.backgroundSecondary.color.cgColor
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        return view
    }()

    private lazy var backRightWrapper: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var backRightImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = ColorBackground.backgroundSecondary.color.cgColor
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        return view
    }()

    private lazy var frontWrapper: UIView = {
        UIView()
    }()

    private lazy var frontImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = ColorBackground.backgroundSecondary.color.cgColor
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        return view
    }()

    private lazy var countBadge: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.palette1.color
        view.layer.cornerRadius = 9
        view.isHidden = true
        return view
    }()

    private lazy var countLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 10, fontWeight: .bold, textColor: .white)
        label.textAlignment = .center
        return label
    }()

    private lazy var cornerBadge: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.palette1.color
        view.layer.cornerRadius = 9
        view.isHidden = true
        return view
    }()

    private lazy var cornerBadgeIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        let view = UIImageView(image: UIImage(systemName: Symbols.pin_fill.symbolName, withConfiguration: config))
        view.tintColor = .white
        view.contentMode = .center
        return view
    }()

    private lazy var pointerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        view.layer.cornerRadius = pointerSize / 2
        return view
    }()

    // MARK: - Init
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = Self.clusteringIdentifier
        draw()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: PhotoStackAnnotationView, _) in
            view.updateBorderColors()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with annotation: PhotoStackAnnotation) {
        let count = annotation.imageCount

        loadImage(annotation.imageURLs[safe: 0], into: frontImageView)
        frontWrapper.layer.shadowPath = UIBezierPath(
            roundedRect: frontImageView.bounds,
            cornerRadius: cornerRadius
        ).cgPath

        if count >= 2 {
            backLeftWrapper.isHidden = false
            backLeftWrapper.transform = CGAffineTransform(translationX: -16, y: 3)
                .rotated(by: -.pi * 16 / 180)
                .scaledBy(x: 0.9, y: 0.9)
            loadImage(annotation.imageURLs[safe: 1], into: backLeftImageView)
        } else {
            backLeftWrapper.isHidden = true
        }

        if count >= 3 {
            backRightWrapper.isHidden = false
            backRightWrapper.transform = CGAffineTransform(translationX: 16, y: 3)
                .rotated(by: .pi * 16 / 180)
                .scaledBy(x: 0.8, y: 0.8)
            loadImage(annotation.imageURLs[safe: 2], into: backRightImageView)
        } else {
            backRightWrapper.isHidden = true
        }

        countBadge.isHidden = count <= 1
        countLabel.text = count > 1 ? "\(count)" : nil
        cornerBadge.isHidden = !annotation.isBadged
    }

    // MARK: - Transition Access
    var frontCardFrame: CGRect { frontWrapper.frame }
    var frontImage: UIImage? { frontImageView.image }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        frontImageView.cancelImageDownload()
        frontImageView.image = nil
        backLeftImageView.cancelImageDownload()
        backLeftImageView.image = nil
        backLeftWrapper.isHidden = true
        backLeftWrapper.transform = .identity
        backRightImageView.cancelImageDownload()
        backRightImageView.image = nil
        backRightWrapper.isHidden = true
        backRightWrapper.transform = .identity
        countBadge.isHidden = true
        countLabel.text = nil
        cornerBadge.isHidden = true
    }

    // MARK: - Private
    private func loadImage(_ urlString: String?, into imageView: UIImageView) {
        guard let urlString else {
            imageView.image = nil
            return
        }
        imageView.setImage(with: urlString, downsampledTo: CGSize(width: photoSize, height: photoSize))
    }

    private func updateBorderColors() {
        let borderColor = ColorBackground.backgroundSecondary.color.cgColor
        frontImageView.layer.borderColor = borderColor
        backLeftImageView.layer.borderColor = borderColor
        backRightImageView.layer.borderColor = borderColor
    }
}

// MARK: - Draw
extension PhotoStackAnnotationView {
    private func draw() {
        backgroundColor = .clear

        let totalWidth: CGFloat = photoSize + 48
        let totalHeight: CGFloat = photoSize + pointerSize + 10
        frame = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
        centerOffset = CGPoint(x: 0, y: -totalHeight / 2)

        let centerX = totalWidth / 2
        let cardFrame = CGRect(x: centerX - photoSize / 2, y: 0, width: photoSize, height: photoSize)

        addSubview(backLeftWrapper)
        backLeftWrapper.frame = cardFrame
        backLeftWrapper.addSubview(backLeftImageView)
        backLeftImageView.frame = backLeftWrapper.bounds
        backLeftWrapper.drawShadow(radius: 8, opacity: 0.3)

        addSubview(backRightWrapper)
        backRightWrapper.frame = cardFrame
        backRightWrapper.addSubview(backRightImageView)
        backRightImageView.frame = backRightWrapper.bounds
        backRightWrapper.drawShadow(radius: 8, opacity: 0.3)

        addSubview(frontWrapper)
        frontWrapper.frame = cardFrame
        frontWrapper.addSubview(frontImageView)
        frontImageView.frame = frontWrapper.bounds
        frontWrapper.drawShadow(radius: 12, opacity: 0.4)

        addSubview(pointerView)
        pointerView.frame = CGRect(
            x: centerX - pointerSize / 2,
            y: photoSize + 4,
            width: pointerSize,
            height: pointerSize
        )

        addSubview(countBadge)
        countBadge.addSubview(countLabel)
        countBadge.frame = CGRect(x: centerX + photoSize / 2 - 14, y: -6, width: 18, height: 18)
        countLabel.frame = countBadge.bounds
        countBadge.drawShadow(radius: 3, opacity: 0.25)

        addSubview(cornerBadge)
        cornerBadge.addSubview(cornerBadgeIcon)
        cornerBadge.frame = CGRect(x: centerX - photoSize / 2 - 4, y: -6, width: 18, height: 18)
        cornerBadgeIcon.frame = cornerBadge.bounds
        cornerBadge.drawShadow(radius: 3, opacity: 0.25)
    }
}
