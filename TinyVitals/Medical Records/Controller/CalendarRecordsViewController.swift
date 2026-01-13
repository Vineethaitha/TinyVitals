//
//  CalendarRecordsViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/14/25.
//

import UIKit
import QuickLook


class CalendarRecordsViewController: UIViewController {
    
    var activeChild: ChildProfile!


    @IBOutlet weak var calendarContainerView: UIView!

    @IBOutlet weak var tableView: UITableView!
    
    let store = RecordsStore.shared

    var recordsByDate: [Date: [MedicalFile]] = [:]
    
    var selectedDateRecords: [MedicalFile] = []
    
    private let calendarView = UICalendarView()
    
    private var previewURL: URL?

    private var emptyAnimationView: EmptyStateAnimationView?

    private let calendarAccentColor = UIColor(
        red: 237/255,
        green: 112/255,
        blue: 153/255,
        alpha: 1
    )


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Records"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        setupCalendar()
        setupTable()
        groupRecordsByDate()
        selectToday()
    }
    
    private func selectToday() {
        let today = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )

        if let selection = calendarView.selectionBehavior
            as? UICalendarSelectionSingleDate {

            selection.setSelected(today, animated: false)

            dateSelection(selection, didSelectDate: today)
        }
    }


    @objc func closeTapped() {
        dismiss(animated: true)
    }

    
    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self

        let nib = UINib(nibName: "RecordListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RecordListCell")

        tableView.tableFooterView = UIView()
    }
    
    func normalizedComponents(_ components: DateComponents) -> DateComponents {
        var comps = components
        comps.calendar = Calendar.current
        return comps
    }
    
    func normalizeDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    
    func saveTempImage(_ image: UIImage) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("preview.jpg")

        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: url)
            return url
        }
        return nil
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let cell = gesture.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell)
        else { return }

        let record = selectedDateRecords[indexPath.row]
        showRecordOptions(for: record)
    }

    func showRecordOptions(for record: MedicalFile) {

        let alert = UIAlertController(
            title: record.title,
            message: nil,
            preferredStyle: .actionSheet
        )

        // Preview
        alert.addAction(UIAlertAction(title: "Preview", style: .default) { _ in
            self.previewRecord(record)
        })

        // Edit
        alert.addAction(UIAlertAction(title: "Edit", style: .default) { _ in
            self.openEditRecord(record)
        })

        // Delete
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteRecord(record)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func previewRecord(_ record: MedicalFile) {

        if let pdfURL = record.pdfURL {
            previewURL = pdfURL
        } else if let image = record.thumbnail {
            previewURL = saveTempImage(image)
        }

        guard previewURL != nil else { return }

        let previewVC = QLPreviewController()
        previewVC.dataSource = self
        present(previewVC, animated: true)
    }
    
    func openEditRecord(_ record: MedicalFile) {

        let vc = AddRecordViewController(
            nibName: "AddRecordViewController",
            bundle: nil
        )

        vc.isEditingRecord = true
        vc.existingRecord = record

        // ✅ PUT THIS LINE HERE
//        vc.availableFolders = store.folders.map { $0.name }
        vc.activeChild = activeChild
        vc.availableFolders = store.folders(for: activeChild.id).map { $0.name }


        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 650 }]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
    }



    func deleteRecord(_ record: MedicalFile) {

        store.filesByChild[activeChild.id]?.removeAll {
            $0.id == record.id
        }

        selectedDateRecords.removeAll {
            $0.id == record.id
        }

        groupRecordsByDate()
        tableView.reloadData()
    }

    
    func showEmptyAnimation() {

        let emptyView = EmptyStateAnimationView(
            animationName: "empty_records",
            message: "No records on this date",
            animationSize: 180
        )

        emptyView.frame = tableView.bounds
        emptyView.play()

        tableView.backgroundView = emptyView
    }



    func hideEmptyAnimation() {

        if let view = tableView.backgroundView as? EmptyStateAnimationView {
            view.stop()
        }

        tableView.backgroundView = nil
    }
    
}

extension CalendarRecordsViewController {

    func setupCalendar() {
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(calendarView)

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        ])

        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.current

        calendarView.tintColor = UIColor(
            red: 237/255,
            green: 112/255,
            blue: 153/255,
            alpha: 1
        )

        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.delegate = self
    }




    func groupRecordsByDate() {
        recordsByDate.removeAll()

        for record in store.allFiles(for: activeChild.id) {
            let date = record.date.toDate()!
            let normalized = Calendar.current.startOfDay(for: date)
            recordsByDate[normalized, default: []].append(record)
        }


        let components = recordsByDate.keys.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }

        calendarView.reloadDecorations(forDateComponents: components, animated: true)
    }



}

extension CalendarRecordsViewController: UICalendarViewDelegate {
    
    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {

        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        let normalizedDate = normalizeDate(date)

        guard let records = recordsByDate[normalizedDate] else { return nil }

        return .customView {
            CalendarDotDecorationView(count: records.count)
        }
    }
}


extension CalendarRecordsViewController: UICalendarSelectionSingleDateDelegate {

    func dateSelection(
        _ selection: UICalendarSelectionSingleDate,
        didSelectDate dateComponents: DateComponents?
    ) {
        guard
            let dateComponents,
            let date = Calendar.current.date(from: dateComponents)
        else {
            selectedDateRecords = []
            showEmptyAnimation()
            tableView.reloadData()
            return
        }

        let normalizedDate = normalizeDate(date)

        if let records = recordsByDate[normalizedDate], !records.isEmpty {
            selectedDateRecords = records
            hideEmptyAnimation()
        } else {
            selectedDateRecords = []
            showEmptyAnimation()
        }

        tableView.reloadData()
    }

}


extension CalendarRecordsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedDateRecords.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RecordListCell",
            for: indexPath
        ) as! RecordListCell

        cell.configure(with: selectedDateRecords[indexPath.row])

        cell.selectionStyle = .none

        cell.gestureRecognizers?.forEach { cell.removeGestureRecognizer($0) }

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPress)

        return cell
    }

    
}

extension CalendarRecordsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        115
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let record = selectedDateRecords[indexPath.row]

        if let pdfURL = record.pdfURL {
            previewURL = pdfURL
        } else if let image = record.thumbnail {
            previewURL = saveTempImage(image)
        }

        guard previewURL != nil else { return }

        let previewVC = QLPreviewController()
        previewVC.dataSource = self
        present(previewVC, animated: true)
    }
}

extension CalendarRecordsViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        previewURL == nil ? 0 : 1
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        previewURL! as NSURL
    }
}




extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale.current
        return formatter.date(from: self)
    }
}


final class CalendarTagDecorationView: UIView {

    init(titles: [String], showDots: Bool) {
        super.init(frame: CGRect(x: 0, y: 0, width: 32, height: 28))

        backgroundColor = .clear

        var yOffset: CGFloat = 0

        for title in titles.prefix(2) {
            let pill = UILabel()
            pill.text = title.prefix(6).uppercased()
            pill.font = .systemFont(ofSize: 8, weight: .semibold)
            pill.textAlignment = .center
            pill.textColor = .white
            pill.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.9)
            pill.layer.cornerRadius = 6
            pill.clipsToBounds = true

            pill.frame = CGRect(x: 0, y: yOffset, width: 32, height: 12)

            // subtle depth
            pill.layer.shadowColor = UIColor.black.cgColor
            pill.layer.shadowOpacity = 0.15
            pill.layer.shadowRadius = 2
            pill.layer.shadowOffset = CGSize(width: 0, height: 1)
            pill.layer.masksToBounds = false

            addSubview(pill)
            yOffset += 13
        }

        if showDots {
            let dots = UILabel()
            dots.text = "•••"
            dots.font = .systemFont(ofSize: 10, weight: .medium)
            dots.textAlignment = .center
            dots.textColor = .secondaryLabel
            dots.frame = CGRect(x: 0, y: yOffset - 2, width: 32, height: 10)
            addSubview(dots)
        }

        // entry animation (soft bounce)
        transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        alpha = 0
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.4
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class CalendarDotDecorationView: UIView {

    init(count: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 8))
        backgroundColor = .clear

        let dotSize: CGFloat = 4
        let spacing: CGFloat = 4

        let visibleDots = min(count, 2)
        let showMore = count > 2

        let totalWidth =
            CGFloat(visibleDots) * dotSize +
            CGFloat(max(visibleDots - 1, 0)) * spacing +
            (showMore ? spacing : 0)

        var x = (bounds.width - totalWidth) / 2

        for _ in 0..<visibleDots {
            let dot = UIView(frame: CGRect(x: x, y: 2, width: dotSize, height: dotSize))
            dot.backgroundColor = .systemPurple
            dot.layer.cornerRadius = dotSize / 2
            dot.alpha = 0
            addSubview(dot)

            x += dotSize + spacing
        }

        if showMore {
            let moreDot = UILabel(frame: CGRect(x: x - 1, y: 0, width: 6, height: 8))
            moreDot.text = "·"
            moreDot.font = .systemFont(ofSize: 12, weight: .bold)
            moreDot.textColor = .systemPurple
            moreDot.alpha = 0
            addSubview(moreDot)
        }

        // subtle appearance animation
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            self.alpha = 1
            self.transform = .identity
            self.subviews.forEach { $0.alpha = 1 }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
