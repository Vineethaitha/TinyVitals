//
//  VaccinationManagerViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 15/12/25.
//

import UIKit

class VaccinationManagerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var activeChild: ChildProfile!
    
    // MARK: - Outlets
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var vaccinesTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var calendarButton: UIButton!

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
    private let clearSearchButton = UIButton(type: .system)
    
    // MARK: - Child DOB
    var childDOB: Date = Date()

    var completionProgress: Double {
        let total = allVaccines.count
        let completed = allVaccines.filter { $0.status == .completed }.count
        return total == 0 ? 0 : Double(completed) / Double(total)
    }

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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        vaccinesTableView.sectionHeaderTopPadding = 8

        let headerAppearance = UITableViewHeaderFooterView.appearance()
        headerAppearance.tintColor = .clear

        setupCollectionView()
        setupTableView()
        updateHeaderVisibility()

        guard let child = activeChild else {
            assertionFailure("VaccinationManagerViewController opened without activeChild")
            return
        }

        childDOB = child.dob
        VaccinationStore.shared.ensureVaccinesExist(
            for: child
        ) { dob in
            self.buildVaccines(from: dob)
        }
        allVaccines = VaccinationStore.shared.vaccines(for: child.id.uuidString)
        filteredVaccines = allVaccines
        vaccinesTableView.reloadData()

        searchTextField.delegate = self
        searchTextField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )

        updateProgressUI()
        setupSearchClearButton()
        requestNotificationPermission()
        scheduleAllReminders()

        vaccinesTableView.showsVerticalScrollIndicator = false
        vaccinesTableView.showsHorizontalScrollIndicator = false
    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
    }

    func buildVaccines(from dob: Date) -> [VaccineItem] {

        let dob = childDOB
        let cal = calendar

        return [
            VaccineItem(
                name: "BCG",
                description: "Tuberculosis",
                ageGroup: "At Birth",
                status: .completed,
                date: dob
            ),

            VaccineItem(
                name: "OPV 0",
                description: "Oral Polio",
                ageGroup: "At Birth",
                status: .completed,
                date: dob
            ),

            VaccineItem(
                name: "Hepatitis B 1",
                description: "Hep B Birth Dose",
                ageGroup: "At Birth",
                status: .completed,
                date: dob
            ),

            // 6 WEEKS
            VaccineItem(
                name: "DTwP 1",
                description: "Diphtheria, Tetanus, Pertussis",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "IPV 1",
                description: "Injectable Polio",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "Hepatitis B 2",
                description: "Hep B Second Dose",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "Hib 1",
                description: "Haemophilus influenzae",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "Rotavirus 1",
                description: "Diarrhea Protection",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "PCV 1",
                description: "Pneumococcal",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            // 10 WEEKS
            VaccineItem(
                name: "DTwP 2",
                description: "Diphtheria, Tetanus, Pertussis",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            VaccineItem(
                name: "IPV 2",
                description: "Injectable Polio",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            VaccineItem(
                name: "Hib 2",
                description: "Haemophilus influenzae",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            VaccineItem(
                name: "Rotavirus 2",
                description: "Diarrhea Protection",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            VaccineItem(
                name: "PCV 2",
                description: "Pneumococcal",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            // 14 WEEKS
            VaccineItem(
                name: "DTwP 3",
                description: "Diphtheria, Tetanus, Pertussis",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            VaccineItem(
                name: "IPV 3",
                description: "Injectable Polio",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            VaccineItem(
                name: "Hib 3",
                description: "Haemophilus influenzae",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            VaccineItem(
                name: "Rotavirus 3",
                description: "Diarrhea Protection",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            VaccineItem(
                name: "PCV 3",
                description: "Pneumococcal",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            // 6 MONTHS
            VaccineItem(
                name: "OPV 1",
                description: "Oral Polio",
                ageGroup: "6 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "Hepatitis B 3",
                description: "Hep B Third Dose",
                ageGroup: "6 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 6, to: dob)!
            ),

            // 9 MONTHS
            VaccineItem(
                name: "OPV 2",
                description: "Oral Polio",
                ageGroup: "9 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 9, to: dob)!
            ),

            VaccineItem(
                name: "MMR 1",
                description: "Measles, Mumps, Rubella",
                ageGroup: "9 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 9, to: dob)!
            ),

            // 12 MONTHS
            VaccineItem(
                name: "Typhoid Conjugate",
                description: "Typhoid",
                ageGroup: "12 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 12, to: dob)!
            ),

            VaccineItem(
                name: "Hepatitis A 1",
                description: "Hep A First Dose",
                ageGroup: "12 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 12, to: dob)!
            ),

            // 15 MONTHS
            VaccineItem(
                name: "MMR 2",
                description: "Measles, Mumps, Rubella",
                ageGroup: "15 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 15, to: dob)!
            ),

            VaccineItem(
                name: "Varicella 1",
                description: "Chickenpox",
                ageGroup: "15 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 15, to: dob)!
            ),

            VaccineItem(
                name: "PCV Booster",
                description: "Pneumococcal",
                ageGroup: "15 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 15, to: dob)!
            ),

            // 18 MONTHS
            VaccineItem(
                name: "DTwP Booster 1",
                description: "DTP Booster",
                ageGroup: "18 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 18, to: dob)!
            ),

            VaccineItem(
                name: "IPV Booster",
                description: "Polio Booster",
                ageGroup: "18 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 18, to: dob)!
            ),

            VaccineItem(
                name: "Hepatitis A 2",
                description: "Hep A Second Dose",
                ageGroup: "18 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 18, to: dob)!
            ),

            // 2 YEARS
            VaccineItem(
                name: "Typhoid Booster",
                description: "Typhoid",
                ageGroup: "2 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 2, to: dob)!
            ),

            // 5–6 YEARS
            VaccineItem(
                name: "DTwP Booster 2",
                description: "DTP Booster",
                ageGroup: "5–6 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 5, to: dob)!
            ),

            VaccineItem(
                name: "OPV 3",
                description: "Oral Polio",
                ageGroup: "5–6 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 5, to: dob)!
            ),

            VaccineItem(
                name: "Varicella 2",
                description: "Chickenpox",
                ageGroup: "5–6 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 5, to: dob)!
            ),

            // 10–12 YEARS
            VaccineItem(
                name: "Tdap / Td",
                description: "Tetanus & Diphtheria",
                ageGroup: "10–12 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 10, to: dob)!
            ),

            VaccineItem(
                name: "HPV",
                description: "Human Papillomavirus",
                ageGroup: "10–12 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 10, to: dob)!
            )
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

        vc.activeChild = self.activeChild

        vc.onSaveStatus = { [weak self] newStatus in
            guard let self = self,
                  let index = vc.vaccineIndex,
                  let childId = self.activeChild?.id.uuidString
            else { return }

            self.allVaccines[index].status = newStatus

            VaccinationStore.shared.setVaccines(
                self.allVaccines,
                for: childId
            )

            self.applyFilter()
            self.updateProgressUI()
            self.setupTableHeader()
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

        var result = allVaccines

        if selectedAge != "All" {
            result = result.filter { $0.ageGroup == selectedAge }
        }

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

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        switch selectedSort {
        case .nameAZ:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .ageOrder:
            result.sort { ageOrderIndex($0.ageGroup) < ageOrderIndex($1.ageGroup) }
        }
        filteredVaccines = result
        vaccinesTableView.reloadData()
    }


    @objc func searchTextChanged() {
        searchQuery = searchTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        clearSearchButton.isHidden = searchQuery.isEmpty
        applyFilter()
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


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func setupSearchClearButton() {

        clearSearchButton.setImage(
            UIImage(systemName: "xmark.circle.fill"),
            for: .normal
        )
        clearSearchButton.tintColor = .secondaryLabel
        clearSearchButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        clearSearchButton.isHidden = true

        clearSearchButton.addTarget(
            self,
            action: #selector(clearSearchTapped),
            for: .touchUpInside
        )

        searchTextField.rightView = clearSearchButton
        searchTextField.rightViewMode = .always
    }

    @objc private func clearSearchTapped() {
        searchTextField.text = ""
        searchQuery = ""
        clearSearchButton.isHidden = true
        applyFilter()
    }

    @IBAction func calendarTapped(_ sender: UIButton) {
        let vc = VaccinationCalendarViewController(
            nibName: "VaccinationCalendarViewController",
            bundle: nil
        )

        vc.allVaccines = allVaccines

        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
                height: 220
            )

        header.configure(
            completed: completedVaccines.count,
            upcoming: upcomingVaccines.count,
            skipped: skippedVaccines.count,
            rescheduled: rescheduledVaccines.count
        )

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

            
            pop.sourceView = vaccinesTableView

            let headerHeight =
                vaccinesTableView.tableHeaderView?.bounds.height ?? 220

            let ringBottomOffset = headerHeight * 0.7

            pop.sourceRect = CGRect(
                x: vaccinesTableView.bounds.midX,
                y: ringBottomOffset,
                width: 1,
                height: 1
            )

            pop.permittedArrowDirections = .up
        }

        present(alert, animated: true)
    }
    
    
    func reloadForChild() {
        guard let child = activeChild else { return }

        VaccinationStore.shared.ensureVaccinesExist(
            for: child
        ) { dob in
            self.buildVaccines(from: dob)
        }

        allVaccines = VaccinationStore.shared.vaccines(for: child.id.uuidString)
        applyFilter()
        updateProgressUI()
    }
    
}
