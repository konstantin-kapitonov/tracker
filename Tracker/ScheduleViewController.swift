//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Капитонов Константин on 25.10.2026.
//

import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - Constants

    private enum Constants {
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 24
        static let bottomInset: CGFloat = 16
        static let rowHeight: CGFloat = 75
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let buttonTopInset: CGFloat = 24
        static let separatorInset: CGFloat = 16
    }

    // MARK: - Properties

    var onDone: ((Set<Weekday>) -> Void)?
    private var selectedDays: Set<Weekday>
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Lifecycle

    init(selectedDays: Set<Weekday>) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("habit.schedule", comment: "Заголовок расписания")
        view.backgroundColor = .ypWhite
        setupTableView()
        setupDoneButton()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeekdayCell")
        tableView.backgroundColor = .clear
        tableView.separatorColor = .ypLightGray
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.separatorInset, bottom: 0, right: Constants.separatorInset)
        tableView.rowHeight = Constants.rowHeight
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        let preferredHeight = tableView.heightAnchor.constraint(equalToConstant: Constants.rowHeight * CGFloat(Weekday.allCases.count))
        preferredHeight.priority = .defaultHigh
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topInset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.rowHeight * CGFloat(Weekday.allCases.count)),
            preferredHeight
        ])
    }

    private func setupDoneButton() {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("schedule.done", comment: "Сохранить расписание"), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: Constants.buttonTopInset),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomInset),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - Actions

    @objc private func done() {
        onDone?(selectedDays)
        navigationController?.popViewController(animated: true)
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        guard let day = Weekday(rawValue: sender.tag) else { return }
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { .leastNonzeroMagnitude }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { .leastNonzeroMagnitude }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell", for: indexPath)
        let day = Weekday.allCases[indexPath.row]
        let keys = ["weekday.monday", "weekday.tuesday", "weekday.wednesday", "weekday.thursday", "weekday.friday", "weekday.saturday", "weekday.sunday"]
        var content = cell.defaultContentConfiguration()
        content.text = NSLocalizedString(keys[indexPath.row], comment: "День недели")
        content.textProperties.color = .ypBlack
        cell.contentConfiguration = content
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
        daySwitch.isOn = selectedDays.contains(day)
        daySwitch.tag = day.rawValue
        daySwitch.accessibilityLabel = content.text
        daySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = daySwitch
        return cell
    }
}
