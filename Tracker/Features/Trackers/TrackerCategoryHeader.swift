//
//  TrackerCategoryHeader.swift
//  Tracker
//
//  Created by Капитонов Константин on 03.11.2026.
//

import UIKit

final class TrackerCategoryHeader: UICollectionReusableView {
    // MARK: - Constants

    private enum Constants {
        static let titleFontSize: CGFloat = 19
        static let titleInset: CGFloat = 12
    }

    // MARK: - Properties

    static let reuseIdentifier = "TrackerCategoryHeader"
    private let titleLabel = UILabel()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        titleLabel.textColor = .ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.titleInset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.titleInset)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    // MARK: - Configuration

    func configure(title: String) { titleLabel.text = title }
}
