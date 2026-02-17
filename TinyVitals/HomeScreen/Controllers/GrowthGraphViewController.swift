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
    @IBOutlet weak var valueLabel: UILabel!

    var initialMetric: GrowthMetric = .weight

    private let graph = GrowthTrendGraphView()
    
    var activeChild: ChildProfile?


    override func viewDidLoad() {
        super.viewDidLoad()

        

        
        graph.frame = graphContainer.bounds
        graph.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphContainer.addSubview(graph)

        configureInitialState()
        updateDisplayedValue()
    }
    
    @IBAction func editTapped(_ sender: UIButton) {

        Haptics.impact(.light)

        let vc = AddMeasureViewController(
            nibName: "AddMeasureViewController",
            bundle: nil
        )

        if metricSegment.selectedSegmentIndex == 0 {
            vc.measureType = .weight
            vc.selectedInitialValue = activeChild?.weight ?? 3.0
        } else {
            vc.measureType = .height
            vc.selectedInitialValue = activeChild?.height ?? 1.0
        }

        vc.delegate = self
        present(vc, animated: true)
    }

    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        Haptics.impact(.light)

        if sender.selectedSegmentIndex == 0 {
            showWeight()
        } else {
            showHeight()
        }

        updateDisplayedValue()
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
    
    private func updateDisplayedValue() {

        guard let child = activeChild else {
            valueLabel.text = "--"
            return
        }

        switch metricSegment.selectedSegmentIndex {
        case 0: // Weight
            if let weight = child.weight {
                valueLabel.text = String(format: "%.1f kg", weight)
            } else {
                valueLabel.text = "-- kg"
            }

        case 1: // Height
            if let height = child.height {
                valueLabel.text = String(format: "%.1f ft", height)
            } else {
                valueLabel.text = "-- ft"
            }

        default:
            break
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
extension GrowthGraphViewController: AddMeasureDelegate {

    func didSaveValue(_ value: Double,
                      type: AddMeasureViewController.MeasureType) {

        guard var child = activeChild else { return }

        switch type {
        case .weight:
            child.weight = value
        case .height:
            child.height = value
        default:
            return
        }

        Task {
            do {
                try await ChildService.shared.updateChild(child)

                await MainActor.run {
                    AppState.shared.updateChild(child)
                    self.activeChild = child
                    self.updateDisplayedValue()
                }

            } catch {
                print("❌ Failed to update child:", error)
            }
        }
    }
}
