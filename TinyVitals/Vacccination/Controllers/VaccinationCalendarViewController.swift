//
//  VaccinationCalendarViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 18/12/25.
//

import UIKit

class VaccinationCalendarViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var vaccinesLabel: UILabel!


    // MARK: - Calendar State
    private var calendar = Calendar.current
    private var currentDate = Date()
    private var dates: [Date?] = []

    // Sample vaccination dates (later you’ll replace with real data)
    private var vaccinationDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        generateSampleVaccines()
        reloadCalendar()
    }

    // MARK: - Setup
    private func setupCollectionView() {
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self

        let nib = UINib(nibName: "CalendarDayCell", bundle: nil)
        calendarCollectionView.register(nib, forCellWithReuseIdentifier: "CalendarDayCell")

        if let layout = calendarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 4
            layout.minimumLineSpacing = 4
        }
    }

    // MARK: - Sample Data
    private func generateSampleVaccines() {
        // Example: vaccines spread across years
        vaccinationDates = [
            calendar.date(byAdding: .day, value: 2, to: Date())!,
            calendar.date(byAdding: .day, value: 10, to: Date())!,
            calendar.date(byAdding: .month, value: 1, to: Date())!,
            calendar.date(byAdding: .year, value: 1, to: Date())!
        ]
    }

    // MARK: - Calendar Logic
    private func reloadCalendar() {
        dates.removeAll()

        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let startOfMonth = calendar.date(from: components)!

        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        // Empty slots before first day
        for _ in 0..<(firstWeekday - 1) {
            dates.append(nil)
        }

        // Actual days
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            dates.append(date)
        }

        updateMonthLabel()
        calendarCollectionView.reloadData()
    }

    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: currentDate)
    }

    // MARK: - Actions
    @IBAction func previousMonthTapped(_ sender: UIButton) {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        reloadCalendar()
    }

    @IBAction func nextMonthTapped(_ sender: UIButton) {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        reloadCalendar()
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dates.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CalendarDayCell",
            for: indexPath
        ) as! CalendarDayCell

        if let date = dates[indexPath.item] {
            let day = calendar.component(.day, from: date)
            let hasVaccine = vaccinationDates.contains {
                calendar.isDate($0, inSameDayAs: date)
            }

            cell.configure(day: day, hasVaccine: hasVaccine)
        } else {
            cell.configureEmpty()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = dates[indexPath.item] else { return }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let hasVaccine = vaccinationDates.contains {
            calendar.isDate($0, inSameDayAs: date)
        }

        let message = hasVaccine
            ? "Vaccination available on \(formatter.string(from: date))"
            : "No vaccination on \(formatter.string(from: date))"

        let alert = UIAlertController(
            title: "Vaccination Info",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.bounds.width - 24) / 7
        return CGSize(width: width, height: width)
    }
}
