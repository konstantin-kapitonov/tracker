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
	static let textInset: CGFloat = 16
	static let cancelBorderWidth: CGFloat = 1
	static let nameCharacterLimit = 38
	static let limitLabelTopInset: CGFloat = 8
	static let limitLabelHeight: CGFloat = 22
	static let limitLabelFontSize: CGFloat = 17
}

final class NewHabitViewController: UIViewController {
    // MARK: - Types

    private enum Option: Int, CaseIterable {
        case category, schedule
    }

    // MARK: - Properties

    var onCreate: ((Tracker) -> Void)?
    private let nameField = UITextField()
    private let limitLabel = UILabel()
    private let createButton = UIButton(type: .system)
    private let optionsTable = UITableView(frame: .zero, style: .insetGrouped)
    private var optionsTopConstraint: NSLayoutConstraint!
    private var schedule = Set(Weekday.allCases)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("habit.title", comment: "Заголовок создания привычки")
        view.backgroundColor = .ypWhite
        setupNameField()
        setupLimitLabel()
        setupOptions()
        setupButtons()
        updateCreateButton()
    }

    // MARK: - Setup

    private func setupNameField() {
        nameField.placeholder = NSLocalizedString("habit.name_placeholder", comment: "Название трекера")
        nameField.backgroundColor = .ypBackground
        nameField.textColor = .ypBlack
        nameField.layer.cornerRadius = Constants.cornerRadius
        nameField.clearButtonMode = .whileEditing
        nameField.delegate = self
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.textInset, height: Constants.fieldHeight))
        nameField.leftViewMode = .always
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        nameField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameField)
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topInset),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
            nameField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight)
        ])
    }

    private func setupLimitLabel() {
        limitLabel.text = NSLocalizedString("habit.name_limit", comment: "Ограничение длины названия")
        limitLabel.textColor = .ypRed
		limitLabel.font = .systemFont(ofSize: Constants.limitLabelFontSize)
        limitLabel.textAlignment = .center
        limitLabel.isHidden = true
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(limitLabel)
        NSLayoutConstraint.activate([
            limitLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: Constants.limitLabelTopInset),
            limitLabel.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            limitLabel.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            limitLabel.heightAnchor.constraint(equalToConstant: Constants.limitLabelHeight)
        ])
    }

    private func setupOptions() {
        optionsTable.dataSource = self
        optionsTable.delegate = self
        optionsTable.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        optionsTable.rowHeight = Constants.rowHeight
        optionsTable.isScrollEnabled = false
        optionsTable.backgroundColor = .clear
        optionsTable.separatorColor = .ypLightGray
        optionsTable.layoutMargins = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        optionsTable.estimatedSectionHeaderHeight = 0
        optionsTable.estimatedSectionFooterHeight = 0
        optionsTable.separatorInset = UIEdgeInsets(
			top: 0,
			left: Constants.textInset,
			bottom: 0,
			right: Constants.textInset
		)
        optionsTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsTable)
        optionsTopConstraint = optionsTable.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: Constants.sectionSpacing)
        NSLayoutConstraint.activate([
            optionsTopConstraint,
            optionsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsTable.heightAnchor.constraint(equalToConstant: Constants.rowHeight * CGFloat(Option.allCases.count))
        ])
    }

    private func setupButtons() {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(NSLocalizedString("habit.cancel", comment: "Отменить создание"), for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderWidth = Constants.cancelBorderWidth
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.cornerRadius = Constants.cornerRadius
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        var createConfiguration = UIButton.Configuration.plain()
        createConfiguration.title = NSLocalizedString("habit.create", comment: "Создать трекер")
        createConfiguration.baseForegroundColor = .ypWhite
        createConfiguration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.foregroundColor = .ypWhite
            return attributes
        }
        createConfiguration.cornerStyle = .fixed
        createConfiguration.background.cornerRadius = Constants.cornerRadius
        createButton.configuration = createConfiguration
        createButton.configurationUpdateHandler = { button in
            var configuration = button.configuration
            configuration?.background.backgroundColor = button.isEnabled ? .ypBlack : .ypGray
            button.configuration = configuration
        }
        createButton.addTarget(self, action: #selector(create), for: .touchUpInside)

        let buttons = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = Constants.buttonSpacing
        buttons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttons)
        NSLayoutConstraint.activate([
            buttons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
            buttons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
            buttons.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -Constants.buttonBottomInset),
            buttons.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - State and actions

    private func updateCreateButton() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        createButton.isEnabled = !name.isEmpty && !schedule.isEmpty
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
        guard !name.isEmpty, !schedule.isEmpty else { return }
        onCreate?(Tracker(id: UUID(), name: name, color: .colorSelection5, emoji: "❤️", schedule: schedule))
        dismiss(animated: true)
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
