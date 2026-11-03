//
//  TrackerCell.swift
//  Tracker
//
//  Created by Капитонов Константин on 03.11.2026.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    // MARK: - Constants

    private enum Constants {
        static let cardCornerRadius: CGFloat = 16
        static let cardHeight: CGFloat = 90
        static let contentInset: CGFloat = 12
        static let emojiSize: CGFloat = 24
        static let emojiFontSize: CGFloat = 16
        static let textFontSize: CGFloat = 12
        static let nameNumberOfLines = 2
        static let buttonSize: CGFloat = 34
        static let buttonTopInset: CGFloat = 8
        static let buttonFontSize: CGFloat = 20
        static let completedAlpha: CGFloat = 0.3
        static let enabledAlpha: CGFloat = 1
        static let disabledAlpha: CGFloat = 0.5
    }

    // MARK: - Properties

    static let reuseIdentifier = "TrackerCell"

    private let card = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
    private let completionButton = UIButton(type: .custom)
    var onCompletionTap: (() -> Void)?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
        setupEmojiLabel()
        setupNameLabel()
        setupCountLabel()
        setupCompletionButton()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    private func setupCard() {
        card.layer.cornerRadius = Constants.cardCornerRadius
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
    }

    private func setupEmojiLabel() {
        emojiLabel.font = .systemFont(ofSize: Constants.emojiFontSize)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = UIColor.ypLightGray
        emojiLabel.layer.cornerRadius = Constants.emojiSize / 2
        emojiLabel.clipsToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emojiLabel)
    }

    private func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: Constants.textFontSize, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = Constants.nameNumberOfLines
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)
    }

    private func setupCountLabel() {
        countLabel.font = .systemFont(ofSize: Constants.textFontSize, weight: .medium)
        countLabel.textColor = .ypBlack
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countLabel)
    }

    private func setupCompletionButton() {
        completionButton.addTarget(self, action: #selector(didTapCompletion), for: .touchUpInside)
        completionButton.setTitleColor(.white, for: .normal)
        completionButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(completionButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.heightAnchor.constraint(equalToConstant: Constants.cardHeight),
            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Constants.contentInset),
            emojiLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: Constants.contentInset),
            emojiLabel.widthAnchor.constraint(equalToConstant: Constants.emojiSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: Constants.emojiSize),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Constants.contentInset),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Constants.contentInset),
            nameLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Constants.contentInset),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentInset),
            countLabel.centerYAnchor.constraint(equalTo: completionButton.centerYAnchor),
            completionButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: Constants.buttonTopInset),
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.contentInset),
            completionButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            completionButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }

    // MARK: - Configuration and reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        onCompletionTap = nil
    }

    func configure(tracker: Tracker, count: Int, completed: Bool, canComplete: Bool) {
        card.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        let format = NSLocalizedString("tracker.completed_days", comment: "Количество дней выполнения трекера")
        countLabel.text = String(format: format, locale: Locale(identifier: "ru_RU"), count)
        completionButton.isEnabled = canComplete
        completionButton.tintColor = tracker.color.withAlphaComponent(completed ? Constants.completedAlpha : Constants.enabledAlpha)
        let buttonImage: UIImage = completed ? .trackerChecked : .trackerPlus
        completionButton.setBackgroundImage(buttonImage.withRenderingMode(.alwaysTemplate), for: .normal)
        completionButton.accessibilityLabel = completed
            ? NSLocalizedString("tracker.unmark_completed", comment: "Снять отметку о выполнении")
            : NSLocalizedString("tracker.mark_completed", comment: "Отметить трекер выполненным")
        completionButton.alpha = canComplete ? Constants.enabledAlpha : Constants.disabledAlpha
    }

    // MARK: - Actions

    @objc private func didTapCompletion() { onCompletionTap?() }
}
