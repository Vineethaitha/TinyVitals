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
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Section icon + color mapping

    private static let sectionMeta: [String: (icon: String, color: UIColor)] = [
        "Diagnosis":        ("stethoscope",                  UIColor.systemPink),
        "Assessment":       ("list.clipboard",               UIColor.systemPink),
        "Impression":       ("lightbulb",                    UIColor.systemPink),
        "Chief Complaint":  ("exclamationmark.bubble",       UIColor.systemOrange),
        "Symptoms":         ("heart.text.clipboard",         UIColor.systemRed),
        "Imaging":          ("xray",                         UIColor.systemIndigo),
        "Investigation":    ("flask",                        UIColor.systemIndigo),
        "Vitals":           ("waveform.path.ecg.rectangle",  UIColor.systemGreen),
        "Treatment":        ("pills",                        UIColor.systemBlue),
        "Medications":      ("pill",                         UIColor.systemBlue),
        "Prescription":     ("doc.text",                     UIColor.systemBlue),
        "Plan":             ("checklist",                    UIColor.systemTeal),
        "Progress":         ("chart.line.uptrend.xyaxis",    UIColor.systemCyan),
        "Hospital Course":  ("building.2",                   UIColor.systemCyan),
        "Discharge":        ("arrow.right.doc.on.clipboard", UIColor.systemMint),
        "Overview":         ("doc.richtext",                 UIColor.secondaryLabel),
    ]

    private static func meta(for title: String) -> (icon: String, color: UIColor) {
        sectionMeta[title] ?? ("text.page", .secondaryLabel)
    }

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
            image: UIImage(systemName: "checkmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(dismissSelf)
        )
        navigationItem.rightBarButtonItem?.tintColor = UIColor(
            red: 237/255, green: 112/255, blue: 153/255, alpha: 1
        )

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
        tableView.register(SummarySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SummarySectionHeaderView.reuseID)
        tableView.register(SummaryItemCell.self, forCellReuseIdentifier: SummaryItemCell.reuseID)
        tableView.alpha = 0

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Build the header
        let header = buildTableHeader()
        tableView.tableHeaderView = header

        // Build the footer (disclaimer)
        let footer = buildTableFooter()
        tableView.tableFooterView = footer
    }

    private func buildTableHeader() -> UIView {
        let container = UIView()

        let icon = UIImageView(image: UIImage(systemName: "doc.text.magnifyingglass"))
        icon.tintColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "AI Summary"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UILabel()
        subtitle.text = record.title
        subtitle.font = .systemFont(ofSize: 14, weight: .regular)
        subtitle.textColor = .secondaryLabel
        subtitle.numberOfLines = 2
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(icon)
        container.addSubview(label)
        container.addSubview(subtitle)
        container.addSubview(divider)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            icon.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            subtitle.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            subtitle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            divider.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1 / (view.window?.windowScene?.screen.scale ?? UITraitCollection.current.displayScale)),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        // Size the header properly
        container.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 100)
        container.setNeedsLayout()
        container.layoutIfNeeded()
        let target = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = container.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        container.frame.size.height = height
        return container
    }

    private func buildTableFooter() -> UIView {
        let container = UIView()

        let card = UIView()
        card.backgroundColor = UIColor.secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        icon.tintColor = .systemYellow
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Disclaimer"
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.textColor = .secondaryLabel
        title.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.text = "This summary is automatically generated using on-device OCR. It is for informational purposes only and is not a substitute for professional medical advice. Always verify with original reports."
        body.font = .systemFont(ofSize: 12, weight: .regular)
        body.textColor = .tertiaryLabel
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(card)
        card.addSubview(icon)
        card.addSubview(title)
        card.addSubview(body)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),

            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            title.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),

            body.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            body.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            body.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        container.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 160)
        container.setNeedsLayout()
        container.layoutIfNeeded()
        let target = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = container.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        container.frame.size.height = height
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

        DispatchQueue.global(qos: .userInitiated).async {

            let text = RecordTextExtractor.extract(from: self.localFileURL)

            DispatchQueue.main.async {

                self.hideLoadingState()

                guard text.count > 80 else {
                    self.showEmptyState(
                        icon: "doc.questionmark",
                        title: "Couldn't Read Document",
                        message: "This document appears blank or partially filled.\n\nTry uploading a typed or scanned PDF report for best results."
                    )
                    return
                }

                let parsed = RecordSummarizer.summarize(text: text)

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
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let bodyLabel = UILabel()
        bodyLabel.text = message
        bodyLabel.font = .systemFont(ofSize: 15)
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
        UIView.animate(withDuration: 0.35) {
            container.alpha = 1
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SummaryItemCell.reuseID, for: indexPath) as! SummaryItemCell
        let section = sections[indexPath.section]
        let meta = Self.meta(for: section.title)
        cell.configure(text: section.items[indexPath.row], accentColor: meta.color)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RecordSummaryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SummarySectionHeaderView.reuseID) as! SummarySectionHeaderView
        let s = sections[section]
        let meta = Self.meta(for: s.title)
        header.configure(title: s.title, iconName: meta.icon, color: meta.color)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        48
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        4
    }
}

// MARK: - Summary Section Header

private final class SummarySectionHeaderView: UITableViewHeaderFooterView {

    static let reuseID = "SummarySectionHeaderView"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let pillBackground = UIView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        pillBackground.layer.cornerRadius = 14
        pillBackground.clipsToBounds = true
        pillBackground.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(pillBackground)
        pillBackground.addSubview(iconView)
        pillBackground.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            pillBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pillBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pillBackground.heightAnchor.constraint(equalToConstant: 28),
            pillBackground.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            pillBackground.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor),

            iconView.leadingAnchor.constraint(equalTo: pillBackground.leadingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: pillBackground.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: pillBackground.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: pillBackground.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(title: String, iconName: String, color: UIColor) {
        // Clean up OCR section titles
        let cleaned = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .first ?? title
        titleLabel.text = cleaned
        titleLabel.textColor = color
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = color
        pillBackground.backgroundColor = color.withAlphaComponent(0.12)
    }
}

// MARK: - Summary Item Cell

private final class SummaryItemCell: UITableViewCell {

    static let reuseID = "SummaryItemCell"

    private let itemLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .secondarySystemGroupedBackground

        itemLabel.font = .systemFont(ofSize: 15, weight: .regular)
        itemLabel.textColor = .label
        itemLabel.numberOfLines = 0
        itemLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(itemLabel)

        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            itemLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(text: String, accentColor: UIColor) {
        // Strip existing bullet prefixes and other OCR artifacts
        var cleaned = text
        while cleaned.hasPrefix("•") || cleaned.hasPrefix("·") || cleaned.hasPrefix("-") || cleaned.hasPrefix(":") {
            cleaned = String(cleaned.dropFirst())
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        // Collapse multiple spaces
        while cleaned.contains("  ") {
            cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        }
        itemLabel.text = cleaned
    }
}
