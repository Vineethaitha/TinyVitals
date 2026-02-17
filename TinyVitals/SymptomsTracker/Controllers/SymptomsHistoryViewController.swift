//
//  SymptomsHistoryViewController.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 26/12/25.
//

import UIKit

private var selectedDayItems: [SymptomEntry] = []

final class SymptomsHistoryViewController: UIViewController, UITableViewDelegate {
    
    var activeChild: ChildProfile!


    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var timelineTableView: UITableView!

    private let calendarView = UICalendarView()
    private let calendar = Calendar.current

    // 🔹 DATA
//    var timelineDataByDate: [Date: [SymptomTimelineItem]] = [:]
    private var allDatesSorted: [Date] = []
    private var selectedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.backgroundColor = .systemBackground
        title = "Symptoms History"

        setupNavigation()
        setupCalendar()
        setupTable()
//        loadSampleData()
        selectToday()
        timelineTableView.reloadData()
        updateEmptyState()
        
//        timelineDataByDate =
//            SymptomsDataStore.shared.timelineDataByDate

        allDatesSorted =
            SymptomsDataStore.shared.allDates(
                for: activeChild.id.uuidString
            )


        reloadCalendarDots()


    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    private func updateEmptyState() {
        if selectedDayItems.isEmpty {
            let label = UILabel()
            label.text = "No symptoms on this day"
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center

            timelineTableView.backgroundView = label
        } else {
            timelineTableView.backgroundView = nil
        }
    }


    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension SymptomsHistoryViewController {

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
        calendarView.locale = .current
        calendarView.tintColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)

        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.delegate = self
    }
}


extension SymptomsHistoryViewController {

    func setupTable() {
        timelineTableView.delegate = self
        timelineTableView.dataSource = self

        timelineTableView.register(
            UINib(nibName: "SymptomTimelineCell", bundle: nil),
            forCellReuseIdentifier: "SymptomTimelineCell"
        )

        timelineTableView.separatorStyle = .none
        timelineTableView.rowHeight = UITableView.automaticDimension
        timelineTableView.estimatedRowHeight = 120
    }
}

extension SymptomsHistoryViewController {

//    func loadSampleData() {
//        let today = calendar.startOfDay(for: Date())
//
//        let fever = SymptomTimelineItem(
//            title: "Fever",
//            description: "High body temperature",
//            time: "09:15 AM",
//            color: .systemRed,
//            iconName: "thermometer"
//        )
//
//        let cold = SymptomTimelineItem(
//            title: "Cold & Cough",
//            description: "Runny nose",
//            time: "02:40 PM",
//            color: .systemBlue,
//            iconName: "wind"
//        )
//
//        timelineDataByDate[today] = [fever, cold]
//
//        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
//            timelineDataByDate[yesterday] = [
//                SymptomTimelineItem(
//                    title: "Vomiting",
//                    description: "After food",
//                    time: "11:00 AM",
//                    color: .systemOrange,
//                    iconName: "cross.case"
//                )
//            ]
//        }
//
//        allDatesSorted = timelineDataByDate.keys.sorted()
//        reloadCalendarDots()
//    }
}

extension SymptomsHistoryViewController: UICalendarViewDelegate {

    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {

        guard let date = calendar.date(from: dateComponents),
              SymptomsDataStore.shared.hasSymptoms(
                  on: date,
                  childId: activeChild.id.uuidString
              )

        else { return nil }

        return .default(color: UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1), size: .small)
    }


    func reloadCalendarDots() {
        let dates =
        SymptomsDataStore.shared
            .allDates(for: activeChild.id.uuidString)
        .map {
            calendar.dateComponents([.year, .month, .day], from: $0)
        }

        calendarView.reloadDecorations(forDateComponents: dates, animated: true)
    }
}

extension SymptomsHistoryViewController: UICalendarSelectionSingleDateDelegate {

    func dateSelection(
        _ selection: UICalendarSelectionSingleDate,
        didSelectDate dateComponents: DateComponents?
    ) {
        guard
            let components = dateComponents,
            let date = calendar.date(from: components)
        else {
            selectedDayItems = []
            timelineTableView.reloadData()
            updateEmptyState()
            return
        }

        let day = calendar.startOfDay(for: date)
        selectedDate = day

        Task {
            do {
                let dtos = try await SymptomService.shared
                    .fetchSymptoms(childId: activeChild.id)

                selectedDayItems = dtos
                    .filter {
                        calendar.isDate($0.logged_at, inSameDayAs: day)
                    }
                    .map {
                        SymptomEntry(dto: $0)
                    }

                DispatchQueue.main.async {
                    self.timelineTableView.reloadData()
                    self.updateEmptyState()
                }

            } catch {
                print("❌ Failed to load symptoms history:", error)
            }
        }
    }


    func selectToday() {

        let todayComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: Date()
        )

        if let selection =
            calendarView.selectionBehavior as? UICalendarSelectionSingleDate {

            selection.setSelected(todayComponents, animated: false)
        }

        let today = calendar.startOfDay(for: Date())
        selectedDate = today

        Task {
            do {
                let dtos = try await SymptomService.shared
                    .fetchSymptoms(childId: activeChild.id)

                selectedDayItems = dtos
                    .filter {
                        calendar.isDate($0.logged_at, inSameDayAs: today)
                    }
                    .map {
                        SymptomEntry(dto: $0)
                    }

                DispatchQueue.main.async {
                    self.timelineTableView.reloadData()
                    self.updateEmptyState()
                }

            } catch {
                print("❌ Failed to load today symptoms:", error)
            }
        }
    }
}

extension SymptomsHistoryViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        selectedDayItems.count
    }


    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SymptomTimelineCell",
            for: indexPath
        ) as! SymptomTimelineCell

        let item = selectedDayItems[indexPath.row]
        cell.configure(with: item)

        return cell
    }
}

