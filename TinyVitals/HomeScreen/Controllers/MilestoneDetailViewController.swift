//
//  MilestoneDetailViewController.swift
//  TinyVitals
//

import UIKit
import AVFoundation

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
    private var videoPaths: [String: String] = [:]
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
            title: "Done", style: .plain,
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

                // Load video paths
                videoPaths = [:]
                for dto in dtos {
                    if let path = dto.video_path {
                        videoPaths[dto.milestone_title] = path
                    }
                }

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
                // Delete video from storage if it exists
                if let videoPath = videoPaths[milestone.title] {
                    try? await MilestoneTrackingService.shared.deleteVideo(path: videoPath)
                }

                try await MilestoneTrackingService.shared.unmarkAchieved(
                    childId: childId,
                    title: milestone.title
                )
                achievedTitles.remove(milestone.title)
                achievedDates.removeValue(forKey: milestone.title)
                videoPaths.removeValue(forKey: milestone.title)
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

    // MARK: - Video Actions

    private func showAchievedActions(for milestone: Milestone) {
        Haptics.impact(.light)

        let hasVideo = videoPaths[milestone.title] != nil

        let sheet = UIAlertController(
            title: milestone.title,
            message: hasVideo ? "This milestone has a recorded memory." : "Would you like to record a memory?",
            preferredStyle: .actionSheet
        )

        if hasVideo {
            // Watch memory
            sheet.addAction(UIAlertAction(
                title: "Watch Memory",
                style: .default
            ) { [weak self] _ in
                self?.playVideo(for: milestone)
            })

            // Re-record
            sheet.addAction(UIAlertAction(
                title: "Re-record Memory",
                style: .default
            ) { [weak self] _ in
                self?.presentVideoRecorder(for: milestone)
            })
        } else {
            // Record memory
            sheet.addAction(UIAlertAction(
                title: "Record Memory",
                style: .default
            ) { [weak self] _ in
                self?.presentVideoRecorder(for: milestone)
            })
        }

        // Unmark
        sheet.addAction(UIAlertAction(
            title: "Unmark Milestone",
            style: .destructive
        ) { [weak self] _ in
            self?.showUnmarkConfirmation(for: milestone)
        })

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(sheet, animated: true)
    }

    private func presentVideoRecorder(for milestone: Milestone) {
        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showRecorder(for: milestone)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.showRecorder(for: milestone)
                    } else {
                        self?.showPermissionAlert()
                    }
                }
            }

        case .denied, .restricted:
            showPermissionAlert()

        @unknown default:
            break
        }
    }

    private func showRecorder(for milestone: Milestone) {
        let recorder = MilestoneVideoRecorderViewController()
        recorder.delegate = self
        recorder.modalPresentationStyle = .fullScreen

        // Store which milestone we're recording for
        objc_setAssociatedObject(
            recorder,
            &AssociatedKeys.milestoneTitle,
            milestone.title,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        present(recorder, animated: true)
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "TinyVitals needs camera access to record milestone memories. Please enable it in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func playVideo(for milestone: Milestone) {
        guard let path = videoPaths[milestone.title] else { return }

        Task {
            do {
                let signedURL = try await MilestoneTrackingService.shared.getSignedVideoURL(path: path)

                await MainActor.run {
                    let playerVC = MilestoneVideoPlayerViewController(
                        videoURL: signedURL,
                        milestoneName: milestone.title
                    )

                    playerVC.onDelete = { [weak self] in
                        self?.deleteVideo(for: milestone)
                    }

                    playerVC.modalPresentationStyle = .pageSheet
                    if let sheet = playerVC.sheetPresentationController {
                        sheet.detents = [.medium(), .large()]
                        sheet.prefersGrabberVisible = true
                    }

                    self.present(playerVC, animated: true)
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Playback Error",
                        message: "Could not load the video. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func deleteVideo(for milestone: Milestone) {
        guard let path = videoPaths[milestone.title] else { return }

        Task {
            do {
                try await MilestoneTrackingService.shared.deleteVideo(path: path)
                try await MilestoneTrackingService.shared.updateVideoPath(
                    childId: childId,
                    title: milestone.title,
                    videoPath: nil
                )

                videoPaths.removeValue(forKey: milestone.title)

                await MainActor.run {
                    Haptics.notification(.success)
                    tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Could not delete the video.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func uploadAndSaveVideo(title: String, videoURL: URL) {
        // Show a loading indicator
        let hud = UIActivityIndicatorView(style: .large)
        hud.color = brandPink
        hud.center = view.center
        hud.startAnimating()
        view.addSubview(hud)
        view.isUserInteractionEnabled = false

        Task {
            do {
                let videoData = try Data(contentsOf: videoURL)
                let storagePath = try await MilestoneTrackingService.shared.uploadVideo(
                    childId: childId,
                    title: title,
                    videoData: videoData
                )

                try await MilestoneTrackingService.shared.updateVideoPath(
                    childId: childId,
                    title: title,
                    videoPath: storagePath
                )

                videoPaths[title] = storagePath

                await MainActor.run {
                    hud.removeFromSuperview()
                    self.view.isUserInteractionEnabled = true
                    Haptics.notification(.success)
                    tableView.reloadData()
                }
            } catch {
                print("❌ Video upload failed:", error)
                await MainActor.run {
                    hud.removeFromSuperview()
                    self.view.isUserInteractionEnabled = true

                    let alert = UIAlertController(
                        title: "Upload Failed",
                        message: "Could not upload the video.\n\n\(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - Associated Keys

private struct AssociatedKeys {
    static var milestoneTitle: UInt8 = 0
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
        let hasVideo = videoPaths[milestone.title] != nil

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
            // Achieved — show date + video badge
            content.image = UIImage(systemName: "checkmark.circle.fill")
            content.imageProperties.tintColor = brandBlue
            content.textProperties.color = .label
            content.textProperties.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 15, weight: .medium))

            if let date = achievedDates[milestone.title] {
                let dateStr = dateFmt.string(from: date)
                content.secondaryText = "Achieved on \(dateStr)"
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

        // Age accessory — add button for achieved milestones
        let accessoryStack = UIStackView()
        accessoryStack.axis = .horizontal
        accessoryStack.spacing = 12
        accessoryStack.alignment = .center

        if isAchieved {
            let actionButton = UIButton(type: .system)
            var config = UIButton.Configuration.tinted()
            config.cornerStyle = .capsule
            config.imagePadding = 6
            
            if hasVideo {
                config.title = "Watch"
                config.image = UIImage(systemName: "play.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14))
                config.baseForegroundColor = brandPink
                config.baseBackgroundColor = brandPink
                
                actionButton.addAction(UIAction { [weak self] _ in
                    self?.playVideo(for: milestone)
                }, for: .touchUpInside)
            } else {
                config.title = "Record"
                config.image = UIImage(systemName: "video.badge.plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14))
                config.baseForegroundColor = .systemBlue
                config.baseBackgroundColor = .systemBlue
                
                actionButton.addAction(UIAction { [weak self] _ in
                    self?.presentVideoRecorder(for: milestone)
                }, for: .touchUpInside)
            }
            
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 13, weight: .bold)
                return outgoing
            }
            
            actionButton.configuration = config
            accessoryStack.addArrangedSubview(actionButton)
        }

        let ageLabel = UILabel()
        ageLabel.text = ageText
        ageLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        ageLabel.textColor = isCurrent ? brandPink : .secondaryLabel
        ageLabel.sizeToFit()
        accessoryStack.addArrangedSubview(ageLabel)

        accessoryStack.setNeedsLayout()
        accessoryStack.layoutIfNeeded()
        let size = accessoryStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        accessoryStack.frame = CGRect(origin: .zero, size: size)

        cell.accessoryView = accessoryStack

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let milestone = milestones[indexPath.row]

        if achievedTitles.contains(milestone.title) {
            showAchievedActions(for: milestone)
        } else {
            showMarkSheet(for: milestone)
        }
    }
}

// MARK: - Video Recorder Delegate

extension MilestoneDetailViewController: MilestoneVideoRecorderDelegate {

    func videoRecorderDidFinish(_ controller: MilestoneVideoRecorderViewController, videoURL: URL) {
        guard let title = objc_getAssociatedObject(
            controller,
            &AssociatedKeys.milestoneTitle
        ) as? String else { return }

        uploadAndSaveVideo(title: title, videoURL: videoURL)
    }

    func videoRecorderDidCancel(_ controller: MilestoneVideoRecorderViewController) {
        // Nothing to do
    }
}
