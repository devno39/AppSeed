//
//  ClusterCountAnnotationView.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import MapKit

final class ClusterCountAnnotationView: MKAnnotationView {

    // MARK: - Constants
    static let reuseID = "ClusterCountAnnotationView"
    private let badgeSize: CGFloat = 40

    // MARK: - UI
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.palette1.color
        view.layer.cornerRadius = badgeSize / 2
        view.layer.borderWidth = 2
        view.setBorderColor(ColorBackground.backgroundSecondary.color)
        return view
    }()

    private lazy var countLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 14, fontWeight: .bold, textColor: .white)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        draw()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }
            countLabel.text = "\(cluster.memberAnnotations.count)"
        }
    }
}

// MARK: - Draw
extension ClusterCountAnnotationView {
    private func draw() {
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize)
        centerOffset = CGPoint(x: 0, y: -badgeSize / 2)

        addSubview(badgeView)
        badgeView.addSubview(countLabel)
        badgeView.frame = bounds
        countLabel.frame = bounds
    }
}
