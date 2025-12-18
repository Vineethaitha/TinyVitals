//
//  HomeScreenViewController.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import UIKit

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var metricSegment: UISegmentedControl!
    
    @IBOutlet weak var articlesCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!


    private let graph = GrowthTrendGraphView()
    
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
        graph.frame = graphContainer.bounds
        graph.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphContainer.addSubview(graph)

        showWeight()
        
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

    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex == 0 ? showWeight() : showHeight()
    }

    private func showWeight() {
        graph.metric = .weight
        graph.data = [
            GrowthPoint(month: 0, value: 3.3),
            GrowthPoint(month: 3, value: 6.4),
            GrowthPoint(month: 6, value: 7.9),
            GrowthPoint(month: 9, value: 8.9),
            GrowthPoint(month: 12, value: 9.4)
        ]
    }

    private func showHeight() {
        graph.metric = .height
        graph.data = [
            GrowthPoint(month: 0, value: 49.8),
            GrowthPoint(month: 3, value: 61.4),
            GrowthPoint(month: 6, value: 67.5),
            GrowthPoint(month: 9, value: 71.8),
            GrowthPoint(month: 12, value: 75.7)
        ]
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
