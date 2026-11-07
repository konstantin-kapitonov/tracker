import UIKit

final class HabitSelectionCell: UICollectionViewCell {
    static let reuseIdentifier = "HabitSelectionCell"

    private enum Constants {
        static let emojiCornerRadius: CGFloat = 16
        static let colorInset: CGFloat = 6
        static let colorCornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 3
        static let borderOpacity: CGFloat = 0.3
        static let emojiFontSize: CGFloat = 32
    }

    private let emojiLabel = UILabel()
    private let colorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        emojiLabel.font = .systemFont(ofSize: Constants.emojiFontSize)
        emojiLabel.textAlignment = .center
        colorView.layer.cornerRadius = Constants.colorCornerRadius
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.colorInset),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.colorInset),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.colorInset),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.colorInset)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(emoji: String, selected: Bool) {
        contentView.layer.cornerRadius = Constants.emojiCornerRadius
        emojiLabel.text = emoji
        emojiLabel.isHidden = false
        colorView.isHidden = true
        contentView.backgroundColor = selected ? .ypLightGray : .clear
        contentView.layer.borderWidth = 0
        accessibilityLabel = emoji
        accessibilityTraits = selected ? [.button, .selected] : .button
    }

    func configure(color: UIColor, selected: Bool, accessibilityName: String) {
        contentView.layer.cornerRadius = Constants.colorCornerRadius + Constants.borderWidth
        emojiLabel.isHidden = true
        colorView.isHidden = false
        colorView.backgroundColor = color
        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = selected ? Constants.borderWidth : 0
        contentView.layer.borderColor = color.withAlphaComponent(Constants.borderOpacity).cgColor
        accessibilityLabel = accessibilityName
        accessibilityTraits = selected ? [.button, .selected] : .button
    }
}
