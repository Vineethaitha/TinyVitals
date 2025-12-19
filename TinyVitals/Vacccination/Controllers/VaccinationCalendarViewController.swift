//
//  VaccinationCalendarViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 18/12/25.
//

import UIKit

final class VaccinationCalendarViewController : UIViewController {

    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!


    private let calendarView = UICalendarView()
    
    var vaccinesByDate: [Date: [VaccinationManagerViewController.VaccineItem]] = [:]
    var selectedVaccines: [VaccinationManagerViewController.VaccineItem] = []

    let calendar = Calendar.current

    // 🔗 reference passed from VaccinationManagerViewController
    var allVaccines: [VaccinationManagerViewController.VaccineItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Calendar"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VaccineCell")
        
        tableView.tableFooterView = UIView()
        scrollToFirstUpcomingVaccine()
        groupVaccinesByDate()
        scrollToLastVaccine()
        setupCalendar()
        selectToday()
    }

    private func setupCalendar() {

        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(calendarView)

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        ])

        // Native configuration
        calendarView.calendar = Calendar.current

        calendarView.locale = Locale.current
        calendarView.fontDesign = .rounded

        // Accent color (optional)
        calendarView.tintColor = .systemBlue

        // REQUIRED FOR DOTS
        calendarView.delegate = self
        
        // Selection
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
    }

    private func selectToday() {
        let today = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )

        if let selection = calendarView.selectionBehavior
            as? UICalendarSelectionSingleDate {
            selection.setSelected(today, animated: false)
        }
    }
    
    func groupVaccinesByDate() {
        vaccinesByDate.removeAll()

        for vaccine in allVaccines {
            let day = calendar.startOfDay(for: vaccine.date)
            vaccinesByDate[day, default: []].append(vaccine)
        }

        let components = vaccinesByDate.keys.map {
            calendar.dateComponents([.year, .month, .day], from: $0)
        }

        calendarView.reloadDecorations(forDateComponents: components, animated: true)
    }

    
    func showNoVaccineAlert() {
        let alert = UIAlertController(
            title: "No Vaccination",
            message: "No vaccination available on this date.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func scrollToLastVaccine() {

        guard let lastDate = allVaccines
            .map({ $0.date })
            .sorted()
            .last
        else { return }

        let components = calendar.dateComponents(
            [.year, .month],
            from: lastDate
        )

        calendarView.setVisibleDateComponents(components, animated: true)
    }


}



extension  VaccinationCalendarViewController : UICalendarSelectionSingleDateDelegate, UITableViewDelegate {

    func dateSelection(
        _ selection: UICalendarSelectionSingleDate,
        didSelectDate dateComponents: DateComponents?
    ) {
        guard
            let components = dateComponents,
            let date = Calendar.current.date(from: components)
        else { return }

        let day = Calendar.current.startOfDay(for: date)

        if let vaccines = vaccinesByDate[day], !vaccines.isEmpty {
            selectedVaccines = vaccines
            tableView.reloadData()
        } else {
            selectedVaccines = []
            tableView.reloadData()
            showNoVaccineAlert()
        }
    }
}


extension  VaccinationCalendarViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedVaccines.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "VaccineCell",
            for: indexPath
        )

        let vaccine = selectedVaccines[indexPath.row]
        cell.textLabel?.text = vaccine.name
        cell.selectionStyle = .none

        return cell
    }
    
    private func scrollToFirstUpcomingVaccine() {

        guard let firstDate = allVaccines
            .map({ $0.date })
            .sorted()
            .first
        else { return }

        let components = calendar.dateComponents(
            [.year, .month],
            from: firstDate
        )

        calendarView.setVisibleDateComponents(components, animated: true)
    }

}

extension VaccinationCalendarViewController : UICalendarViewDelegate {

    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {

        guard let date = calendar.date(from: dateComponents) else {
            return nil
        }

        let day = calendar.startOfDay(for: date)

        guard vaccinesByDate[day] != nil else {
            return nil
        }

        return .default(color: .systemBlue, size: .small)
    }
}


//extension VaccinationCalendarViewController : UICalendarSelectionSingleDateDelegate {
//
//    func dateSelection(
//        _ selection: UICalendarSelectionSingleDate,
//        didSelectDate dateComponents: DateComponents?
//    ) {
//        guard
//            let components = dateComponents,
//            let date = Calendar.current.date(from: components)
//        else { return }
//
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//
//        print("Selected date:", formatter.string(from: date))
//    }
//}

//extension  VaccinationCalendarViewController : UICalendarViewDelegate {
//
//    func calendarView(
//        _ calendarView: UICalendarView,
//        decorationFor dateComponents: DateComponents
//    ) -> UICalendarView.Decoration? {
//
//        guard let date = Calendar.current.date(from: dateComponents) else {
//            return nil
//        }
//
//        let day = Calendar.current.startOfDay(for: date)
//
//        guard vaccinesByDate[day] != nil else {
//            return nil
//        }
//
//        return .default(color: .systemBlue, size: .small)
//    }
//}
