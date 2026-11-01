//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Капитонов Константин on 03.11.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Constants

    private enum Constants {
        static let addButtonSize: CGFloat = 42
        static let titleFontSize: CGFloat = 34
        static let titleLeadingInset: CGFloat = 10
        static let titleTopInset: CGFloat = 1
        static let searchIconLeadingInset: CGFloat = 8
        static let searchIconSize: CGFloat = 16
        static let searchIconContainerWidth: CGFloat = 30
        static let searchHeight: CGFloat = 36
        static let searchFontSize: CGFloat = 17
        static let searchCornerRadius: CGFloat = 10
        static let searchTrailingInset: CGFloat = 10
        static let searchTopInset: CGFloat = 7
        static let emptyLabelFontSize: CGFloat = 12
        static let emptyStateSpacing: CGFloat = 8
        static let emptyImageSize: CGFloat = 80
        static let collectionTopInset: CGFloat = 12
        static let collectionHorizontalInset: CGFloat = 16
        static let collectionColumnCount: CGFloat = 2
        static let collectionItemSpacing: CGFloat = 9
        static let collectionLineSpacing: CGFloat = 16
        static let collectionItemHeight: CGFloat = 132
        static let collectionHeaderHeight: CGFloat = 48
    }

    // MARK: - Properties

	private let addButton = UIButton(type: .system)
    private let datePicker = UIDatePicker()
    private let titleLabel = UILabel()
    private let searchField = UITextField()
	private let emptyImageView = UIImageView(image: UIImage.emptyTrackers)
    private let emptyLabel = UILabel()
	
	private var categories: [TrackerCategory] = []
	private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private let defaultCategoryName = NSLocalizedString("habit.default_category", comment: "Категория новых привычек")
    private var emptyState: UIStackView!
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
        setupTitle()
        setupSearch()
        setupEmptyState()
        setupCollectionView()
        categories = [TrackerCategory(name: defaultCategoryName, trackers: [])]
        updateVisibleTrackers()
    }

    // MARK: - Setup

    private func setupView() {
		view.backgroundColor = UIColor.ypWhite
    }

    private func setupNavigation() {
        addButton.setImage(UIImage.addTracker.withRenderingMode(.alwaysTemplate), for: .normal)
		addButton.tintColor = .ypBlack
        addButton.addTarget(self, action: #selector(showNewHabit), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(filtersChanged), for: .valueChanged)

        let addItem = UIBarButtonItem(customView: addButton)
        let dateItem = UIBarButtonItem(customView: datePicker)
        if #available(iOS 26.0, *) {
            addItem.hidesSharedBackground = true
            dateItem.hidesSharedBackground = true
        }
        navigationItem.leftBarButtonItem = addItem
        navigationItem.rightBarButtonItem = dateItem

        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: Constants.addButtonSize),
            addButton.heightAnchor.constraint(equalToConstant: Constants.addButtonSize)
        ])
    }

    private func setupTitle() {
        titleLabel.text = NSLocalizedString("trackers.title", comment: "Заголовок экрана трекеров")
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
		titleLabel.textColor = UIColor.ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.titleLeadingInset),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.titleTopInset)
        ])
    }

    private func setupSearch() {
		let searchIcon = UIImageView(image: UIImage.search)
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: Constants.searchIconLeadingInset, y: 0, width: Constants.searchIconSize, height: Constants.searchHeight)
        let searchIconContainer = UIView(frame: CGRect(x: 0, y: 0, width: Constants.searchIconContainerWidth, height: Constants.searchHeight))
        searchIconContainer.addSubview(searchIcon)

        searchField.placeholder = NSLocalizedString("trackers.search", comment: "Подсказка поля поиска")
        searchField.font = .systemFont(ofSize: Constants.searchFontSize, weight: .regular)
		searchField.textColor = UIColor.ypBlack
		searchField.backgroundColor = UIColor.ypBackground
        searchField.layer.cornerRadius = Constants.searchCornerRadius
        searchField.leftView = searchIconContainer
		searchField.leftViewMode = .always
        searchField.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchField)

        NSLayoutConstraint.activate([
			searchField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.searchTrailingInset),
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.searchTopInset),
            searchField.heightAnchor.constraint(equalToConstant: Constants.searchHeight)
        ])
    }

    private func setupEmptyState() {
        emptyImageView.contentMode = .scaleAspectFit
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.text = NSLocalizedString("trackers.empty", comment: "Пустой список трекеров")
        emptyLabel.font = .systemFont(ofSize: Constants.emptyLabelFontSize, weight: .medium)
        emptyLabel.textColor = UIColor.ypBlack
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [emptyImageView, emptyLabel])
        emptyState = stackView
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.emptyStateSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            emptyImageView.widthAnchor.constraint(equalToConstant: Constants.emptyImageSize),
            emptyImageView.heightAnchor.constraint(equalToConstant: Constants.emptyImageSize),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: Constants.collectionTopInset),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.collectionHorizontalInset),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.collectionHorizontalInset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions and tracker state

    @objc private func filtersChanged() { updateVisibleTrackers() }

    @objc private func showNewHabit() {
        let controller = NewHabitViewController()
        controller.onCreate = { [weak self] tracker in
            guard let self else { return }
            self.categories = self.categories.map { category in
                guard category.name == self.defaultCategoryName else { return category }
                return TrackerCategory(name: category.name, trackers: category.trackers + [tracker])
            }
            self.updateVisibleTrackers()
        }
        let navigation = UINavigationController(rootViewController: controller)
        present(navigation, animated: true)
    }

    private func updateVisibleTrackers() {
        let calendarDay = Calendar.current.component(.weekday, from: datePicker.date)
        let weekday = Weekday(rawValue: calendarDay)
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.schedule.isEmpty || weekday.map { tracker.schedule.contains($0) } == true
            }
            return trackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: trackers)
        }
        emptyState.isHidden = !visibleCategories.isEmpty
        collectionView.isHidden = visibleCategories.isEmpty
        collectionView.reloadData()
    }

    private func toggleCompletion(for tracker: Tracker) {
        let calendar = Calendar.current
        guard calendar.startOfDay(for: datePicker.date) <= calendar.startOfDay(for: Date()) else { return }
        if let index = completedTrackers.firstIndex(where: { $0.trackerID == tracker.id && calendar.isDate($0.date, inSameDayAs: datePicker.date) }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(trackerID: tracker.id, date: calendar.startOfDay(for: datePicker.date)))
        }
        collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { visibleCategories.count }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { visibleCategories[section].trackers.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as! TrackerCell
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let records = completedTrackers.filter { $0.trackerID == tracker.id }
        let completed = records.contains { Calendar.current.isDate($0.date, inSameDayAs: datePicker.date) }
        let canComplete = Calendar.current.startOfDay(for: datePicker.date) <= Calendar.current.startOfDay(for: Date())
        cell.configure(tracker: tracker, count: records.count, completed: completed, canComplete: canComplete)
        cell.onCompletionTap = { [weak self] in self?.toggleCompletion(for: tracker) }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier, for: indexPath) as! TrackerCategoryHeader
        header.configure(title: visibleCategories[indexPath.section].name)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: floor((collectionView.bounds.width - Constants.collectionItemSpacing) / Constants.collectionColumnCount), height: Constants.collectionItemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { Constants.collectionItemSpacing }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { Constants.collectionLineSpacing }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { CGSize(width: collectionView.bounds.width, height: Constants.collectionHeaderHeight) }
}
