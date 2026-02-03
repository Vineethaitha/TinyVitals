//
//  SymptomsTrackerViewController.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 25/12/25.
//

import UIKit
import Lottie

private var currentEntries: [SymptomEntry] = []

class SymptomsTrackerViewController: UIViewController, UITableViewDelegate {
    
    var activeChild: ChildProfile!
    
    private let calendar = Calendar.current
    private var visibleDates: [Date] = []
    private var selectedDate: Date = Date()
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var historyButton: UIButton!

    @IBOutlet weak var calendarCollectionView: UICollectionView!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var emptyImageView: UIView!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptySubtitleLabel: UILabel!

    @IBOutlet weak var timelineTableView: UITableView!

    @IBOutlet weak var floatingAddButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    
    private var emptyLottieView: LottieAnimationView?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupCalendarCollectionView()
        updateSummary(for: Date())
        
        generateDates()
        calendarCollectionView.reloadData()
        
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
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        timelineTableView.addGestureRecognizer(longPress)
        
        setupEmptyAnimation()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
        updateSummary(for: selectedDate)

        calendarCollectionView.reloadData()

        if let index = indexOfToday() {
            calendarCollectionView.selectItem(
                at: index,
                animated: false,
                scrollPosition: .centeredHorizontally
            )
        }
    }

    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let indexPath = indexOfToday() else { return }

        calendarCollectionView.selectItem(
            at: indexPath,
            animated: false,
            scrollPosition: .centeredHorizontally
        )
    }


    private func setupUI() {
        emptyImageView.tintColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)

        emptyTitleLabel.text = "No symptoms logged"
        emptyTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        emptySubtitleLabel.textColor = .secondaryLabel

        floatingAddButton.configuration = nil
        floatingAddButton.tintColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        floatingAddButton.layer.cornerRadius = 25
        floatingAddButton.setImage(UIImage(systemName: "stethoscope"),for: .normal)
        floatingAddButton.tintColor = .white

    }
    
    private func setupCalendarCollectionView() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self


        calendarCollectionView.register(
            UINib(nibName: "SympCalenderDayCell", bundle: .main),
            forCellWithReuseIdentifier: "SympCalenderDayCell"
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

        let vc = LogSymptomsViewController(
            nibName: "LogSymptomsViewController",
            bundle: nil
        )
//        print("Tapped")
        vc.activeChild = self.activeChild
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    
    
    private func updateSummary(for date: Date) {

        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: date)

        currentEntries = SymptomsDataStore.shared.entries(
            for: date,
            childId: activeChild.id.uuidString
        )


        if currentEntries.isEmpty {

            emptyImageView.isHidden = false
            emptyTitleLabel.isHidden = false
            emptySubtitleLabel.isHidden = false
            timelineTableView.isHidden = true

            emptyLottieView?.play()

            summaryLabel.text = "Your child doesn’t have any symptoms on this day"

        } else {

            emptyImageView.isHidden = true
            emptyTitleLabel.isHidden = true
            emptySubtitleLabel.isHidden = true
            timelineTableView.isHidden = false

            emptyLottieView?.stop()

            summaryLabel.text = "Your child has \(currentEntries.count) symptoms today"
        }

        timelineTableView.reloadData()
    }

    
    @IBAction func historyTapped(_ sender: UIButton) {
        let vc = SymptomsHistoryViewController(
            nibName: "SymptomsHistoryViewController",
            bundle: nil
        )
        vc.activeChild = self.activeChild
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    @IBAction func exportTapped(_ sender: UIButton) {
        exportPDF()
    }

    
    
    @objc private func exportPDF() {

        let childId = activeChild.id.uuidString

        guard let childEntries =
            SymptomsDataStore.shared.entriesByChild[childId]
        else { return }

        guard let pdfURL = SymptomsPDFExporter.generatePDF(
            from: childEntries,
            calendar: calendar
        ) else { return }

        let activityVC = UIActivityViewController(
            activityItems: [pdfURL],
            applicationActivities: nil
        )

        present(activityVC, animated: true)
    }


    private func indexOfToday() -> IndexPath? {
        let today = calendar.startOfDay(for: Date())
        if let index = visibleDates.firstIndex(where: {
            calendar.isDate($0, inSameDayAs: today)
        }) {
            return IndexPath(item: index, section: 0)
        }
        return nil
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let entry = currentEntries[indexPath.row]
        presentDetail(entry)
    }

    
    private func presentDetail(_ entry: SymptomEntry) {
        let vc = SymptomDetailViewController(
            nibName: "SymptomDetailViewController",
            bundle: nil
        )
        vc.entry = entry
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }



    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {

        if gesture.state != .began { return }

        let point = gesture.location(in: timelineTableView)
        guard let indexPath = timelineTableView.indexPathForRow(at: point) else { return }

        let entry = currentEntries[indexPath.row]

        let alert = UIAlertController(
            title: "Delete symptom?",
            message: entry.symptom.title,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            SymptomsDataStore.shared.deleteEntry(
                entry,
                childId: self.activeChild.id.uuidString
            )
            self.updateSummary(for: self.selectedDate)
        })


        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    func reloadForActiveChild() {
        updateSummary(for: selectedDate)
        calendarCollectionView.reloadData()
    }

    private func setupEmptyAnimation() {

        let animationView = LottieAnimationView(name: "Happy boy")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop

        emptyImageView.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: emptyImageView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: emptyImageView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: emptyImageView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: emptyImageView.heightAnchor)
        ])

        emptyLottieView = animationView
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
            withReuseIdentifier: "SympCalenderDayCell",
            for: indexPath
        ) as! SympCalenderDayCell

        let date = visibleDates[indexPath.item]

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"

        let day = dayFormatter.string(from: date).uppercased()
        let dayNumber = dateFormatter.string(from: date)

        let hasSymptoms =
        SymptomsDataStore.shared.hasSymptoms(
            on: date,
            childId: activeChild.id.uuidString
        )

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
        currentEntries.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SymptomTimelineCell",
            for: indexPath
        ) as! SymptomTimelineCell

        cell.configure(with: currentEntries[indexPath.row])
        return cell
    }
}

