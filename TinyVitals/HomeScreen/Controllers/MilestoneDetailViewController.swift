//
//  MilestoneDetailViewController.swift
//  TinyVitals
//

import UIKit

final class MilestoneDetailViewController: UIViewController {

    // MARK: - Properties

    private let dob: Date
    private let childId: UUID
    private let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
    private let brandBlue = UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 1)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var milestones: [Milestone] { MilestoneService.milestones }
    private var achievedTitles: Set<String> = []
    private var achievedDates: [String: Date] = [:]
    private lazy var snap: MilestoneSnapshot = MilestoneService.snapshot(achievedTitles: achievedTitles, achievedDates: achievedDates)

    /// Called when the user marks/unmarks a milestone so the home screen can refresh.
    var onDismiss: (() -> Void)?

    // MARK: - Init

    init(dob: Date, childId: UUID) {
        self.dob = dob
        self.childId = childId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Milestones"
        setupNav()
        setupTable()
        loadAchievedMilestones()
    }

    // MARK: - Nav

    private func setupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done", style: .done,
            target: self, action: #selector(dismissSelf)
        )
        navigationItem.rightBarButtonItem?.tintColor = brandPink
    }

    @objc private func dismissSelf() {
        onDismiss?()
        dismiss(animated: true)
    }

    // MARK: - Data Loading

    private func loadAchievedMilestones() {
        Task {
            do {
                let dtos = try await MilestoneTrackingService.shared.fetchAchieved(childId: childId)
                achievedTitles = Set(dtos.map { $0.milestone_title })
                achievedDates = Dictionary(uniqueKeysWithValues: dtos.map { ($0.milestone_title, $0.achieved_at) })
                snap = MilestoneService.snapshot(achievedTitles: achievedTitles, achievedDates: achievedDates)

                await MainActor.run {
                    tableView.tableHeaderView = buildHeader()
                    tableView.reloadData()
                    scrollToCurrent()
                }
            } catch {
                // Silently fall back to empty state
            }
        }
    }

    // MARK: - Header

    private func buildHeader() -> UIView {
        guard let current = snap.current else { return UIView() }

        let wrapper = UIView()

        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(card)

        // SF Symbol icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: current.category.icon, withConfiguration: iconConfig))
        iconView.tintColor = current.category.color
        iconView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconView)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = current.title
        titleLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 20, weight: .bold))
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = UILabel()
        let mo = current.ageMonths
        let ageStr: String
        if mo >= 12 {
            let y = mo / 12; let r = mo % 12
            ageStr = r > 0 ? "\(y)y \(r)m" : "\(y) year\(y > 1 ? "s" : "")"
        } else {
            ageStr = "\(mo) months"
        }
        subtitleLabel.text = "\(current.category.rawValue) · Expected by \(ageStr)"
        subtitleLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 13, weight: .regular))
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)

        // Ring
        let ring = CircularProgressRing()
        ring.trackColor = .systemGray5
        ring.progressColor = brandPink
        ring.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(ring)

        // Percentage
        let pctLabel = UILabel()
        pctLabel.text = "\(Int(snap.progress * 100))%"
        pctLabel.font = UIFontMetrics.default.scaledFont(for: .monospacedDigitSystemFont(ofSize: 12, weight: .bold))
        pctLabel.textColor = brandPink
        pctLabel.textAlignment = .center
        pctLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pctLabel)

        // Count
        let countLabel = UILabel()
        countLabel.text = "\(snap.achievedCount) of \(snap.totalCount) achieved"
        countLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 12))
        countLabel.textColor = .tertiaryLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(countLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -4),

            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 34),
            iconView.heightAnchor.constraint(equalToConstant: 34),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: ring.leadingAnchor, constant: -10),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: ring.leadingAnchor, constant: -10),

            ring.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            ring.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            ring.widthAnchor.constraint(equalToConstant: 44),
            ring.heightAnchor.constraint(equalToConstant: 44),

            pctLabel.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            pctLabel.centerYAnchor.constraint(equalTo: ring.centerYAnchor),

            countLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            countLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            countLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ring.setProgress(CGFloat(self.snap.progress), animated: true)
        }

        // Size it
        wrapper.setNeedsLayout()
        wrapper.layoutIfNeeded()
        let size = wrapper.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        wrapper.frame = CGRect(origin: .zero, size: size)
        return wrapper
    }

    // MARK: - Table

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .systemGroupedBackground
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = buildHeader()
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func scrollToCurrent() {
        guard let current = snap.current else { return }
        if let idx = milestones.firstIndex(where: { $0.title == current.title && $0.ageMonths == current.ageMonths }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.tableView.scrollToRow(at: IndexPath(row: idx, section: 0), at: .middle, animated: true)
            }
        }
    }

    // MARK: - Mark / Unmark Actions

    private func showMarkSheet(for milestone: Milestone) {
        Haptics.impact(.light)

        let sheet = UIViewController()
        sheet.view.backgroundColor = .systemBackground

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Mark as Achieved"
        titleLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 20, weight: .bold))
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sheet.view.addSubview(titleLabel)

        // Milestone name
        let nameLabel = UILabel()
        nameLabel.text = milestone.title
        nameLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 15, weight: .medium))
        nameLabel.textColor = .secondaryLabel
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        sheet.view.addSubview(nameLabel)

        // Date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.maximumDate = Date()
        datePicker.tintColor = brandPink
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        sheet.view.addSubview(datePicker)

        // Save button
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Mark as Achieved", for: .normal)
        saveButton.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        saveButton.backgroundColor = brandPink
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 14
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        sheet.view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sheet.view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: sheet.view.centerXAnchor),

            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            nameLabel.centerXAnchor.constraint(equalTo: sheet.view.centerXAnchor),

            datePicker.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: sheet.view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: sheet.view.trailingAnchor, constant: -16),

            saveButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: sheet.view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: sheet.view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(lessThanOrEqualTo: sheet.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        // Action
        saveButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let selectedDate = datePicker.date
            sheet.dismiss(animated: true) {
                self.performMark(milestone: milestone, date: selectedDate)
            }
        }, for: .touchUpInside)

        sheet.modalPresentationStyle = .pageSheet
        if let sheetCtrl = sheet.sheetPresentationController {
            sheetCtrl.detents = [.large()]
            sheetCtrl.prefersGrabberVisible = true
        }

        present(sheet, animated: true)
    }

    private func performMark(milestone: Milestone, date: Date) {
        Task {
            do {
                try await MilestoneTrackingService.shared.markAchieved(
                    childId: childId,
                    title: milestone.title,
                    achievedAt: date
                )
                achievedTitles.insert(milestone.title)
                achievedDates[milestone.title] = date
                snap = MilestoneService.snapshot(achievedTitles: achievedTitles, achievedDates: achievedDates)

                await MainActor.run {
                    Haptics.impact(.medium)
                    tableView.tableHeaderView = buildHeader()
                    tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "Error", message: "Could not save the milestone.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func showUnmarkConfirmation(for milestone: Milestone) {
        Haptics.impact(.light)
        let alert = UIAlertController(
            title: "Unmark Milestone",
            message: "Remove \"\(milestone.title)\" from achieved milestones?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Unmark", style: .destructive) { [weak self] _ in
            self?.performUnmark(milestone: milestone)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func performUnmark(milestone: Milestone) {
        Task {
            do {
                try await MilestoneTrackingService.shared.unmarkAchieved(
                    childId: childId,
                    title: milestone.title
                )
                achievedTitles.remove(milestone.title)
                achievedDates.removeValue(forKey: milestone.title)
                snap = MilestoneService.snapshot(achievedTitles: achievedTitles, achievedDates: achievedDates)

                await MainActor.run {
                    Haptics.impact(.light)
                    tableView.tableHeaderView = buildHeader()
                    tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "Error", message: "Could not unmark the milestone.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - DataSource & Delegate

extension MilestoneDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        milestones.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Developmental Timeline"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let milestone = milestones[indexPath.row]
        let isAchieved = achievedTitles.contains(milestone.title)
        let isCurrent = milestone.title == snap.current?.title && milestone.ageMonths == snap.current?.ageMonths && !isAchieved

        // Use the built-in cell content configuration (Apple HIG standard)
        var content = cell.defaultContentConfiguration()

        content.text = milestone.title
        content.secondaryTextProperties.numberOfLines = 0

        // Age text
        let mo = milestone.ageMonths
        let ageText: String
        if mo >= 12 {
            let y = mo / 12; let r = mo % 12
            ageText = r > 0 ? "\(y)y \(r)m" : "\(y)y"
        } else {
            ageText = "\(mo)m"
        }

        // Date formatter for achieved dates
        let dateFmt = DateFormatter()
        dateFmt.dateStyle = .medium
        dateFmt.timeStyle = .none

        if isAchieved {
            // Achieved — show date
            content.image = UIImage(systemName: "checkmark.circle.fill")
            content.imageProperties.tintColor = brandBlue
            content.textProperties.color = .label
            content.textProperties.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 15, weight: .medium))
            if let date = achievedDates[milestone.title] {
                content.secondaryText = "Achieved on \(dateFmt.string(from: date))"
            } else {
                content.secondaryText = milestone.description
            }
            content.secondaryTextProperties.color = brandBlue
            content.secondaryTextProperties.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 13))
            cell.backgroundColor = brandBlue.withAlphaComponent(0.06)
        } else if isCurrent {
            // Current — next expected, highlighted
            content.image = UIImage(systemName: "star.fill")
            content.imageProperties.tintColor = brandPink
            content.textProperties.color = brandPink
            content.textProperties.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 15, weight: .bold))
            content.secondaryText = milestone.description
            content.secondaryTextProperties.color = brandPink.withAlphaComponent(0.7)
            content.secondaryTextProperties.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 13))
            cell.backgroundColor = brandPink.withAlphaComponent(0.06)
        } else {
            // Upcoming
            content.image = UIImage(systemName: "circle")
            content.imageProperties.tintColor = .systemGray4
            content.textProperties.color = .label
            content.textProperties.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 15, weight: .regular))
            content.secondaryText = milestone.description
            content.secondaryTextProperties.color = .secondaryLabel
            content.secondaryTextProperties.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 13))
            cell.backgroundColor = .secondarySystemGroupedBackground
        }

        cell.contentConfiguration = content
        cell.selectionStyle = .default

        // Age accessory label
        let ageLabel = UILabel()
        ageLabel.text = ageText
        ageLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        ageLabel.textColor = isCurrent ? brandPink : .secondaryLabel
        ageLabel.sizeToFit()
        cell.accessoryView = ageLabel

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let milestone = milestones[indexPath.row]

        if achievedTitles.contains(milestone.title) {
            showUnmarkConfirmation(for: milestone)
        } else {
            showMarkSheet(for: milestone)
        }
    }
}
