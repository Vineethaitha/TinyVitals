//
//  VaccinationCalendarViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 18/12/25.
//

import UIKit
import Lottie

final class VaccinationCalendarViewController : UIViewController {

    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var animationContainerView: UIView!


    private var emptyAnimationView: LottieAnimationView?
    private let calendarView = UICalendarView()
    
    var vaccinesByDate: [Date: [VaccineItem]] = [:]
    var selectedVaccines: [VaccineItem] = []
    var allVaccines: [VaccineItem] = [] {
        didSet {
            groupVaccinesByDate()
        }
    }


    let calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

//        view.backgroundColor = .systemBackground
//        title = "Calendar"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VaccineCell")
        tableView.tableFooterView = UIView()
        
        groupVaccinesByDate()
        setupCalendar()
        selectToday()
        loadVaccinesForToday()
        setupEmptyStateAnimation()
        emptyStateView.isHidden = true
        tableView.isHidden = false

    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
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
        calendarView.tintColor =
        UIColor(
                red: 237/255,
                green: 112/255,
                blue: 153/255,
                alpha: 1
            )

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
    
    private func loadVaccinesForToday() {
        let today = calendar.startOfDay(for: Date())
        selectedVaccines = vaccinesByDate[today] ?? []
        tableView.reloadData()
        updateEmptyState()
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
    
    private func setupEmptyStateAnimation() {
        let animation = LottieAnimation.named("Injection")
        let animationView = LottieAnimationView(animation: animation)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop

        animationContainerView.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: animationContainerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: animationContainerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: animationContainerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: animationContainerView.bottomAnchor)
        ])

        animationView.play()
        emptyAnimationView = animationView
    }
    
    private func updateEmptyState() {
        let hasVaccines = !selectedVaccines.isEmpty
        tableView.isHidden = !hasVaccines
        emptyStateView.isHidden = hasVaccines
    }

    private func dotColor(
        for vaccines: [VaccineItem]
    ) -> UIColor {

        if vaccines.contains(where: { $0.status == .skipped }) {
            return .systemRed
        }

        if vaccines.contains(where: { $0.status == .rescheduled }) {
            return .systemOrange
        }

        if vaccines.allSatisfy({ $0.status == .completed }) {
            return .systemGreen
        }

        return UIColor(
            red: 237/255,
            green: 112/255,
            blue: 153/255,
            alpha: 1
        )
    }

    
    private func refreshCalendarDot(for date: Date) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        calendarView.reloadDecorations(forDateComponents: [components], animated: true)
    }
}



extension  VaccinationCalendarViewController : UICalendarSelectionSingleDateDelegate, UITableViewDelegate {

    func dateSelection(
        _ selection: UICalendarSelectionSingleDate,
        didSelectDate dateComponents: DateComponents?
    ) {
        guard
            let components = dateComponents,
            let date = calendar.date(from: components)
        else { return }

        let day = calendar.startOfDay(for: date)

        selectedVaccines = vaccinesByDate[day] ?? []
        tableView.reloadData()
        updateEmptyState()
        refreshCalendarDot(for: day)

    }
}


extension  VaccinationCalendarViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = selectedVaccines.count
            return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {

        guard let date = calendar.date(from: dateComponents) else {
            return nil
        }

        let day = calendar.startOfDay(for: date)

        guard let vaccines = vaccinesByDate[day] else {
            return nil
        }

        return .default(
            color: dotColor(for: vaccines),
            size: .small
        )
    }

}
