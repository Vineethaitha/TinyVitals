//
//  HomeScreenViewController.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    var activeChild: ChildProfile? {
        didSet {
            refreshForActiveChild()
        }
    }



    
    @IBOutlet weak var articlesCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var weightCardView: UIView!
    @IBOutlet weak var heightCardView: UIView!

    
    @IBOutlet weak var weightValueLabel: UILabel!
    @IBOutlet weak var heightValueLabel: UILabel!
    

    @IBOutlet weak var vaccinationProgressContainer: UIView!
    
    @IBOutlet weak var dueDaysLabel: UILabel!
    @IBOutlet weak var vaccineGroupLabel: UILabel!
    @IBOutlet weak var upcomingVaccineCardView: UIView!
    
    @IBOutlet weak var weightStatusLabel: UILabel!
    @IBOutlet weak var heightStatusLabel: UILabel!
    
    @IBOutlet weak var weightUpdateLabel: UILabel!
    @IBOutlet weak var heightUpdateLabel: UILabel!
    

    let articles: [Article] = [
        Article(
            title: "Healthy Living",
            subtitle: "By HealthyChildren.org",
            animationName: "Food Choice"
        ),
        Article(
            title: "Healthy Habits for Healthy Kids",
            subtitle: "By Mississippi State health department",
            animationName: "Kids Learning From Home"
        ),
        Article(
            title: "Healthy Sleep Habits",
            subtitle: "By Stanford Children's Health",
            animationName: "pink baby"
        )
    ]
    
    private var autoScrollTimer: Timer?
    private var currentPage = 0


    private var nextVaccineGroup: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        setupSummaryCards()
        setupCardGestures()
    
        articlesCollectionView.delegate = self
        articlesCollectionView.dataSource = self
        
        articlesCollectionView.register(
            UINib(nibName: "ArticleCardCell", bundle: nil),
            forCellWithReuseIdentifier: "ArticleCardCell"
        )
        
        articlesCollectionView.contentInsetAdjustmentBehavior = .never

        if let layout = articlesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero
        }

        
        pageControl.numberOfPages = articles.count
        pageControl.currentPage = 0
        startAutoScroll()

        
        let upcomingTap = UITapGestureRecognizer(
            target: self,
            action: #selector(openUpcomingVaccines)
        )

        dueDaysLabel.superview?.addGestureRecognizer(upcomingTap)
        dueDaysLabel.superview?.isUserInteractionEnabled = true

//        if activeChild != nil {
//            refreshForActiveChild()
//        }


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //Always pull latest from AppState
        activeChild = AppState.shared.activeChild

        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
    }



    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        print("🟢 Home didAppear, child:", activeChild as Any)
//        refreshForActiveChild()
//    }

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startAutoScroll()
    }
    
    private func startAutoScroll() {
        stopAutoScroll()

        autoScrollTimer = Timer.scheduledTimer(
            withTimeInterval: 5.0,
            repeats: true
        ) { [weak self] _ in
            self?.scrollToNextPage()
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    private func scrollToNextPage() {
        guard articles.count > 1 else { return }

        currentPage = (currentPage + 1) % articles.count

        let indexPath = IndexPath(item: currentPage, section: 0)

        articlesCollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )

        pageControl.currentPage = currentPage
    }

    private func setupSummaryCards() {
        weightValueLabel.text = "-- kg"
        heightValueLabel.text = "-- ft"
    }


    private func setupCardGestures() {
        let weightTap = UITapGestureRecognizer(
            target: self,
            action: #selector(openWeightGraph)
        )
        weightCardView.addGestureRecognizer(weightTap)

        let heightTap = UITapGestureRecognizer(
            target: self,
            action: #selector(openHeightGraph)
        )
        heightCardView.addGestureRecognizer(heightTap)
    }

    @objc private func openWeightGraph() {
        presentGraph(initialMetric: .weight)
    }

    @objc private func openHeightGraph() {
        presentGraph(initialMetric: .height)
    }

    private func presentGraph(initialMetric: GrowthMetric) {
        Haptics.impact(.light)

        let vc = GrowthGraphViewController(
            nibName: "GrowthGraphViewController",
            bundle: nil
        )

        vc.initialMetric = initialMetric
        vc.activeChild = activeChild

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {

            let customDetent = UISheetPresentationController.Detent.custom(
                identifier: .init("customHeight")
            ) { context in
                return 550   // 👈 your custom height in points
            }

            sheet.detents = [customDetent, .large()]
            sheet.selectedDetentIdentifier = .init("customHeight")
            sheet.prefersGrabberVisible = true
        }


        present(vc, animated: true)

        // 🔥 THIS IS THE FIX
        vc.presentationController?.delegate = self
    }



//    private func setupSparklines() {
//        
//        weightSparklineContainer.subviews.forEach { $0.removeFromSuperview() }
//        heightSparklineContainer.subviews.forEach { $0.removeFromSuperview() }
//        // Weight sparkline
//        weightSparkline.frame = weightSparklineContainer.bounds
//        weightSparkline.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        weightSparkline.lineColor = UIColor(
//            red: 237/255, green: 112/255, blue: 153/255, alpha: 1
//        )
//        weightSparkline.values = [7.0, 7.4, 7.4, 7.5, 7.6]
//        weightSparklineContainer.addSubview(weightSparkline)
//
//        // Height sparkline
//        heightSparkline.frame = heightSparklineContainer.bounds
//        heightSparkline.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        heightSparkline.lineColor = UIColor(
//            red: 237/255, green: 112/255, blue: 153/255, alpha: 1
//        )
//        heightSparkline.values = [72.0, 73.1, 74.4, 75.0, 75.7]
//        heightSparklineContainer.addSubview(heightSparkline)
//    }

    
//    func setupVaccinationProgress() {
//        guard let child = activeChild else { return }
//
//        Task {
//            do {
//                let vaccines = try await VaccinationService.shared
//                    .fetchVaccines(childId: child.id, dob: child.dob)
//
//                let completed = vaccines.filter { $0.status == .completed }.count
//                let upcoming = vaccines.filter { $0.status == .upcoming }.count
//                let skipped = vaccines.filter { $0.status == .skipped }.count
//                let rescheduled = vaccines.filter { $0.status == .rescheduled }.count
//
//                await MainActor.run {
//
//                    let header: VaccinationHeaderView
//
//                    if let existing = self.vaccinationProgressContainer
//                        .subviews.first as? VaccinationHeaderView {
//                        header = existing
//                    } else {
//                        guard let h = Bundle.main.loadNibNamed(
//                            "VaccinationHeaderView",
//                            owner: nil,
//                            options: nil
//                        )?.first as? VaccinationHeaderView else { return }
//
//                        h.frame = self.vaccinationProgressContainer.bounds
//                        h.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                        self.vaccinationProgressContainer.addSubview(h)
//                        header = h
//                    }
//
//                    header.configure(
//                        completed: completed,
//                        upcoming: upcoming,
//                        skipped: skipped,
//                        rescheduled: rescheduled
//                    )
//                }
//
//            } catch {
//                print("❌ vaccination progress load failed:", error)
//            }
//        }
//    }
    func setupVaccinationProgress() {
        guard let child = activeChild else { return }

        Task {
            do {
                let vaccines = try await VaccinationService.shared
                    .fetchVaccines(childId: child.id, dob: child.dob)

                let completed = vaccines.filter { $0.status == .completed }.count
                let upcoming = vaccines.filter { $0.status == .upcoming }.count
                let skipped = vaccines.filter { $0.status == .skipped }.count
                let rescheduled = vaccines.filter { $0.status == .rescheduled }.count

                let upcomingVaccines = vaccines
                    .filter { $0.status == .upcoming && $0.date >= Date() }
                    .sorted { $0.date < $1.date }

                let nextVaccine = upcomingVaccines.first

                await MainActor.run {

                    // NEXT VACCINE LOGIC
                    if let vaccine = nextVaccine {
                        
                        self.nextVaccineGroup = vaccine.ageGroup

                        let daysLeft = Calendar.current.dateComponents(
                            [.day],
                            from: Date(),
                            to: vaccine.date
                        ).day ?? 0

                        if daysLeft <= 0 {
                            self.dueDaysLabel.text = "Due Today"
                            self.dueDaysLabel.textColor = .systemRed
                        } else {
                            self.dueDaysLabel.text = "\(daysLeft) days left"
                            self.dueDaysLabel.textColor =
                                daysLeft <= 3 ? .systemOrange : UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
                        }

                        self.vaccineGroupLabel.text =
                            "Vaccine Group: \(vaccine.ageGroup)"

                    } else {
                        self.nextVaccineGroup = nil
                        self.dueDaysLabel.text = "All vaccines completed 🎉"
                        self.dueDaysLabel.textColor = .systemGreen
                        self.vaccineGroupLabel.text = ""
                    }

                    // EXISTING HEADER CODE (UNCHANGED)
                    let header: VaccinationHeaderView

                    if let existing = self.vaccinationProgressContainer
                        .subviews.first as? VaccinationHeaderView {
                        header = existing
                    } else {
                        guard let h = Bundle.main.loadNibNamed(
                            "VaccinationHeaderView",
                            owner: nil,
                            options: nil
                        )?.first as? VaccinationHeaderView else { return }

                        h.frame = self.vaccinationProgressContainer.bounds
                        h.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        self.vaccinationProgressContainer.addSubview(h)
                        header = h
                    }

                    header.configure(
                        completed: completed,
                        upcoming: upcoming,
                        skipped: skipped,
                        rescheduled: rescheduled
                    )
                }

            } catch {
                print("❌ vaccination progress load failed:", error)
            }
        }
    }





    
    private func openVaccinesTab() {
        Haptics.impact(.light)
        tabBarController?.selectedIndex = 3
    }

    func refreshForActiveChild() {
        guard isViewLoaded else { return }
        guard let child = activeChild else { return }

        // Weight / Height summary
        if let weight = child.weight {
            weightValueLabel.text = String(format: "%.1f kg", weight)
        } else {
            weightValueLabel.text = "-- kg"
        }

        if let height = child.height {
            heightValueLabel.text = String(format: "%.1f ft", height)
        } else {
            heightValueLabel.text = "-- ft"
        }

        // Vaccination progress
        setupVaccinationProgress()
        // Growth status
        updateGrowthSummary()
    }



    private func setupNextUpcomingVaccine(from vaccines: [VaccineItem]) {

        let upcoming = vaccines
            .filter { $0.status == .upcoming }
            .sorted { $0.date < $1.date }

        guard let next = upcoming.first else {
            vaccineGroupLabel.text = "All vaccinations up to date 🎉"
            dueDaysLabel.text = ""
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let dueDate = Calendar.current.startOfDay(for: next.date)

        let components = Calendar.current.dateComponents(
            [.day],
            from: today,
            to: dueDate
        )

        let daysLeft = components.day ?? 0

        vaccineGroupLabel.text = "\(next.name) • \(next.ageGroup)"

        if daysLeft > 0 {
            dueDaysLabel.text = "Due in \(daysLeft) day\(daysLeft == 1 ? "" : "s")"
            dueDaysLabel.textColor = UIColor.systemPink
        } else if daysLeft == 0 {
            dueDaysLabel.text = "Due Today"
            dueDaysLabel.textColor = UIColor.systemOrange
        } else {
            let overdue = abs(daysLeft)
            dueDaysLabel.text = "Overdue by \(overdue) day\(overdue == 1 ? "" : "s")"
            dueDaysLabel.textColor = UIColor.systemRed
        }
    }


    @objc private func openUpcomingVaccines() {
        Haptics.impact(.light)
        UIView.animate(withDuration: 0.1, animations: {
            self.upcomingVaccineCardView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.upcomingVaccineCardView.transform = .identity
            }
        }

        guard let group = nextVaccineGroup else { return }

        tabBarController?.selectedIndex = 3

        if let tabBar = tabBarController as? MainTabBarController,
           let nav = tabBar.viewControllers?[3] as? UINavigationController,
           let vaccineVC = nav.topViewController as? VaccinationManagerViewController {

            //  THIS LINE IS MISSING
            vaccineVC.activeChild = AppState.shared.activeChild

            vaccineVC.preselectAgeGroup(group)
        }
    }

    private func updateGrowthSummary() {

        guard let child = activeChild else { return }

        Task {
            do {

                let weightPoints = try await GrowthService.shared.fetchGrowth(
                    child: child,
                    metric: .weight
                )

                let heightPoints = try await GrowthService.shared.fetchGrowth(
                    child: child,
                    metric: .height
                )

                await MainActor.run {

                    updateCard(
                        metric: .weight,
                        points: weightPoints,
                        child: child
                    )

                    updateCard(
                        metric: .height,
                        points: heightPoints,
                        child: child
                    )
                }

            } catch {
                print("❌ Failed to load summary growth:", error)
            }
        }
    }
    
    private func updateCard(
        metric: GrowthMetric,
        points: [GrowthPoint],
        child: ChildProfile
    ) {

        guard let latest = points.last else { return }

        let month = latest.month
        let actual = latest.value

        let graph = GrowthTrendGraphView()
        graph.childGender = child.gender

        let optimal = metric == .weight
            ? graph.optimalWeightValue(for: month)
            : graph.optimalHeightValue(for: month)

        guard let optimalValue = optimal else { return }

        let difference = abs(actual - optimalValue)

        let buffer = metric == .weight ? 2.0 : 1.0

        let isStable = difference <= buffer

        let statusText = isStable ? "Stable" : "Needs Attention!"
        let statusColor: UIColor = isStable ? UIColor(red: 108/255, green: 173/255, blue: 226/255, alpha: 1) : .systemOrange

        // ---------- STATUS LABEL ----------
        if metric == .weight {
            weightStatusLabel.text = statusText
            weightStatusLabel.textColor = statusColor
        } else {
            heightStatusLabel.text = statusText
            heightStatusLabel.textColor = statusColor
        }

        // ---------- LAST UPDATED ----------
        let calendar = Calendar.current

        if let recordedDate = calendar.date(
            byAdding: .month,
            value: month,
            to: child.dob
        ) {

            let components = calendar.dateComponents(
                [.day],
                from: recordedDate,
                to: Date()
            )

            let text: String

            if components.day == 0 {
                text = "Updated today"
            }
            else if let days = components.day, days < 30 {
                text = "Updated \(days) day\(days == 1 ? "" : "s") ago"
            }
            else {
                let months = calendar.dateComponents(
                    [.month],
                    from: recordedDate,
                    to: Date()
                ).month ?? 0

                text = "Updated \(months) month\(months == 1 ? "" : "s") ago"
            }

            if metric == .weight {
                weightUpdateLabel.text = text
            } else {
                heightUpdateLabel.text = text
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        articles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ArticleCardCell",
            for: indexPath
        ) as! ArticleCardCell

        let item = articles[indexPath.item]
        cell.configure(
            title: item.title,
            subtitle: item.subtitle,
            animationName: item.animationName
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(
            width: collectionView.frame.width,
            height: 140
        )
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        currentPage = page
        pageControl.currentPage = page
    }
}

extension HomeScreenViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        // Refresh after sheet closes
        self.activeChild = AppState.shared.activeChild
    }
}
