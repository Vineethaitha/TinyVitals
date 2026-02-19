//
//  VaccinationManagerViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 15/12/25.
//

import UIKit

class VaccinationManagerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ActiveChildReceivable  {

    var activeChild: ChildProfile?



    
    // MARK: - Outlets
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var vaccinesTableView: UITableView!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: - Filters
    let filterOptions = [
        "All",
        "At Birth",
        "6 Weeks",
        "10 Weeks",
        "14 Weeks",
        "6 Months",
        "9 Months",
        "12 Months",
        "15 Months",
        "18 Months",
        "2 Years",
        "5–6 Years",
        "10–12 Years"
    ]

    var selectedFilterIndex = 0
    
    // MARK: - Child DOB
    var childDOB: Date = Date()

    var completionProgress: Double {
        let total = allVaccines.count
        let completed = allVaccines.filter { $0.status == .completed }.count
        return total == 0 ? 0 : Double(completed) / Double(total)
    }

    // MARK: - Data Model

    var filteredVaccines: [VaccineItem] = []

    let calendar = Calendar.current

    var allVaccines: [VaccineItem] = []
    
    
    enum SortOption {
        case nameAZ
        case ageOrder
    }

    enum StatusFilter {
        case all
        case upcoming
        case completed
        case skipped
        case rescheduled
    }

    var selectedSort: SortOption = .ageOrder
    var selectedStatusFilter: StatusFilter = .all
    
    var upcomingVaccines: [VaccineItem] {
        filteredVaccines.filter { $0.status == .upcoming }
    }

    var completedVaccines: [VaccineItem] {
        filteredVaccines.filter { $0.status == .completed }
    }

    var rescheduledVaccines: [VaccineItem] {
        filteredVaccines.filter { $0.status == .rescheduled }
    }

    var skippedVaccines: [VaccineItem] {
        filteredVaccines.filter { $0.status == .skipped }
    }

    var searchQuery: String = ""


    private var pendingPreselectGroup: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        vaccinesTableView.sectionHeaderTopPadding = 8

        let headerAppearance = UITableViewHeaderFooterView.appearance()
        headerAppearance.tintColor = .clear

        setupCollectionView()
        setupTableView()
        updateHeaderVisibility()

        searchBar.delegate = self
        searchBar.placeholder = "Search vaccines"
        searchBar.showsCancelButton = false
        searchBar.searchBarStyle = .minimal



        requestNotificationPermission()

        vaccinesTableView.showsVerticalScrollIndicator = false
        vaccinesTableView.showsHorizontalScrollIndicator = false
        
        reloadForChild()
    }



    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
    }

    func buildVaccines(from dob: Date) -> [VaccineItem] {

        let cal = calendar

        func id(_ name: String, _ date: Date) -> String {
            "\(name)_\(Int(date.timeIntervalSince1970))"
        }

        return [

            // MARK: - AT BIRTH
            VaccineItem(
                id: id("BCG", dob),
                name: "BCG",
                description: "Tuberculosis",
                ageGroup: "At Birth",
                status: .completed,
                date: dob
            ),

            VaccineItem(
                id: id("OPV0", dob),
                name: "OPV 0",
                description: "Oral Polio",
                ageGroup: "At Birth",
                status: .completed,
                date: dob
            ),

            VaccineItem(
                id: id("HepB1", dob),
                name: "Hepatitis B 1",
                description: "Hep B Birth Dose",
                ageGroup: "At Birth",
                status: .completed,
                date: dob
            ),

            // MARK: - 6 WEEKS
            {
                let d = cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
                return VaccineItem(id: id("DTwP1", d), name: "DTwP 1", description: "Diphtheria, Tetanus, Pertussis", ageGroup: "6 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
                return VaccineItem(id: id("IPV1", d), name: "IPV 1", description: "Injectable Polio", ageGroup: "6 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
                return VaccineItem(id: id("HepB2", d), name: "Hepatitis B 2", description: "Hep B Second Dose", ageGroup: "6 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
                return VaccineItem(id: id("Hib1", d), name: "Hib 1", description: "Haemophilus influenzae", ageGroup: "6 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
                return VaccineItem(id: id("Rotavirus1", d), name: "Rotavirus 1", description: "Diarrhea Protection", ageGroup: "6 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
                return VaccineItem(id: id("PCV1", d), name: "PCV 1", description: "Pneumococcal", ageGroup: "6 Weeks", status: .upcoming, date: d)
            }(),

            // MARK: - 10 WEEKS
            {
                let d = cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
                return VaccineItem(id: id("DTwP2", d), name: "DTwP 2", description: "Diphtheria, Tetanus, Pertussis", ageGroup: "10 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
                return VaccineItem(id: id("IPV2", d), name: "IPV 2", description: "Injectable Polio", ageGroup: "10 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
                return VaccineItem(id: id("Hib2", d), name: "Hib 2", description: "Haemophilus influenzae", ageGroup: "10 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
                return VaccineItem(id: id("Rotavirus2", d), name: "Rotavirus 2", description: "Diarrhea Protection", ageGroup: "10 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
                return VaccineItem(id: id("PCV2", d), name: "PCV 2", description: "Pneumococcal", ageGroup: "10 Weeks", status: .upcoming, date: d)
            }(),

            // MARK: - 14 WEEKS
            {
                let d = cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
                return VaccineItem(id: id("DTwP3", d), name: "DTwP 3", description: "Diphtheria, Tetanus, Pertussis", ageGroup: "14 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
                return VaccineItem(id: id("IPV3", d), name: "IPV 3", description: "Injectable Polio", ageGroup: "14 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
                return VaccineItem(id: id("Hib3", d), name: "Hib 3", description: "Haemophilus influenzae", ageGroup: "14 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
                return VaccineItem(id: id("Rotavirus3", d), name: "Rotavirus 3", description: "Diarrhea Protection", ageGroup: "14 Weeks", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
                return VaccineItem(id: id("PCV3", d), name: "PCV 3", description: "Pneumococcal", ageGroup: "14 Weeks", status: .upcoming, date: d)
            }(),

            // MARK: - 6 MONTHS
            {
                let d = cal.date(byAdding: .month, value: 6, to: dob)!
                return VaccineItem(id: id("OPV1", d), name: "OPV 1", description: "Oral Polio", ageGroup: "6 Months", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .month, value: 6, to: dob)!
                return VaccineItem(id: id("HepB3", d), name: "Hepatitis B 3", description: "Hep B Third Dose", ageGroup: "6 Months", status: .upcoming, date: d)
            }(),

            // MARK: - 9 MONTHS
            {
                let d = cal.date(byAdding: .month, value: 9, to: dob)!
                return VaccineItem(id: id("OPV2", d), name: "OPV 2", description: "Oral Polio", ageGroup: "9 Months", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .month, value: 9, to: dob)!
                return VaccineItem(id: id("MMR1", d), name: "MMR 1", description: "Measles, Mumps, Rubella", ageGroup: "9 Months", status: .upcoming, date: d)
            }(),

            // MARK: - 12 MONTHS
            {
                let d = cal.date(byAdding: .month, value: 12, to: dob)!
                return VaccineItem(id: id("Typhoid1", d), name: "Typhoid Conjugate", description: "Typhoid", ageGroup: "12 Months", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .month, value: 12, to: dob)!
                return VaccineItem(id: id("HepA1", d), name: "Hepatitis A 1", description: "Hep A First Dose", ageGroup: "12 Months", status: .upcoming, date: d)
            }(),

            // MARK: - 15 MONTHS
            {
                let d = cal.date(byAdding: .month, value: 15, to: dob)!
                return VaccineItem(id: id("MMR2", d), name: "MMR 2", description: "Measles, Mumps, Rubella", ageGroup: "15 Months", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .month, value: 15, to: dob)!
                return VaccineItem(id: id("Varicella1", d), name: "Varicella 1", description: "Chickenpox", ageGroup: "15 Months", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .month, value: 15, to: dob)!
                return VaccineItem(id: id("PCVBooster", d), name: "PCV Booster", description: "Pneumococcal", ageGroup: "15 Months", status: .upcoming, date: d)
            }(),

            // MARK: - 18 MONTHS
            {
                let d = cal.date(byAdding: .month, value: 18, to: dob)!
                return VaccineItem(id: id("DTwPBooster1", d), name: "DTwP Booster 1", description: "DTP Booster", ageGroup: "18 Months", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .month, value: 18, to: dob)!
                return VaccineItem(id: id("IPVBooster", d), name: "IPV Booster", description: "Polio Booster", ageGroup: "18 Months", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .month, value: 18, to: dob)!
                return VaccineItem(id: id("HepA2", d), name: "Hepatitis A 2", description: "Hep A Second Dose", ageGroup: "18 Months", status: .upcoming, date: d)
            }(),

            // MARK: - 2 YEARS
            {
                let d = cal.date(byAdding: .year, value: 2, to: dob)!
                return VaccineItem(id: id("TyphoidBooster", d), name: "Typhoid Booster", description: "Typhoid", ageGroup: "2 Years", status: .upcoming, date: d)
            }(),

            // MARK: - 5–6 YEARS
            {
                let d = cal.date(byAdding: .year, value: 5, to: dob)!
                return VaccineItem(id: id("DTwPBooster2", d), name: "DTwP Booster 2", description: "DTP Booster", ageGroup: "5–6 Years", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .year, value: 5, to: dob)!
                return VaccineItem(id: id("OPV3", d), name: "OPV 3", description: "Oral Polio", ageGroup: "5–6 Years", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .year, value: 5, to: dob)!
                return VaccineItem(id: id("Varicella2", d), name: "Varicella 2", description: "Chickenpox", ageGroup: "5–6 Years", status: .upcoming, date: d)
            }(),

            // MARK: - 10–12 YEARS
            {
                let d = cal.date(byAdding: .year, value: 10, to: dob)!
                return VaccineItem(id: id("Tdap", d), name: "Tdap / Td", description: "Tetanus & Diphtheria", ageGroup: "10–12 Years", status: .upcoming, date: d)
            }(),

            {
                let d = cal.date(byAdding: .year, value: 10, to: dob)!
                return VaccineItem(id: id("HPV", d), name: "HPV", description: "Human Papillomavirus", ageGroup: "10–12 Years", status: .upcoming, date: d)
            }()
        ]
    }


    
    // MARK: - Setup
    func setupCollectionView() {
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self

        let nib = UINib(nibName: "AgeFilterCell", bundle: nil)
        filtersCollectionView.register(nib, forCellWithReuseIdentifier: "AgeFilterCell")
    }

    func setupTableView() {
        vaccinesTableView.delegate = self
        vaccinesTableView.dataSource = self

        let nib = UINib(nibName: "VaccineCell", bundle: nil)
        vaccinesTableView.register(nib, forCellReuseIdentifier: "VaccineCell")
    }

    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AgeFilterCell",
            for: indexPath
        ) as! AgeFilterCell

        let title = filterOptions[indexPath.item]
        let isSelected = indexPath.item == selectedFilterIndex
        cell.configure(with: title, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFilterIndex = indexPath.item
        applyFilter()
        updateHeaderVisibility()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(
            width: 120,
            height: 30
        )
    }
    
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return upcomingVaccines.count
        case 1: return completedVaccines.count
        case 2: return skippedVaccines.count
        case 3: return rescheduledVaccines.count
        default: return 0
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "VaccineCell",
            for: indexPath
        ) as! VaccineCell

        let vaccine: VaccineItem

        switch indexPath.section {
        case 0:
            vaccine = upcomingVaccines[indexPath.row]
        case 1:
            vaccine = completedVaccines[indexPath.row]
        case 2:
            vaccine = skippedVaccines[indexPath.row]
        case 3:
            vaccine = rescheduledVaccines[indexPath.row]
        default:
            fatalError("Invalid section")
        }

        cell.configure(
            with: vaccine,
            highlight: searchQuery
        )

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vaccine: VaccineItem
        switch indexPath.section {
        case 0: vaccine = upcomingVaccines[indexPath.row]
        case 1: vaccine = completedVaccines[indexPath.row]
        case 2: vaccine = skippedVaccines[indexPath.row]
        case 3: vaccine = rescheduledVaccines[indexPath.row]
        default: return
        }

        let vc = VaccineDetailViewController(
            nibName: "VaccineDetailViewController",
            bundle: nil
        )

        vc.vaccine = vaccine
        vc.vaccineIndex = allVaccines.firstIndex {
            $0.name == vaccine.name && $0.date == vaccine.date
        }

        // 🔥 REQUIRED — THIS WAS MISSING
        vc.activeChild = self.activeChild

        vc.onSaveStatus = { [weak self] newStatus in
            guard let self = self,
                  let index = vc.vaccineIndex
            else { return }

            self.allVaccines[index].status = newStatus
            self.applyFilter()
            self.updateProgressUI()
        }


        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }



    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return upcomingVaccines.isEmpty ? nil : "Upcoming"
        case 1: return completedVaccines.isEmpty ? nil : "Completed"
        case 2: return skippedVaccines.isEmpty ? nil : "Skipped"
        case 3: return rescheduledVaccines.isEmpty ? nil : "Rescheduled"
        default: return nil
        }
    }

    func ageOrderIndex(_ age: String) -> Int {
        switch age {
        case "At Birth": return 0
        case "6 Weeks": return 1
        case "10 Weeks": return 2
        case "14 Weeks": return 3
        case "9 Months": return 4
        case "12 Months": return 5
        case "15 Months": return 6
        case "16–24 Months": return 7
        case "5–6 Years": return 8
        case "10 Years": return 9
        case "16 Years": return 10
        case "Pregnancy": return 11
        default: return 999
        }
    }


    @IBAction func filterSortTapped(_ sender: UIView) {

        let sheet = UIAlertController(title: "Filter & Sort", message: nil, preferredStyle: .actionSheet)

        // STATUS FILTER
        sheet.addAction(UIAlertAction(title: "All", style: .default) { _ in
            self.selectedStatusFilter = .all
            self.applyFilter()
        })

        sheet.addAction(UIAlertAction(title: "Upcoming", style: .default) { _ in
            self.selectedStatusFilter = .upcoming
            self.applyFilter()
        })

        sheet.addAction(UIAlertAction(title: "Completed", style: .default) { _ in
            self.selectedStatusFilter = .completed
            self.applyFilter()
        })
        
        sheet.addAction(UIAlertAction(title: "Skipped", style: .default) { _ in
            self.selectedStatusFilter = .skipped
            self.applyFilter()
        })


        sheet.addAction(UIAlertAction(title: "Rescheduled", style: .default) { _ in
            self.selectedStatusFilter = .rescheduled
            self.applyFilter()
        })

        // SORT
        sheet.addAction(UIAlertAction(title: "Sort A → Z", style: .default) { _ in
            self.selectedSort = .nameAZ
            self.applyFilter()
        })

        sheet.addAction(UIAlertAction(title: "Sort by Age", style: .default) { _ in
            self.selectedSort = .ageOrder
            self.applyFilter()
        })

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let pop = sheet.popoverPresentationController {
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
        }

        present(sheet, animated: true)
    }

    func applyFilter() {

        let selectedAge = filterOptions[selectedFilterIndex]

        // Start from full data
        var result = allVaccines

        // Age filter
        if selectedAge != "All" {
            result = result.filter { $0.ageGroup == selectedAge }
        }

        // Status filter
        switch selectedStatusFilter {
        case .all:
            break
        case .upcoming:
            result = result.filter { $0.status == .upcoming }
        case .completed:
            result = result.filter { $0.status == .completed }
        case .skipped:
            result = result.filter { $0.status == .skipped }
        case .rescheduled:
            result = result.filter { $0.status == .rescheduled }
        }


        // SEARCH FILTER (THIS WAS WRONG BEFORE)
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        // Sorting
        switch selectedSort {
        case .nameAZ:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .ageOrder:
            result.sort { ageOrderIndex($0.ageGroup) < ageOrderIndex($1.ageGroup) }
        }
        filteredVaccines = result
        vaccinesTableView.reloadData()
    }

    
    @objc private func showDetails() {

        let completed = allVaccines.filter { $0.status == .completed }.count
        let upcoming = allVaccines.filter { $0.status == .upcoming }.count
        let skipped = allVaccines.filter { $0.status == .skipped }.count
        let rescheduled = allVaccines.filter { $0.status == .rescheduled }.count

        let message = """
        Completed: \(completed)
        Upcoming: \(upcoming)
        Skipped: \(skipped)
        Rescheduled: \(rescheduled)
        """

        let alert = UIAlertController(
            title: "Vaccination Summary",
            message: message,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    

    

    @IBAction func calendarTapped(_ sender: UIButton) {

        let vc = VaccinationCalendarViewController(
            nibName: "VaccinationCalendarViewController",
            bundle: nil
        )

        vc.allVaccines = allVaccines
        vc.title = "Vaccination Calendar"

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet

        present(nav, animated: true)
    }



    
    func updateProgressUI() {
        updateHeaderVisibility()
    }
    
    private func updateHeaderVisibility() {
        if filterOptions[selectedFilterIndex] == "All" {
            setupTableHeader()
        } else {
            vaccinesTableView.tableHeaderView = nil
        }
    }

    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }


    func scheduleReminder(for vaccine: VaccineItem) {
        guard vaccine.status == .upcoming else { return }

        let content = UNMutableNotificationContent()
        content.title = "Vaccination Reminder"
        content.body = "\(vaccine.name) is scheduled tomorrow"
        content.sound = .default

        let reminderDate = calendar.date(byAdding: .day, value: -1, to: vaccine.date)!
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour],
            from: reminderDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let id = "vaccine_\(vaccine.name)_\(vaccine.date)"
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleAllReminders() {
        allVaccines.forEach { scheduleReminder(for: $0) }
    }

    private func setupTableHeader() {

        guard let header = Bundle.main.loadNibNamed(
            "VaccinationHeaderView",
            owner: nil,
            options: nil
        )?.first as? VaccinationHeaderView else {
            return
        }
        
        header.frame = CGRect(
                x: 0,
                y: 0,
                width: vaccinesTableView.bounds.width,
                height: 220   // reduced wasted space
            )

        header.configure(
            completed: completedVaccines.count,
            upcoming: upcomingVaccines.count,
            skipped: skippedVaccines.count,
            rescheduled: rescheduledVaccines.count
        )

        // THIS IS THE KEY PART
        header.setNeedsLayout()
        header.layoutIfNeeded()

        let targetSize = CGSize(
            width: vaccinesTableView.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let height = header.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        var frame = header.frame
        frame.size.height = height
        header.frame = frame

        vaccinesTableView.tableHeaderView = header
        
        header.onRingTap = { [weak self] in
               self?.showProgressDetails()
           }

        vaccinesTableView.tableHeaderView = header
    }
    
    private func showProgressDetails() {

        let completed = allVaccines.filter { $0.status == .completed }.count
        let upcoming = allVaccines.filter { $0.status == .upcoming }.count
        let skipped = allVaccines.filter { $0.status == .skipped }.count
        let rescheduled = allVaccines.filter { $0.status == .rescheduled }.count

        let message = """
        Completed: \(completed)
        Upcoming: \(upcoming)
        Missed: \(skipped)
        Rescheduled: \(rescheduled)
        """

        let alert = UIAlertController(
            title: "Vaccination Summary",
            message: message,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Done", style: .cancel))

        if let pop = alert.popoverPresentationController {

            // Anchor to table (stable reference)
            pop.sourceView = vaccinesTableView

            let headerHeight =
                vaccinesTableView.tableHeaderView?.bounds.height ?? 220

            // Ring is roughly centered in header → subtract some space
            let ringBottomOffset = headerHeight * 0.7

            pop.sourceRect = CGRect(
                x: vaccinesTableView.bounds.midX,
                y: ringBottomOffset,
                width: 1,
                height: 1
            )

            // This creates the small "speech-bubble" arrow
            pop.permittedArrowDirections = .up
        }

        present(alert, animated: true)
    }
    
    
    func reloadForChild() {
        guard isViewLoaded else { return }
        guard let child = activeChild else { return }

        childDOB = child.dob

        selectedFilterIndex = 0
        selectedStatusFilter = .all
        searchQuery = ""

        Task {
            do {
                let vaccines = try await VaccinationService.shared
                    .fetchVaccines(
                        childId: child.id,
                        dob: child.dob
                    )


                self.allVaccines = vaccines
                self.filteredVaccines = vaccines

                self.applyFilter()
                self.updateProgressUI()
                self.scheduleAllReminders()
                
                // If home requested a preselection before data was ready
                if let group = self.pendingPreselectGroup {
                    self.applyPreselection(group)
                    self.pendingPreselectGroup = nil
                }

                print("✅ Loaded vaccines from backend:", vaccines.count)

            } catch {
                print("❌ fetch vaccines failed:", error)
            }
        }
    }

    func onActiveChildChanged() {
        reloadForChild()
    }
    
    private func ageGroupForDate(dob: Date, due: Date) -> String {

        let c = Calendar.current
        let comp = c.dateComponents([.month, .day], from: dob, to: due)

        let months = comp.month ?? 0
        let days = comp.day ?? 0
        let totalDays = months * 30 + days

        switch totalDays {
        case 0...7: return "At Birth"
        case 35...49: return "6 Weeks"
        case 63...77: return "10 Weeks"
        case 91...105: return "14 Weeks"
        case 150...210: return "6 Months"
        case 240...300: return "9 Months"
        case 330...390: return "12 Months"
        case 420...480: return "15 Months"
        case 510...570: return "18 Months"
        case 700...900: return "2 Years"
        case 1700...2200: return "5–6 Years"
        case 3500...4500: return "10–12 Years"
        default: return "Other"
        }
    }
    
    func preselectAgeGroup(_ group: String) {

        loadViewIfNeeded()

        // If vaccines not loaded yet → store and return
        guard !allVaccines.isEmpty else {
            pendingPreselectGroup = group
            return
        }

        applyPreselection(group)
    }

    private func applyPreselection(_ group: String) {

        guard let index = filterOptions.firstIndex(of: group) else {
            selectedFilterIndex = 0
            return
        }

        selectedFilterIndex = index
        selectedStatusFilter = .all
        searchQuery = ""

        applyFilter()
        updateHeaderVisibility()
        filtersCollectionView.reloadData()

        DispatchQueue.main.async {
            self.filtersCollectionView.scrollToItem(
                at: IndexPath(item: index, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }

        vaccinesTableView.setContentOffset(.zero, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        applyFilter()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchQuery = ""
        applyFilter()
        searchBar.resignFirstResponder()
    }




}
