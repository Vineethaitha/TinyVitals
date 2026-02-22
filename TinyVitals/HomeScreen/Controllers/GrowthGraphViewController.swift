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

    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    var childAgeInMonths: Int = 0
    var initialMetric: GrowthMetric = .weight

    private let graph = GrowthTrendGraphView()
    
    var activeChild: ChildProfile?
    
    private let loaderContainer = UIView()
    private let loader = UIActivityIndicatorView(style: .large)


    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoader()


        
        graph.frame = graphContainer.bounds
        graph.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphContainer.addSubview(graph)

        configureInitialState()
        updateDisplayedValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGrowthData()
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

        guard let child = activeChild else { return }

        titleLabel.text = "Weight Trend"
        graph.metric = .weight
        graph.childGender = child.gender
        
        showLoader()

        Task {
            do {
                
//                try await GrowthService.shared.ensureBaselineExists(for: child)

                let points = try await GrowthService.shared.fetchGrowth(
                    child: child,
                    metric: .weight
                )

                await MainActor.run {

                    graph.childAgeInMonths = Calendar.current.dateComponents(
                        [.month],
                        from: child.dob,
                        to: Date()
                    ).month ?? 0

                    graph.data = points
                    updateStatusLabel(using: points)
                    hideLoader()
                }

            } catch {
                print("❌ Failed to load growth data:", error)
                await MainActor.run {
                    hideLoader()
                }
            }
        }
    }
    
    private func showHeight() {

        guard let child = activeChild else { return }

        titleLabel.text = "Height Trend"
        graph.metric = .height
        graph.childGender = child.gender
        
        showLoader()
        
        Task {
            do {
//                try await GrowthService.shared.ensureBaselineExists(for: child)
                
                let points = try await GrowthService.shared.fetchGrowth(
                    child: child,
                    metric: .height
                )

                await MainActor.run {

                    graph.childAgeInMonths = Calendar.current.dateComponents(
                        [.month],
                        from: child.dob,
                        to: Date()
                    ).month ?? 0

                    graph.data = points
                    updateStatusLabel(using: points)
                    hideLoader()
                }

            } catch {
                print("❌ Failed to load growth data:", error)
                await MainActor.run {
                    hideLoader()
                }
            }
        }
    }


    
    private func loadGrowthData() {
        if metricSegment.selectedSegmentIndex == 0 {
            showWeight()
        } else {
            showHeight()
        }
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
    
    private func updateStatusLabel(using points: [GrowthPoint]) {

        guard let latest = points.last,
              let child = activeChild else {
            statusLabel.text = "--"
            lastUpdatedLabel.text = ""
            return
        }

        let month = latest.month
        let actualValue = latest.value

        let optimal: Double? =
            metricSegment.selectedSegmentIndex == 0
            ? graph.optimalWeightValue(for: month)
            : graph.optimalHeightValue(for: month)

        guard let optimalValue = optimal else { return }

        let difference = actualValue - optimalValue
        let absDifference = abs(difference)

        let threshold = metricSegment.selectedSegmentIndex == 0 ? 1.0 : 0.3

        // ---------- STATUS ----------
        if absDifference <= threshold {
            statusLabel.text = "On track"
            statusLabel.textColor = .systemBlue
            valueLabel.textColor = .systemBlue
        } else if difference > 0 {
            statusLabel.text = "Above optimal"
            statusLabel.textColor = .systemOrange
            valueLabel.textColor = .systemOrange
        } else {
            statusLabel.text = "Below optimal"
            statusLabel.textColor = .systemOrange
            valueLabel.textColor = .systemOrange
        }

        // ---------- LAST UPDATED ----------
        let calendar = Calendar.current
        let now = Date()

        let components = calendar.dateComponents(
            [.day, .month],
            from: latest.recordedAt,
            to: now
        )

        if let days = components.day, days == 0 {
            lastUpdatedLabel.text = "Last updated today"
        }
        else if let days = components.day, days < 30 {
            lastUpdatedLabel.text = "Last updated \(days) day\(days == 1 ? "" : "s") ago"
        }
        else if let months = components.month {
            lastUpdatedLabel.text = "Last updated \(months) month\(months == 1 ? "" : "s") ago"
        }

    }




    private func setupLoader() {
        loaderContainer.translatesAutoresizingMaskIntoConstraints = false
        loaderContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        loaderContainer.isHidden = true

        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true

        loaderContainer.addSubview(loader)
        view.addSubview(loaderContainer)

        NSLayoutConstraint.activate([
            loaderContainer.topAnchor.constraint(equalTo: view.topAnchor),
            loaderContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loaderContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loader.centerXAnchor.constraint(equalTo: loaderContainer.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: loaderContainer.centerYAnchor)
        ])
    }

    private func showLoader() {
        loaderContainer.isHidden = false
        loader.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func hideLoader() {
        loader.stopAnimating()
        loaderContainer.isHidden = true
        view.isUserInteractionEnabled = true
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

                try await GrowthService.shared.addGrowthEntry(
                    childId: child.id,
                    metric: type == .weight ? .weight : .height,
                    value: value
                )


                await MainActor.run {
                    AppState.shared.updateChild(child)
                    self.activeChild = child
                    self.loadGrowthData()
                    self.updateDisplayedValue()
                }

            } catch {
                print("❌ Failed to update child:", error)
            }
        }
    }
}
