//
//  RecordSummaryViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import UIKit
import Lottie

final class RecordSummaryViewController: UIViewController {

    private let record: MedicalFile
    private let localFileURL: URL

    private var sections: [MedicalSection] = []
    private var rawOCRText: String = ""

    // MARK: - Brand Colors (only two)
    static let brandPink  = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
    static let brandBlue  = UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 1)

    // MARK: - Section icon mapping (colors alternate between the two brand colors)

    private static let sectionIcons: [String: String] = [
        "Diagnosis":        "stethoscope",
        "Assessment":       "list.clipboard",
        "Impression":       "lightbulb",
        "Chief Complaint":  "exclamationmark.bubble",
        "Symptoms":         "heart.text.clipboard",
        "Imaging":          "xray",
        "Investigation":    "flask",
        "Vitals":           "waveform.path.ecg.rectangle",
        "Treatment":        "pills",
        "Medications":      "pill",
        "Prescription":     "doc.text",
        "Plan":             "checklist",
        "Progress":         "chart.line.uptrend.xyaxis",
        "Hospital Course":  "building.2",
        "Discharge":        "arrow.right.doc.on.clipboard",
        "Overview":         "doc.richtext",
    ]

    private static func icon(for title: String) -> String {
        sectionIcons[title] ?? "text.page"
    }

    /// Alternates between pink and blue based on section index
    private func brandColor(for sectionIndex: Int) -> UIColor {
        sectionIndex % 2 == 0 ? Self.brandPink : Self.brandBlue
    }

    // MARK: - UI Elements

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .systemGroupedBackground
        tv.showsVerticalScrollIndicator = false
        tv.allowsSelection = false
        return tv
    }()

    private var lottieView: LottieAnimationView?

    private let loadingContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let loadingLabel: UILabel = {
        let l = UILabel()
        l.text = "Analyzing document…"
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init

    init(record: MedicalFile, localFileURL: URL) {
        self.record = record
        self.localFileURL = localFileURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(dismissSelf)
        )
        navigationItem.rightBarButtonItem?.tintColor = .tertiaryLabel

        setupTableView()
        setupLoadingState()
        generateSummary()
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    // MARK: - Table View Setup

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SummarySectionHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: SummarySectionHeaderView.reuseID)
        tableView.register(SummaryItemCell.self,
                           forCellReuseIdentifier: SummaryItemCell.reuseID)
        tableView.alpha = 0

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tableView.tableHeaderView = buildTableHeader()
        tableView.tableFooterView = buildTableFooter()
    }

    // MARK: - Header (gradient card)

    private func buildTableHeader() -> UIView {
        let wrapper = UIView()

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true
        wrapper.addSubview(card)

        let gradient = CAGradientLayer()
        gradient.colors = [Self.brandPink.cgColor, Self.brandBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 110)
        card.layer.insertSublayer(gradient, at: 0)

        // Sparkle
        let sparkle = UIImageView(image: UIImage(systemName: "sparkles"))
        sparkle.tintColor = .white
        sparkle.contentMode = .scaleAspectFit
        sparkle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(sparkle)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Summary"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = record.title
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .white.withAlphaComponent(0.85)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)

        // Watermark icon
        let bgIcon = UIImageView(image: UIImage(systemName: "doc.text.magnifyingglass"))
        bgIcon.tintColor = .white.withAlphaComponent(0.12)
        bgIcon.contentMode = .scaleAspectFit
        bgIcon.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bgIcon)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            card.heightAnchor.constraint(equalToConstant: 110),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -4),

            sparkle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            sparkle.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            sparkle.widthAnchor.constraint(equalToConstant: 24),
            sparkle.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: sparkle.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: sparkle.centerYAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: sparkle.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: bgIcon.leadingAnchor, constant: -12),

            bgIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            bgIcon.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
            bgIcon.widthAnchor.constraint(equalToConstant: 56),
            bgIcon.heightAnchor.constraint(equalToConstant: 56),
        ])

        wrapper.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 130)
        wrapper.setNeedsLayout()
        wrapper.layoutIfNeeded()
        let fittingSize = CGSize(width: view.bounds.width,
                                  height: UIView.layoutFittingCompressedSize.height)
        wrapper.frame.size.height = wrapper.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return wrapper
    }

    // MARK: - Footer (Writing Tools button + Disclaimer)

    private func buildTableFooter() -> UIView {
        let container = UIView()

        // Disclaimer
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        icon.tintColor = .systemYellow
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let disclaimerTitle = UILabel()
        disclaimerTitle.text = "Disclaimer"
        disclaimerTitle.font = .preferredFont(forTextStyle: .caption1)
        disclaimerTitle.textColor = .secondaryLabel
        disclaimerTitle.translatesAutoresizingMaskIntoConstraints = false

        let disclaimerBody = UILabel()
        if #available(iOS 18.0, *) {
            #if canImport(FoundationModels)
            disclaimerBody.text = "This summary is generated securely on-device using Apple Intelligence. It is an AI-generated layout and is not a substitute for professional medical advice. Always verify with original reports."
            #else
            disclaimerBody.text = "This summary is generated using on-device OCR. It is not a substitute for professional medical advice. Always verify with original reports."
            #endif
        } else {
            disclaimerBody.text = "This summary is generated using on-device OCR. It is not a substitute for professional medical advice. Always verify with original reports."
        }
        disclaimerBody.font = .preferredFont(forTextStyle: .caption2)
        disclaimerBody.textColor = .tertiaryLabel
        disclaimerBody.numberOfLines = 0
        disclaimerBody.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(card)
        card.addSubview(icon)
        card.addSubview(disclaimerTitle)
        card.addSubview(disclaimerBody)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),

            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),

            disclaimerTitle.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            disclaimerTitle.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),

            disclaimerBody.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 6),
            disclaimerBody.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            disclaimerBody.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            disclaimerBody.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])

        container.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        container.setNeedsLayout()
        container.layoutIfNeeded()
        let fittingSize = CGSize(width: view.bounds.width,
                                  height: UIView.layoutFittingCompressedSize.height)
        container.frame.size.height = container.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return container
    }


    // MARK: - Loading State

    private func setupLoadingState() {
        view.addSubview(loadingContainer)

        let animation = LottieAnimation.named("Stars")
        let loader = LottieAnimationView(animation: animation)
        loader.loopMode = .loop
        loader.contentMode = .scaleAspectFit
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.play()
        self.lottieView = loader

        loadingContainer.addSubview(loader)
        loadingContainer.addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            loadingContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),

            loader.topAnchor.constraint(equalTo: loadingContainer.topAnchor),
            loader.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            loader.widthAnchor.constraint(equalToConstant: 120),
            loader.heightAnchor.constraint(equalToConstant: 120),

            loadingLabel.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 12),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            loadingLabel.bottomAnchor.constraint(equalTo: loadingContainer.bottomAnchor),
        ])
    }

    private func hideLoadingState() {
        UIView.animate(withDuration: 0.3) {
            self.loadingContainer.alpha = 0
        } completion: { _ in
            self.lottieView?.stop()
            self.loadingContainer.removeFromSuperview()
            self.lottieView = nil
        }
    }

    // MARK: - Summary Generation

    private func generateSummary() {
        Task {
            let url = localFileURL
            // First run OCR extract in the background
            let text = await Task.detached(priority: .userInitiated) {
                RecordTextExtractor.extract(from: url)
            }.value

            guard text.count > 80 else {
                await MainActor.run {
                    self.hideLoadingState()
                    self.showEmptyState(
                        icon: "doc.questionmark",
                        title: "Couldn't Read Document",
                        message: "This document appears blank or partially filled.\n\nTry uploading a typed or scanned PDF report for best results."
                    )
                }
                return
            }

            self.rawOCRText = text

            // Run FoundationModel LLM on device
            let parsed = await RecordSummarizer.summarizeAsync(text: text)

            await MainActor.run {
                self.hideLoadingState()

                guard !parsed.isEmpty else {
                    self.showEmptyState(
                        icon: "text.magnifyingglass",
                        title: "No Structured Data Found",
                        message: "We couldn't extract structured medical information from this document.\n\nForm-style documents, tables, or low-quality scans may not be supported."
                    )
                    return
                }

                self.sections = parsed
                UIView.animate(withDuration: 0.35) {
                    self.tableView.alpha = 1
                }
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Empty State

    private func showEmptyState(icon: String, title: String, message: String) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .tertiaryLabel
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let bodyLabel = UILabel()
        bodyLabel.text = message
        bodyLabel.font = .preferredFont(forTextStyle: .subheadline)
        bodyLabel.textColor = .tertiaryLabel
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(bodyLabel)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),

            iconView.topAnchor.constraint(equalTo: container.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        container.alpha = 0
        UIView.animate(withDuration: 0.35) { container.alpha = 1 }
    }
}

// MARK: - UITableViewDataSource

extension RecordSummaryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        min(sections[section].items.count, 8)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SummaryItemCell.reuseID,
                                                  for: indexPath) as! SummaryItemCell
        let color = brandColor(for: indexPath.section)
        cell.configure(text: sections[indexPath.section].items[indexPath.row],
                       accentColor: color)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RecordSummaryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SummarySectionHeaderView.reuseID) as! SummarySectionHeaderView
        let s = sections[section]
        let color = brandColor(for: section)
        header.configure(title: s.title,
                         iconName: Self.icon(for: s.title),
                         color: color)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        4
    }
}


// MARK: - Section Header (HIG: left-aligned label, no truncation)

private final class SummarySectionHeaderView: UITableViewHeaderFooterView {

    static let reuseID = "SummarySectionHeaderView"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.numberOfLines = 0           // ← no truncation
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, iconName: String, color: UIColor) {
        let cleaned = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .first ?? title
        titleLabel.text = cleaned
        titleLabel.textColor = color
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = color
    }
}

// MARK: - Item Cell (colored bullet + text)

private final class SummaryItemCell: UITableViewCell {

    static let reuseID = "SummaryItemCell"

    private let bulletView = UIView()
    private let itemLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .secondarySystemGroupedBackground

        bulletView.layer.cornerRadius = 3
        bulletView.translatesAutoresizingMaskIntoConstraints = false

        itemLabel.font = .preferredFont(forTextStyle: .subheadline)
        itemLabel.textColor = .label
        itemLabel.numberOfLines = 0
        itemLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(bulletView)
        contentView.addSubview(itemLabel)

        NSLayoutConstraint.activate([
            bulletView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bulletView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            bulletView.widthAnchor.constraint(equalToConstant: 6),
            bulletView.heightAnchor.constraint(equalToConstant: 6),

            itemLabel.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: 10),
            itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            itemLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String, accentColor: UIColor) {
        bulletView.backgroundColor = accentColor

        var cleaned = text
        while cleaned.hasPrefix("•") || cleaned.hasPrefix("·") || cleaned.hasPrefix("-") || cleaned.hasPrefix(":") {
            cleaned = String(cleaned.dropFirst())
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        while cleaned.contains("  ") {
            cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        }
        itemLabel.text = cleaned
    }
}
