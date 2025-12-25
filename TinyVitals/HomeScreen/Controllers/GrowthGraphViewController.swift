//
//  GrowthGraphViewController.swift
//  TinyVitals
//
//  Created by admin0 on 12/20/25.
//

import UIKit

class GrowthGraphViewController: UIViewController {
    
    @IBOutlet weak var metricSegment: UISegmentedControl!
    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    var initialMetric: GrowthMetric = .weight

    private let graph = GrowthTrendGraphView()

    override func viewDidLoad() {
        super.viewDidLoad()

        graph.frame = graphContainer.bounds
        graph.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphContainer.addSubview(graph)

        configureInitialState()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex == 0
            ? showWeight()
            : showHeight()
    }


    private func configureInitialState() {
        switch initialMetric {
        case .weight:
            metricSegment.selectedSegmentIndex = 0
            showWeight()
        case .height:
            metricSegment.selectedSegmentIndex = 1
            showHeight()
        }
    }

    private func showWeight() {
        titleLabel.text = "Weight Trend"
        graph.metric = .weight
        graph.data = [
            GrowthPoint(month: 0, value: 3.3),
            GrowthPoint(month: 3, value: 6.1),
            GrowthPoint(month: 5, value: 7.1),
            GrowthPoint(month: 7, value: 7.7),
            GrowthPoint(month: 9, value: 8.1),
            GrowthPoint(month: 12, value: 8.5)
        ]


    }

    private func showHeight() {
        titleLabel.text = "Height Trend"
        graph.metric = .height
        graph.data = [
            GrowthPoint(month: 0, value: 49.8),
            GrowthPoint(month: 2, value: 57.2),
            GrowthPoint(month: 4, value: 63.0),
            GrowthPoint(month: 6, value: 66.8),
            GrowthPoint(month: 9, value: 70.4),
            GrowthPoint(month: 12, value: 73.6)
        ]

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
