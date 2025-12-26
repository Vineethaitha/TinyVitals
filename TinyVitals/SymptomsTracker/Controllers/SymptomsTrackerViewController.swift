//
//  SymptomsTrackerViewController.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 25/12/25.
//

import UIKit

struct SymptomTimelineItem {
    let title: String
    let description: String
    let time: String
    let color: UIColor
    let iconName: String
}

class SymptomsTrackerViewController: UIViewController, UITableViewDelegate {
    
    private var timelineDataByDate: [Date: [SymptomTimelineItem]] = [:]
    private var currentTimelineItems: [SymptomTimelineItem] = []

    
    private let calendar = Calendar.current
    private var visibleDates: [Date] = []
    private var selectedDate: Date = Date()

    // TEMP: mock symptoms count per day
    private var symptomsByDate: [Date: Int] = [:]

    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var historyButton: UIButton!

    @IBOutlet weak var calendarCollectionView: UICollectionView!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var emptyStateStackView: UIStackView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptySubtitleLabel: UILabel!

    @IBOutlet weak var timelineTableView: UITableView!

    @IBOutlet weak var floatingAddButton: UIButton!

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            showSampleData()
            
            setupCalendarCollectionView()
            updateSummary(for: Date())
            
            generateDates()
            calendarCollectionView.reloadData()
            
            let today = calendar.startOfDay(for: Date())
            symptomsByDate[today] = 2

            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
                symptomsByDate[yesterday] = 1
            }
            
            timelineTableView.delegate = self
            timelineTableView.dataSource = self

            timelineTableView.register(
                UINib(nibName: "SymptomTimelineCell", bundle: nil),
                forCellReuseIdentifier: "SymptomTimelineCell"
            )

            timelineTableView.separatorStyle = .none
            timelineTableView.showsVerticalScrollIndicator = false
            timelineTableView.rowHeight = UITableView.automaticDimension
            timelineTableView.estimatedRowHeight = 120
            
            calendarCollectionView.allowsMultipleSelection = false
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Export",
                style: .plain,
                target: self,
                action: #selector(exportPDF)
            )
            

        }

        private func setupUI() {
            view.backgroundColor = .systemBackground

            searchBar.placeholder = "Search symptoms"

            emptyImageView.image = UIImage(systemName: "figure.and.child.holdinghands")
            emptyImageView.tintColor = .systemPink

            emptyTitleLabel.text = "No symptoms logged"
            emptyTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

            emptySubtitleLabel.text = "Tap + to add symptoms"
            emptySubtitleLabel.textColor = .secondaryLabel

            floatingAddButton.setImage(
                UIImage(systemName: "plus"),
                for: .normal
            )
            floatingAddButton.backgroundColor = .systemPink
            floatingAddButton.tintColor = .white
            floatingAddButton.layer.cornerRadius = 28
        }

    private func showSampleData() {

        let today = calendar.startOfDay(for: Date())

        let fever = SymptomTimelineItem(
            title: "Fever",
            description: "High temperature",
            time: "09:15 AM",
            color: .systemRed,
            iconName: "thermometer"
        )

        let cold = SymptomTimelineItem(
            title: "Cold & Cough",
            description: "Runny nose",
            time: "02:40 PM",
            color: .systemBlue,
            iconName: "wind"
        )

        timelineDataByDate[today] = [fever, cold]
        symptomsByDate[today] = 2

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {

            let vomiting = SymptomTimelineItem(
                title: "Vomiting",
                description: "One episode after food",
                time: "11:10 AM",
                color: .systemOrange,
                iconName: "cross.case"
            )

            timelineDataByDate[yesterday] = [vomiting]
            symptomsByDate[yesterday] = 1
        }
    }

    
    private func setupCalendarCollectionView() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self

        let nib = UINib(
            nibName: "CalendarDayCell",
            bundle: nil
        )

        calendarCollectionView.register(
            nib,
            forCellWithReuseIdentifier: "CalendarDayCell"
        )

        calendarCollectionView.showsHorizontalScrollIndicator = false

        if let layout = calendarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
        }
    }
    
    private func generateDates() {
        visibleDates.removeAll()

        let today = calendar.startOfDay(for: Date())

        for offset in -7...7 {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                visibleDates.append(date)
            }
        }

        selectedDate = today
    }



    @IBAction func addSymptomsTapped(_ sender: UIButton) {
            print("Add Symptoms tapped")
            // Next step: push LogSymptomsViewController
        }
    
    
    private func updateSummary(for date: Date) {

        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: date)

        let day = calendar.startOfDay(for: date)
        currentTimelineItems = timelineDataByDate[day] ?? []

        if currentTimelineItems.isEmpty {
            emptyStateStackView.isHidden = false
            timelineTableView.isHidden = true
            summaryLabel.text = "Your child doesn’t have any symptoms today"
        } else {
            emptyStateStackView.isHidden = true
            timelineTableView.isHidden = false
            summaryLabel.text = "Your child has \(currentTimelineItems.count) symptoms today"
        }

        timelineTableView.reloadData()
    }
    
    @IBAction func historyTapped(_ sender: UIButton) {
        let vc = SymptomsHistoryViewController(
            nibName: "SymptomsHistoryViewController",
            bundle: nil
        )

        vc.timelineDataByDate = self.timelineDataByDate

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    
    @objc private func exportPDF() {

        guard let pdfURL = SymptomsPDFExporter.generatePDF(
            from: timelineDataByDate,
            calendar: calendar
        ) else { return }

        let activityVC = UIActivityViewController(
            activityItems: [pdfURL],
            applicationActivities: nil
        )

        present(activityVC, animated: true)
    }

    @IBAction func doctorTapped(_ sender: UIButton) {
        let vc = DoctorSymptomsViewController(
            nibName: "DoctorSymptomsViewController",
            bundle: nil
        )

        // Pass full history (NOT just selected date)
        vc.symptomsByDate = timelineDataByDate

        navigationController?.pushViewController(vc, animated: true)
    }

    
    
}



extension SymptomsTrackerViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        visibleDates.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CalendarDayCell",
            for: indexPath
        ) as! CalendarDayCell

        let date = visibleDates[indexPath.item]

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"

        let day = dayFormatter.string(from: date).uppercased()
        let dayNumber = dateFormatter.string(from: date)

        let hasSymptoms =
            symptomsByDate[calendar.startOfDay(for: date)] != nil

        cell.configure(
            day: day,
            date: dayNumber,
            cellDate: date,
            hasSymptoms: hasSymptoms
        )

        cell.isSelected =
            calendar.isDate(date, inSameDayAs: selectedDate)

        return cell
    }
}


extension SymptomsTrackerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 64)
    }
}

extension SymptomsTrackerViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selectedDate = visibleDates[indexPath.item]

        collectionView.reloadData()

        // ✅ RE-SELECT after reload
        collectionView.selectItem(
            at: indexPath,
            animated: false,
            scrollPosition: []
        )

        updateSummary(for: selectedDate)
    }

}

extension SymptomsTrackerViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        currentTimelineItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SymptomTimelineCell",
            for: indexPath
        ) as! SymptomTimelineCell

        cell.configure(with: currentTimelineItems[indexPath.row])
        return cell
    }
}

