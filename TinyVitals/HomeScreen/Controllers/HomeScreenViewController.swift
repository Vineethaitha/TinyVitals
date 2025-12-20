//
//  HomeScreenViewController.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    @IBOutlet weak var articlesCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var weightCardView: UIView!
    @IBOutlet weak var heightCardView: UIView!

    @IBOutlet weak var weightValueLabel: UILabel!
    @IBOutlet weak var heightValueLabel: UILabel!
    
    @IBOutlet weak var weightSparklineContainer: UIView!
    @IBOutlet weak var heightSparklineContainer: UIView!


    private let weightSparkline = SparklineView()
    private let heightSparkline = SparklineView()


    
    
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

        
        setupSparklines()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
    }
    
    
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
        weightValueLabel.text = "9.4 kg"
        heightValueLabel.text = "75.7 cm"
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
        let vc = GrowthGraphViewController(
            nibName: "GrowthGraphViewController",
            bundle: nil
        )

        vc.initialMetric = initialMetric
        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
    }

    private func setupSparklines() {

        // Weight sparkline
        weightSparkline.frame = weightSparklineContainer.bounds
        weightSparkline.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        weightSparkline.lineColor = UIColor(
            red: 204/255, green: 142/255, blue: 224/255, alpha: 1
        )
        weightSparkline.values = [8.2, 8.6, 8.9, 9.1, 9.4]
        weightSparklineContainer.addSubview(weightSparkline)

        // Height sparkline
        heightSparkline.frame = heightSparklineContainer.bounds
        heightSparkline.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        heightSparkline.lineColor = UIColor.systemBlue
        heightSparkline.values = [72.0, 73.1, 74.4, 75.0, 75.7]
        heightSparklineContainer.addSubview(heightSparkline)
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
