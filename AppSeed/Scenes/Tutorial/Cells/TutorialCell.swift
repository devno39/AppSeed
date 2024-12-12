//
//  TutorialCell.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import UIKit
import SnapKit

final class TutorialCell: BaseCollectionViewCell {
    // MARK: - UI
    private lazy var tutorialImageView: BaseImageView = {
        let view = BaseImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = ColorText.textPrimary.color
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorText.textSecondary.color
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        draw()
    }

    // MARK: - Configure Cell
    func configure(with model: TutorialUIModel?) {
        titleLabel.text = model?.title
        subtitleLabel.text = model?.subtitle
        tutorialImageView.image = model?.image?.image
    }
}

// MARK: - Draw
private extension TutorialCell {
    private func draw() {
        addSubview(tutorialImageView)
        tutorialImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(tutorialImageView.snp.width)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(tutorialImageView.snp.bottom).offset(16)
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
}
