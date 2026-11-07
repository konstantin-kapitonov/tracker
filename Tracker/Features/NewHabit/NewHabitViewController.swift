//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Капитонов Константин on 03.11.2026.
//

import UIKit

private enum Constants {
	static let horizontalInset: CGFloat = 16
	static let topInset: CGFloat = 24
	static let fieldHeight: CGFloat = 75
	static let rowHeight: CGFloat = 75
	static let sectionSpacing: CGFloat = 24
	static let cornerRadius: CGFloat = 16
	static let buttonHeight: CGFloat = 60
	static let buttonSpacing: CGFloat = 8
	static let buttonBottomInset: CGFloat = 16
	static let buttonsTopInset: CGFloat = 24
	static let textInset: CGFloat = 16
	static let cancelBorderWidth: CGFloat = 1
	static let nameCharacterLimit = 38
	static let limitLabelTopInset: CGFloat = 8
	static let limitLabelHeight: CGFloat = 22
	static let limitLabelFontSize: CGFloat = 17
	static let selectionItemSize: CGFloat = 52
	static let selectionColumns: CGFloat = 6
	static let selectionRows: CGFloat = 3
	static let selectionLineSpacing: CGFloat = 0
	static let selectionHeaderFontSize: CGFloat = 19
	static let selectionHeaderInset: CGFloat = 12
	static let selectionHeaderSpacing: CGFloat = 16
	static let selectionSectionSpacing: CGFloat = 24
}

final class NewHabitViewController: UIViewController {
    // MARK: - Types

    private enum Option: Int, CaseIterable {
        case category, schedule
    }

    // MARK: - Properties

    var onCreate: ((Tracker) -> Void)?

    private let emojis = ["🙂", "😍", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [.colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18]
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.keyboardDismissMode = .interactive
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let formView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiTitleLabel = makeSectionTitle(NSLocalizedString("habit.emoji", comment: "Заголовок выбора эмодзи"))
    private let colorTitleLabel = makeSectionTitle(NSLocalizedString("habit.color", comment: "Заголовок выбора цвета"))
    private lazy var emojiCollection = makeSelectionCollection()
    private lazy var colorCollection = makeSelectionCollection()

    private lazy var nameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("habit.name_placeholder", comment: "Название трекера")
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.textInset, height: Constants.fieldHeight))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let limitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("habit.name_limit", comment: "Ограничение длины названия")
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: Constants.limitLabelFontSize)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var optionsTable: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        table.rowHeight = Constants.rowHeight
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        table.separatorColor = .ypLightGray
        table.layoutMargins = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        table.estimatedSectionHeaderHeight = 0
        table.estimatedSectionFooterHeight = 0
        table.separatorInset = UIEdgeInsets(top: 0, left: Constants.textInset, bottom: 0, right: Constants.textInset)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("habit.cancel", comment: "Отменить создание"), for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderWidth = Constants.cancelBorderWidth
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = NSLocalizedString("habit.create", comment: "Создать трекер")
        configuration.baseForegroundColor = .ypWhite
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.foregroundColor = .ypWhite
            return attributes
        }
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = Constants.cornerRadius
        button.configuration = configuration
        button.configurationUpdateHandler = { button in
            var configuration = button.configuration
            configuration?.background.backgroundColor = button.isEnabled ? .ypBlack : .ypGray
            button.configuration = configuration
        }
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.buttonSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var optionsTopConstraint: NSLayoutConstraint!
    private var schedule = Set(Weekday.allCases)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("habit.title", comment: "Заголовок создания привычки")
        view.backgroundColor = .ypWhite
        setupScrollView()
        setupNameField()
        setupLimitLabel()
        setupOptions()
        setupSelections()
        setupButtons()
        updateCreateButton()
    }

    // MARK: - Setup

    private static func makeSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: Constants.selectionHeaderFontSize, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeSelectionCollection() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.selectionLineSpacing
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(HabitSelectionCell.self, forCellWithReuseIdentifier: HabitSelectionCell.reuseIdentifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(formView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            formView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            formView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            formView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupNameField() {
        formView.addSubview(nameField)
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: formView.topAnchor, constant: Constants.topInset),
            nameField.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: Constants.horizontalInset),
            nameField.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -Constants.horizontalInset),
            nameField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight)
        ])
    }

    private func setupLimitLabel() {
        formView.addSubview(limitLabel)
        NSLayoutConstraint.activate([
            limitLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: Constants.limitLabelTopInset),
            limitLabel.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            limitLabel.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            limitLabel.heightAnchor.constraint(equalToConstant: Constants.limitLabelHeight)
        ])
    }

    private func setupOptions() {
        formView.addSubview(optionsTable)
        optionsTopConstraint = optionsTable.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: Constants.sectionSpacing)
        NSLayoutConstraint.activate([
            optionsTopConstraint,
            optionsTable.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            optionsTable.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            optionsTable.heightAnchor.constraint(equalToConstant: Constants.rowHeight * CGFloat(Option.allCases.count))
        ])
    }

    private func setupSelections() {
        [emojiTitleLabel, emojiCollection, colorTitleLabel, colorCollection].forEach { formView.addSubview($0) }
        let collectionHeight = Constants.selectionItemSize * Constants.selectionRows + Constants.selectionLineSpacing * (Constants.selectionRows - 1)
        NSLayoutConstraint.activate([
            emojiTitleLabel.topAnchor.constraint(equalTo: optionsTable.bottomAnchor, constant: Constants.selectionSectionSpacing),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: nameField.leadingAnchor, constant: Constants.selectionHeaderInset),
            emojiTitleLabel.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
			
            emojiCollection.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: Constants.selectionHeaderSpacing),
            emojiCollection.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: collectionHeight),
			
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: Constants.selectionSectionSpacing),
            colorTitleLabel.leadingAnchor.constraint(equalTo: emojiTitleLabel.leadingAnchor),
            colorTitleLabel.trailingAnchor.constraint(equalTo: emojiTitleLabel.trailingAnchor),
			
            colorCollection.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: Constants.selectionHeaderSpacing),
            colorCollection.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            colorCollection.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: collectionHeight)
        ])
    }

    private func setupButtons() {
        formView.addSubview(buttonsStack)
        NSLayoutConstraint.activate([
            buttonsStack.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: Constants.buttonsTopInset),
            buttonsStack.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: Constants.horizontalInset),
            buttonsStack.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -Constants.horizontalInset),
            buttonsStack.bottomAnchor.constraint(equalTo: formView.bottomAnchor, constant: -Constants.buttonBottomInset),
            buttonsStack.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - State and actions

    private func updateCreateButton() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        createButton.isEnabled = !name.isEmpty && !schedule.isEmpty && selectedEmojiIndex != nil && selectedColorIndex != nil
    }

    @objc private func nameChanged() {
        guard nameField.markedTextRange == nil else { return }
        let text = nameField.text ?? ""
        if text.count > Constants.nameCharacterLimit {
            nameField.text = String(text.prefix(Constants.nameCharacterLimit))
        }
        updateLimitWarning(isVisible: text.count >= Constants.nameCharacterLimit)
        updateCreateButton()
    }

    private func updateLimitWarning(isVisible: Bool) {
        limitLabel.isHidden = !isVisible
        optionsTopConstraint.constant = Constants.sectionSpacing + (isVisible ? Constants.limitLabelTopInset + Constants.limitLabelHeight : 0)
    }
    @objc private func cancel() { dismiss(animated: true) }

    private func showSchedule() {
        view.endEditing(true)
        let controller = ScheduleViewController(selectedDays: schedule)
        controller.onDone = { [weak self] days in
            self?.schedule = days
            self?.updateCreateButton()
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func create() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !schedule.isEmpty, let emojiIndex = selectedEmojiIndex, let colorIndex = selectedColorIndex else { return }
        onCreate?(Tracker(id: UUID(), name: name, color: colors[colorIndex], emoji: emojis[emojiIndex], schedule: schedule))
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegateFlowLayout

extension NewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollection ? emojis.count : colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitSelectionCell.reuseIdentifier, for: indexPath) as! HabitSelectionCell
        if collectionView === emojiCollection {
            cell.configure(emoji: emojis[indexPath.item], selected: selectedEmojiIndex == indexPath.item)
        } else {
            let format = NSLocalizedString("habit.color_accessibility", comment: "Номер цвета")
            let name = String(format: format, indexPath.item + 1)
            cell.configure(color: colors[indexPath.item], selected: selectedColorIndex == indexPath.item, accessibilityName: name)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollection {
            selectedEmojiIndex = indexPath.item
        } else {
            selectedColorIndex = indexPath.item
        }
        collectionView.reloadData()
        updateCreateButton()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width / Constants.selectionColumns
        return CGSize(width: Constants.selectionItemSize, height: Constants.selectionItemSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let itemWidth = min(Constants.selectionItemSize, floor(collectionView.bounds.width / Constants.selectionColumns))
        return max(0, (collectionView.bounds.width - itemWidth * Constants.selectionColumns) / (Constants.selectionColumns - 1))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.selectionLineSpacing
    }
}

// MARK: - UITextFieldDelegate

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.markedTextRange == nil else { return true }
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        guard updatedText.count <= Constants.nameCharacterLimit else {
            updateLimitWarning(isVisible: true)
            return false
        }
        return true
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate

extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { .leastNonzeroMagnitude }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { .leastNonzeroMagnitude }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Option.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        let option = Option.allCases[indexPath.row]
        var content = cell.defaultContentConfiguration()
        switch option {
        case .category:
            content.text = NSLocalizedString("habit.category", comment: "Категория трекера")
        case .schedule:
            content.text = NSLocalizedString("habit.schedule", comment: "Расписание трекера")
        }
        content.textProperties.color = .ypBlack
        cell.contentConfiguration = content
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Option.allCases[indexPath.row] == .schedule else { return }
        showSchedule()
    }
}
