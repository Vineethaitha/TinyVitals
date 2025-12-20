//
//  VaccinationManagerViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 15/12/25.
//

//import UIKit
//
//final class VaccinationManagerViewController: UIViewController {
//
//    // MARK: - Outlets
//    @IBOutlet weak var filtersCollectionView: UICollectionView!
//    @IBOutlet weak var vaccinesTableView: UITableView!
//
//    // MARK: - Data
//    
//    private let filterOptions = [
//        "All", "At Birth", "6 Weeks", "10 Weeks", "14 Weeks",
//        "6 Months", "9 Months", "12 Months", "18 Months",
//        "5 Years", "10 Years", "14 Years"
//    ]
//
//    private var allVaccines: [VaccineItem] = [
//        // At Birth
//        VaccineItem(id: UUID(), name: "BCG", ageGroup: "At Birth", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "OPV-0", ageGroup: "At Birth", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "Hepatitis B-0", ageGroup: "At Birth", dueDate: nil, status: .upcoming),
//
//        // 6 Weeks
//        VaccineItem(id: UUID(), name: "Pentavalent-1", ageGroup: "6 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "OPV-1", ageGroup: "6 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "IPV-1", ageGroup: "6 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "Rotavirus-1", ageGroup: "6 Weeks", dueDate: nil, status: .upcoming),
//
//        // 10 Weeks
//        VaccineItem(id: UUID(), name: "Pentavalent-2", ageGroup: "10 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "OPV-2", ageGroup: "10 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "Rotavirus-2", ageGroup: "10 Weeks", dueDate: nil, status: .upcoming),
//
//        // 14 Weeks
//        VaccineItem(id: UUID(), name: "Pentavalent-3", ageGroup: "14 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "OPV-3", ageGroup: "14 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "IPV-2", ageGroup: "14 Weeks", dueDate: nil, status: .upcoming),
//
//        // 9 Months
//        VaccineItem(id: UUID(), name: "Measles / MR", ageGroup: "9 Months", dueDate: nil, status: .upcoming),
//
//        // 12 Months
//        VaccineItem(id: UUID(), name: "JE-1", ageGroup: "12 Months", dueDate: nil, status: .upcoming),
//
//        // 16–24 Months
//        VaccineItem(id: UUID(), name: "DPT Booster-1", ageGroup: "18 Months", dueDate: nil, status: .upcoming),
//        VaccineItem(id: UUID(), name: "OPV Booster", ageGroup: "18 Months", dueDate: nil, status: .upcoming),
//
//        // 5 Years
//        VaccineItem(id: UUID(), name: "DPT Booster-2", ageGroup: "5 Years", dueDate: nil, status: .upcoming)
//    ]
//
//    private var allVaccines: [VaccineItem] = []
////    private var filteredVaccines: [VaccineItem] = []
////    
////    var allVaccines = [
////        VaccineItem(
////            id: UUID(),
////            name: "BCG",
////            ageGroup: "At Birth",
////            description: "Protection against Tuberculosis",
////            dueDate: nil,
////            status: .upcoming
////        ),
////        VaccineItem(
////            id: UUID(),
////            name: "OPV",
////            ageGroup: "6 Weeks",
////            description: "Oral Polio Vaccine",
////            dueDate: nil,
////            status: .completed
////        ),
////        VaccineItem(
////            id: UUID(),
////            name: "Pentavalent",
////            ageGroup: "10 Weeks",
////            description: "Diphtheria, Tetanus, Hep B, Hib",
////            dueDate: nil,
////            status: .rescheduled
////        )
////    ]
//
////    filteredVaccines = allVaccines
//
//
////    private var filteredVaccines: [VaccineItem] = []
//    
//    var selectedAgeFilter: String = "All"
////    var filteredVaccines: [VaccineItem] {
////        if selectedAgeFilter == "All" {
////            return allVaccines
////        } else {
////            return allVaccines.filter {
////                $0.ageGroup == selectedAgeFilter
////            }
////        }
////    }
//    
//    enum VaccineSection: Int, CaseIterable {
//        case upcoming
//        case completed
//        case rescheduled
//
//        var title: String {
//            switch self {
//            case .upcoming: return "Upcoming"
//            case .completed: return "Completed"
//            case .rescheduled: return "Rescheduled"
//            }
//        }
//    }
//
//    private var selectedFilterIndex: Int = 0
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        setupTableView()
//    }
//
//    // MARK: - Setup
//    private func setupCollectionView() {
//        filtersCollectionView.delegate = self
//        filtersCollectionView.dataSource = self
//        filtersCollectionView.showsHorizontalScrollIndicator = false
//
//        let nib = UINib(nibName: "AgeFilterCell", bundle: nil)
//        filtersCollectionView.register(nib, forCellWithReuseIdentifier: "AgeFilterCell")
//    }
//
//    private func setupTableView() {
//        vaccinesTableView.delegate = self
//        vaccinesTableView.dataSource = self
//        vaccinesTableView.separatorStyle = .none
//        vaccinesTableView.estimatedRowHeight = 80
//        vaccinesTableView.rowHeight = UITableView.automaticDimension
//
//        let nib = UINib(nibName: "VaccineCell", bundle: nil)
//        vaccinesTableView.register(nib, forCellReuseIdentifier: "VaccineCell")
//    }
//}
//
//// MARK: - Collection View
//extension VaccinationManagerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return filterOptions.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "AgeFilterCell",
//            for: indexPath
//        ) as? AgeFilterCell else {
//            return UICollectionViewCell()
//        }
//
//        let title = filterOptions[indexPath.item]
//        let isSelected = indexPath.item == selectedFilterIndex
//        cell.configure(with: title, isSelected: isSelected)
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//
//        selectedAgeFilter = filterOptions[indexPath.item]
//        collectionView.reloadData()
//        vaccinesTableView.reloadData()
//    }
//
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//        return CGSize(width: 80, height: 32)
//    }
//}
//
//// MARK: - Table View
//extension VaccinationManagerViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        VaccineSection.allCases.count
//    }
//    
//    
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        VaccineSection(rawValue: section)?.title
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        filteredVaccines.count
//    }
//
//
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: "VaccineCell",
//            for: indexPath
//        ) as? VaccineCell else {
//            return UITableViewCell()
//        }
//
//        let vaccine = filteredVaccines[indexPath.row]
//        cell.configure(with: vaccine)
//        return cell
//    }
//    
//
////    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
////        return section == 0 ? "Upcoming" : "Completed"
////    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//    
//    func vaccines(for section: VaccineSection) -> [VaccineItem] {
//        return filteredVaccines.filter { $0.status == sectionStatus(section) }
//    }
//
//    func sectionStatus(_ section: VaccineSection) -> VaccineStatus {
//        switch section {
//        case .upcoming: return .upcoming
//        case .completed: return .completed
//        case .rescheduled: return .rescheduled
//        }
//    }
//    
//    func updateStatus(_ status: VaccineStatus, for id: UUID) {
//        if let index = allVaccines.firstIndex(where: { $0.id == id }) {
//            allVaccines[index].status = status
//            vaccinesTableView.reloadData()
//        }
//    }
//    
//    func applyAgeFilter(_ age: String) {
//        if age == "All" {
//            filteredVaccines = allVaccines
//        } else {
//            filteredVaccines = allVaccines.filter {
//                $0.ageGroup == age
//            }
//        }
//        vaccinesTableView.reloadData()
//    }
//
//    func filterByStatus(_ status: VaccineStatus) {
//        filteredVaccines = allVaccines.filter {
//            $0.status == status
//        }
//        vaccinesTableView.reloadData()
//    }
//
//
//
//}


//import UIKit
//
//class VaccinationManagerViewController: UIViewController,
//                      UICollectionViewDelegate,
//                      UICollectionViewDataSource,
//                      UICollectionViewDelegateFlowLayout,
//                      UITableViewDelegate,
//                      UITableViewDataSource {
//
//    // MARK: - OUTLETS
//    @IBOutlet weak var filtersCollectionView: UICollectionView!
//    @IBOutlet weak var vaccinesTableView: UITableView!
//    @IBOutlet weak var bottomBar: UIView!
//    @IBOutlet weak var advancedFilterButton: UIButton!
//
//    // MARK: - MODELS (INLINE – NO EXTRA FILES)
//    struct VaccineItem {
//        let name: String
//        let ageGroup: String
//        let dueDate: Date?
//        var status: VaccineStatus
//    }
//
//    enum VaccineStatus {
//        case upcoming
//        case completed
//        case rescheduled
//    }
//
//    enum AdvancedFilterMode {
//        case all
//        case upcomingOnly
//        case completedOnly
//        case rescheduledOnly
//    }
//
//    // MARK: - DATA
//    let filterOptions = [
//        "All", "At Birth", "6 Weeks", "10 Weeks",
//        "14 Weeks", "6 Months", "9 Months",
//        "12 Months", "18 Months", "5 Years"
//    ]
//
//    var selectedFilterIndex = 0
//    var advancedFilterMode: AdvancedFilterMode = .all
//    var sortByNearestDate = true
//
//    // BASE DATA (Indian Immunization Schedule)
//    var allVaccines: [VaccineItem] = [
//        VaccineItem(name: "BCG", ageGroup: "At Birth", dueDate: nil, status: .upcoming),
//        VaccineItem(name: "OPV-0", ageGroup: "At Birth", dueDate: nil, status: .completed),
//        VaccineItem(name: "Hepatitis B-0", ageGroup: "At Birth", dueDate: nil, status: .upcoming),
//
//        VaccineItem(name: "Pentavalent-1", ageGroup: "6 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(name: "OPV-1", ageGroup: "6 Weeks", dueDate: nil, status: .rescheduled),
//        VaccineItem(name: "Rotavirus-1", ageGroup: "6 Weeks", dueDate: nil, status: .upcoming),
//
//        VaccineItem(name: "Pentavalent-2", ageGroup: "10 Weeks", dueDate: nil, status: .upcoming),
//        VaccineItem(name: "Pentavalent-3", ageGroup: "14 Weeks", dueDate: nil, status: .upcoming),
//
//        VaccineItem(name: "Measles / MR", ageGroup: "9 Months", dueDate: nil, status: .completed),
//        VaccineItem(name: "DPT Booster", ageGroup: "18 Months", dueDate: nil, status: .upcoming)
//    ]
//
//    var visibleVaccines: [VaccineItem] = []
//
//    // MARK: - LIFECYCLE
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        setupTableView()
//        applyAllFilters()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        styleBottomBar()
//    }
//
//    // MARK: - SETUP
//    func setupCollectionView() {
//        filtersCollectionView.delegate = self
//        filtersCollectionView.dataSource = self
//        filtersCollectionView.showsHorizontalScrollIndicator = false
//
//        let nib = UINib(nibName: "AgeFilterCell", bundle: nil)
//        filtersCollectionView.register(nib, forCellWithReuseIdentifier: "AgeFilterCell")
//    }
//
//    func setupTableView() {
//        vaccinesTableView.delegate = self
//        vaccinesTableView.dataSource = self
//        vaccinesTableView.separatorStyle = .none
//        vaccinesTableView.rowHeight = 80
//
//        let nib = UINib(nibName: "VaccineCell", bundle: nil)
//        vaccinesTableView.register(nib, forCellReuseIdentifier: "VaccineCell")
//    }
//
//    // MARK: - FILTER LOGIC
//    func applyAllFilters() {
//        let ageFilter = filterOptions[selectedFilterIndex]
//
//        visibleVaccines = allVaccines.filter { vaccine in
//            let ageMatch = (ageFilter == "All") || vaccine.ageGroup == ageFilter
//            let statusMatch: Bool
//
//            switch advancedFilterMode {
//            case .all: statusMatch = true
//            case .upcomingOnly: statusMatch = vaccine.status == .upcoming
//            case .completedOnly: statusMatch = vaccine.status == .completed
//            case .rescheduledOnly: statusMatch = vaccine.status == .rescheduled
//            }
//
//            return ageMatch && statusMatch
//        }
//
//        if sortByNearestDate {
//            visibleVaccines.sort {
//                ($0.dueDate ?? Date.distantFuture) <
//                ($1.dueDate ?? Date.distantFuture)
//            }
//        } else {
//            visibleVaccines.sort { $0.name < $1.name }
//        }
//
//        vaccinesTableView.reloadData()
//    }
//
//    // MARK: - ADVANCED FILTER BUTTON
//    @IBAction func advancedFilterTapped(_ sender: UIButton) {
//        let sheet = UIAlertController(title: "Filter & Sort", message: nil, preferredStyle: .actionSheet)
//
//        sheet.addAction(UIAlertAction(title: "All", style: .default) { _ in
//            self.advancedFilterMode = .all
//            self.applyAllFilters()
//        })
//        sheet.addAction(UIAlertAction(title: "Upcoming", style: .default) { _ in
//            self.advancedFilterMode = .upcomingOnly
//            self.applyAllFilters()
//        })
//        sheet.addAction(UIAlertAction(title: "Completed", style: .default) { _ in
//            self.advancedFilterMode = .completedOnly
//            self.applyAllFilters()
//        })
//        sheet.addAction(UIAlertAction(title: "Rescheduled", style: .default) { _ in
//            self.advancedFilterMode = .rescheduledOnly
//            self.applyAllFilters()
//        })
//
//        sheet.addAction(UIAlertAction(title: "Sort by Name", style: .default) { _ in
//            self.sortByNearestDate = false
//            self.applyAllFilters()
//        })
//
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(sheet, animated: true)
//    }
//
//    // MARK: - COLLECTION VIEW
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        filterOptions.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "AgeFilterCell",
//            for: indexPath
//        ) as! AgeFilterCell
//
//        cell.configure(
//            with: filterOptions[indexPath.item],
//            isSelected: indexPath.item == selectedFilterIndex
//        )
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedFilterIndex = indexPath.item
//        applyAllFilters()
//        collectionView.reloadData()
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        CGSize(width: 80, height: 32)
//    }
//
//    // MARK: - TABLE VIEW
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        visibleVaccines.count
//    }
//
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: "VaccineCell",
//            for: indexPath
//        ) as! VaccineCell
//
//        let vaccine = visibleVaccines[indexPath.row]
//        cell.configure(name: vaccine.name, subtitle: vaccine.ageGroup)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vaccine = visibleVaccines[indexPath.row]
//
//        let vc = VaccineDetailViewController(
//            nibName: "VaccineDetailViewController",
//            bundle: nil
//        )
//        vc.vaccineName = vaccine.name
//        vc.vaccineDescription = vaccine.ageGroup
//        vc.presentAsCard(on: self)
//    }
//
//    // MARK: - UI
//    func styleBottomBar() {
//        bottomBar.layer.cornerRadius = bottomBar.bounds.height / 2
//        bottomBar.layer.shadowOpacity = 0.15
//        bottomBar.layer.shadowRadius = 18
//        bottomBar.layer.shadowOffset = CGSize(width: 0, height: 8)
//    }
//}


import UIKit

class VaccinationManagerViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITableViewDataSource,
UITableViewDelegate, UITextFieldDelegate
 {

    // MARK: - Outlets
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var vaccinesTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var calendarButton: UIButton!
//    @IBOutlet weak var progressView: UIProgressView!
//    @IBOutlet weak var progressRingView: VaccinationProgressRingView!

//    @IBOutlet weak var progressLabel: UILabel!



    // MARK: - Filters
    let filterOptions = [
        "All",
        "At Birth",
        "6 Weeks",
        "10 Weeks",
        "14 Weeks",
        "9 Months",
        "12 Months",
        "15 Months",
        "16–24 Months",
        "5–6 Years",
        "10 Years",
        "16 Years",
        "Pregnancy"
    ]

    var selectedFilterIndex = 0
    private let clearSearchButton = UIButton(type: .system)
    
    // MARK: - Child DOB
    var childDOB: Date = Date()   // default, replace later from profile screen

    // STATUS COMPLETION
    var completionProgress: Double {
        let total = allVaccines.count
        let completed = allVaccines.filter { $0.status == .completed }.count
        return total == 0 ? 0 : Double(completed) / Double(total)
    }

    // MARK: - Data Model
    struct VaccineItem {
        let name: String
        let description: String
        let ageGroup: String
        var status: VaccineStatus
        let date: Date
    }

    enum VaccineStatus {
        case upcoming
        case completed
        case skipped
        case rescheduled
    }

//    private weak var headerView: VaccinationHeaderView?

    var filteredVaccines: [VaccineItem] = []

    let calendar = Calendar.current

//    let allVaccines: [VaccineItem] = [
//        VaccineItem(name: "BCG", description: "Tuberculosis vaccine", ageGroup: "At Birth", status: .completed,  date: Date()),
//        VaccineItem(name: "OPV", description: "Polio vaccine", ageGroup: "6 Weeks", status: .upcoming,date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!),
//        VaccineItem(name: "Pentavalent", description: "DTP + HepB + Hib", ageGroup: "6 Weeks", status: .upcoming, date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!),
//        VaccineItem(name: "Rotavirus", description: "Diarrhea prevention", ageGroup: "10 Weeks", status: .rescheduled, date: Calendar.current.date(byAdding: .day, value: 10 , to: Date())!)
//    ]
    var allVaccines: [VaccineItem] = []

//    var allVaccines: [VaccineItem] {
//
//        let dob = childDOB
//        let cal = calendar
//
//        return [
//
//            // MARK: - At Birth
//            VaccineItem(
//                name: "BCG",
//                description: "Tuberculosis vaccine",
//                ageGroup: "At Birth",
//                status: .completed,
//                date: dob
//            ),
//
//            VaccineItem(
//                name: "OPV-0",
//                description: "Oral Polio Vaccine (Birth dose)",
//                ageGroup: "At Birth",
//                status: .completed,
//                date: dob
//            ),
//
//            VaccineItem(
//                name: "Hepatitis B (Birth)",
//                description: "Hepatitis B birth dose",
//                ageGroup: "At Birth",
//                status: .completed,
//                date: dob
//            ),
//
//            // MARK: - 6 Weeks
//            VaccineItem(
//                name: "Pentavalent-1",
//                description: "DTP + HepB + Hib",
//                ageGroup: "6 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "OPV-1",
//                description: "Oral Polio Vaccine",
//                ageGroup: "6 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "Rotavirus-1",
//                description: "Diarrhea prevention",
//                ageGroup: "6 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "IPV-1",
//                description: "Injectable Polio Vaccine",
//                ageGroup: "6 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
//            ),
//
//            // MARK: - 10 Weeks
//            VaccineItem(
//                name: "Pentavalent-2",
//                description: "DTP + HepB + Hib",
//                ageGroup: "10 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "OPV-2",
//                description: "Oral Polio Vaccine",
//                ageGroup: "10 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "Rotavirus-2",
//                description: "Diarrhea prevention",
//                ageGroup: "10 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
//            ),
//
//            // MARK: - 14 Weeks
//            VaccineItem(
//                name: "Pentavalent-3",
//                description: "DTP + HepB + Hib",
//                ageGroup: "14 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "OPV-3",
//                description: "Oral Polio Vaccine",
//                ageGroup: "14 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "IPV-2",
//                description: "Injectable Polio Vaccine",
//                ageGroup: "14 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
//            ),
//
//            // MARK: - 9 Months
//            VaccineItem(
//                name: "MR-1",
//                description: "Measles & Rubella",
//                ageGroup: "9 Months",
//                status: .upcoming,
//                date: cal.date(byAdding: .month, value: 9, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "JE-1",
//                description: "Japanese Encephalitis",
//                ageGroup: "9 Months",
//                status: .upcoming,
//                date: cal.date(byAdding: .month, value: 9, to: dob)!
//            ),
//
//            // MARK: - 16–24 Months
//            VaccineItem(
//                name: "DPT Booster-1",
//                description: "Diphtheria, Pertussis, Tetanus",
//                ageGroup: "16–24 Months",
//                status: .upcoming,
//                date: cal.date(byAdding: .month, value: 18, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "OPV Booster",
//                description: "Oral Polio Booster",
//                ageGroup: "16–24 Months",
//                status: .upcoming,
//                date: cal.date(byAdding: .month, value: 18, to: dob)!
//            ),
//
//            VaccineItem(
//                name: "MR-2",
//                description: "Measles & Rubella (2nd dose)",
//                ageGroup: "16–24 Months",
//                status: .upcoming,
//                date: cal.date(byAdding: .month, value: 18, to: dob)!
//            ),
//
//            // MARK: - 5–6 Years
//            VaccineItem(
//                name: "DPT Booster-2",
//                description: "Diphtheria, Pertussis, Tetanus",
//                ageGroup: "5–6 Years",
//                status: .upcoming,
//                date: cal.date(byAdding: .year, value: 5, to: dob)!
//            ),
//
//            // MARK: - 10 Years
//            VaccineItem(
//                name: "Td",
//                description: "Tetanus & Diphtheria",
//                ageGroup: "10 Years",
//                status: .upcoming,
//                date: cal.date(byAdding: .year, value: 10, to: dob)!
//            ),
//
//            // MARK: - 16 Years
//            VaccineItem(
//                name: "Td Booster",
//                description: "Tetanus & Diphtheria",
//                ageGroup: "16 Years",
//                status: .upcoming,
//                date: cal.date(byAdding: .year, value: 16, to: dob)!
//            )
//        ]
//    }



    
    enum SortOption {
        case nameAZ
        case ageOrder
    }

    enum StatusFilter {
        case all
        case upcoming
        case completed
        case skipped       // ✅ ADD THIS
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

    
//    var filteredVaccines: [VaccineItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupTableView()
        setupTableHeader()

        if allVaccines.isEmpty {
                allVaccines = buildVaccines()
            }
        
        // ✅ LOAD DATA INITIALLY
        filteredVaccines = allVaccines
        vaccinesTableView.reloadData()
        
        searchTextField.delegate = self
        searchTextField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )

        setupCollectionView()
        setupTableView()
        updateProgressUI()
        setupSearchClearButton()
        requestNotificationPermission()
        scheduleAllReminders()
        
        vaccinesTableView.showsVerticalScrollIndicator = false
        vaccinesTableView.showsHorizontalScrollIndicator = false
        
//        progressRingView.onTap = { [weak self] in
//            self?.showProgressDetails()
//        }

        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(showDetails))
//        progressRingView.isUserInteractionEnabled = true
//        progressRingView.addGestureRecognizer(tap)

        
    }
    
    //
    
    func buildVaccines() -> [VaccineItem] {

        let dob = childDOB
        let cal = calendar

        return [
            VaccineItem(name: "BCG", description: "Tuberculosis vaccine", ageGroup: "At Birth", status: .completed, date: dob),
            VaccineItem(name: "OPV-0", description: "Oral Polio Vaccine (Birth dose)", ageGroup: "At Birth", status: .completed, date: dob),

            VaccineItem(
                name: "Pentavalent-1",
                description: "DTP + HepB + Hib",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),
            // keep rest exactly same
            
//            VaccineItem(
//                name: "BCG",
//                description: "Tuberculosis vaccine",
//                ageGroup: "At Birth",
//                status: .completed,
//                date: dob
//            ),
//
//            VaccineItem(
//                name: "OPV-0",
//                description: "Oral Polio Vaccine (Birth dose)",
//                ageGroup: "At Birth",
//                status: .completed,
//                date: dob
//            ),

            VaccineItem(
                name: "Hepatitis B (Birth)",
                description: "Hepatitis B birth dose",
                ageGroup: "At Birth",
                status: .completed,
                date: dob
            ),

            // MARK: - 6 Weeks
//            VaccineItem(
//                name: "Pentavalent-1",
//                description: "DTP + HepB + Hib",
//                ageGroup: "6 Weeks",
//                status: .upcoming,
//                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
//            ),

            VaccineItem(
                name: "OPV-1",
                description: "Oral Polio Vaccine",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "Rotavirus-1",
                description: "Diarrhea prevention",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            VaccineItem(
                name: "IPV-1",
                description: "Injectable Polio Vaccine",
                ageGroup: "6 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 6, to: dob)!
            ),

            // MARK: - 10 Weeks
            VaccineItem(
                name: "Pentavalent-2",
                description: "DTP + HepB + Hib",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            VaccineItem(
                name: "OPV-2",
                description: "Oral Polio Vaccine",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            VaccineItem(
                name: "Rotavirus-2",
                description: "Diarrhea prevention",
                ageGroup: "10 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 10, to: dob)!
            ),

            // MARK: - 14 Weeks
            VaccineItem(
                name: "Pentavalent-3",
                description: "DTP + HepB + Hib",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            VaccineItem(
                name: "OPV-3",
                description: "Oral Polio Vaccine",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            VaccineItem(
                name: "IPV-2",
                description: "Injectable Polio Vaccine",
                ageGroup: "14 Weeks",
                status: .upcoming,
                date: cal.date(byAdding: .weekOfYear, value: 14, to: dob)!
            ),

            // MARK: - 9 Months
            VaccineItem(
                name: "MR-1",
                description: "Measles & Rubella",
                ageGroup: "9 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 9, to: dob)!
            ),

            VaccineItem(
                name: "JE-1",
                description: "Japanese Encephalitis",
                ageGroup: "9 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 9, to: dob)!
            ),

            // MARK: - 16–24 Months
            VaccineItem(
                name: "DPT Booster-1",
                description: "Diphtheria, Pertussis, Tetanus",
                ageGroup: "16–24 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 18, to: dob)!
            ),

            VaccineItem(
                name: "OPV Booster",
                description: "Oral Polio Booster",
                ageGroup: "16–24 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 18, to: dob)!
            ),

            VaccineItem(
                name: "MR-2",
                description: "Measles & Rubella (2nd dose)",
                ageGroup: "16–24 Months",
                status: .upcoming,
                date: cal.date(byAdding: .month, value: 18, to: dob)!
            ),

            // MARK: - 5–6 Years
            VaccineItem(
                name: "DPT Booster-2",
                description: "Diphtheria, Pertussis, Tetanus",
                ageGroup: "5–6 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 5, to: dob)!
            ),

            // MARK: - 10 Years
            VaccineItem(
                name: "Td",
                description: "Tetanus & Diphtheria",
                ageGroup: "10 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 10, to: dob)!
            ),

            // MARK: - 16 Years
            VaccineItem(
                name: "Td Booster",
                description: "Tetanus & Diphtheria",
                ageGroup: "16 Years",
                status: .upcoming,
                date: cal.date(byAdding: .year, value: 16, to: dob)!
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

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

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
        
        collectionView.reloadData()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return CGSize(
            width: 120,
            height: 30
        )
    }

//    func applyFilter() {
//        let selected = filterOptions[selectedFilterIndex]
//
//        if selected == "All" {
//            filteredVaccines = allVaccines
//        } else {
//            filteredVaccines = allVaccines.filter {
//                $0.ageGroup == selected
//            }
//        }
//
//        vaccinesTableView.reloadData()
//    }

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


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

        let vc = VaccineDetailViewController(
            nibName: "VaccineDetailViewController",
            bundle: nil
        )

//        vc.vaccine = vaccine   // ✅ CORRECT vaccine now
        
        vc.vaccine = vaccine
        vc.vaccineIndex = allVaccines.firstIndex {
            $0.name == vaccine.name && $0.date == vaccine.date
        }
        
        vc.onSaveStatus = { [weak self] newStatus in
            guard let self = self,
                  let index = vc.vaccineIndex else { return }

            self.allVaccines[index].status = newStatus
            self.applyFilter()
//            self.updateProgressUI()
            self.setupTableHeader()
        }


        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
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

        // 1️⃣ Start from full data
        var result = allVaccines

        // 2️⃣ Age filter
        if selectedAge != "All" {
            result = result.filter { $0.ageGroup == selectedAge }
        }

        // 3️⃣ Status filter
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


        // 4️⃣ 🔍 SEARCH FILTER (THIS WAS WRONG BEFORE)
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        // 5️⃣ Sorting
        switch selectedSort {
        case .nameAZ:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .ageOrder:
            result.sort { ageOrderIndex($0.ageGroup) < ageOrderIndex($1.ageGroup) }
        }

        // 6️⃣ Assign ONCE
        filteredVaccines = result

        // 7️⃣ Reload ONCE
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

//        if let pop = alert.popoverPresentationController {
//            pop.sourceView = progressRingView
//            pop.sourceRect = progressRingView.bounds
//        }

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

        vc.allVaccines = allVaccines   // ✅ THIS IS KEY
//        vc.allVaccines = allVaccines   // ✅ IMPORTANT
//            present(vc, animated: true)
        
        // Present modally (clean UX)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    
    func updateProgressUI() {

        let completed = allVaccines.filter { $0.status == .completed }.count
        let upcoming = allVaccines.filter { $0.status == .upcoming }.count
        let skipped = allVaccines.filter { $0.status == .skipped }.count
        let rescheduled = allVaccines.filter { $0.status == .rescheduled }.count

        setupTableHeader()

        let total = allVaccines.count
        let percent = total == 0 ? 0 : Int((Double(completed) / Double(total)) * 100)
//        progressLabel.text = "Vaccination Progress: \(percent)%"
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

        // 🔥 THIS IS THE KEY PART
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

            // ⬆️ Ring is roughly centered in header → subtract some space
            let ringBottomOffset = headerHeight * 0.7

            pop.sourceRect = CGRect(
                x: vaccinesTableView.bounds.midX,
                y: ringBottomOffset,
                width: 1,
                height: 1
            )

            // 🔼 This creates the small "speech-bubble" arrow
            pop.permittedArrowDirections = .up
        }

        present(alert, animated: true)
    }


}
