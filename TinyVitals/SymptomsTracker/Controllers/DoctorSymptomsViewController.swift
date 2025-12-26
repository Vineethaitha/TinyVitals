//
//  DoctorSymptomsViewController.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 26/12/25.
//

import UIKit

private var selectedDate: Date?

class DoctorSymptomsViewController: UIViewController,  UITableViewDelegate {

    
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var symptomsByDate: [Date: [SymptomTimelineItem]] = [:]
    private var selectedItems: [SymptomTimelineItem] = []

    private let calendarView = UICalendarView()
    private let calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Doctor Review"
        navigationItem.largeTitleDisplayMode = .never

        setupCalendar()
        setupTable()
        selectToday()
    }
    
}

extension DoctorSymptomsViewController {

    func setupCalendar() {
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(calendarView)

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        ])

        calendarView.calendar = calendar
        calendarView.tintColor = UIColor.label

        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.delegate = self

        reloadDots()
    }

    func reloadDots() {
        let components = symptomsByDate.keys.map {
            calendar.dateComponents([.year, .month, .day], from: $0)
        }

        calendarView.reloadDecorations(forDateComponents: components, animated: true)
    }
    
    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self

        let nib = UINib(
            nibName: "SymptomTimelineCell",
            bundle: nil
        )
        tableView.register(
            nib,
            forCellReuseIdentifier: "SymptomTimelineCell"
        )

        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.allowsSelection = false

    }

}

extension DoctorSymptomsViewController: UICalendarViewDelegate {

    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {

        guard let date = calendar.date(from: dateComponents) else { return nil }
        let day = calendar.startOfDay(for: date)

        guard symptomsByDate[day] != nil else { return nil }

        return .default(color: .systemPink, size: .small)
    }
}

extension DoctorSymptomsViewController: UICalendarSelectionSingleDateDelegate {

    func dateSelection(
        _ selection: UICalendarSelectionSingleDate,
        didSelectDate dateComponents: DateComponents?
    ) {
        guard
            let dateComponents,
            let date = calendar.date(from: dateComponents)
        else {
            selectedItems = []
            tableView.reloadData()
            return
        }

        let day = calendar.startOfDay(for: date)
        selectedDate = day
        selectedItems = symptomsByDate[day] ?? []
        tableView.reloadData()
        
        if selectedItems.isEmpty {
            tableView.backgroundView = {
                let label = UILabel()
                label.text = "No symptoms recorded on this date"
                label.textAlignment = .center
                label.textColor = .secondaryLabel
                label.font = .systemFont(ofSize: 15)
                return label
            }()
        } else {
            tableView.backgroundView = nil
        }

    }

    func selectToday() {
        let todayComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: Date()
        )

        if let selection = calendarView.selectionBehavior
            as? UICalendarSelectionSingleDate {

            selection.setSelected(todayComponents, animated: false)
            dateSelection(selection, didSelectDate: todayComponents)
        }
    }
}

extension DoctorSymptomsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SymptomTimelineCell",
            for: indexPath
        ) as! SymptomTimelineCell

        cell.configure(with: selectedItems[indexPath.row])
        return cell
    }
}

