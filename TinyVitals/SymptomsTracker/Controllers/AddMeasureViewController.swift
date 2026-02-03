//
//  AddWeightViewController.swift
//  HeightScreen
//
//  Created by admin0 on 1/10/26.
//

import UIKit

protocol AddMeasureDelegate: AnyObject {
    func didSaveValue(_ value: Double, type: AddMeasureViewController.MeasureType)
}

final class AddMeasureViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    enum MeasureType {
        case weight
        case height
        case temperature
        case severity
    }
    
    weak var delegate: AddMeasureDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!

    var measureType: MeasureType = .weight
    var selectedInitialValue: Double = 0

    private let cellWidth: CGFloat = 10

    private var minValue: Double {
        switch measureType {
        case .weight: return 0.1
        case .height: return 1.0
        case .temperature: return 92.0
        case .severity: return 1.0
        }
    }

    private var maxValue: Double {
        switch measureType {
        case .weight: return 100.0
        case .height: return 15.0
        case .temperature: return 120.0
        case .severity: return 22.0
        }
    }
    
    private var step: Double {
        switch measureType {
        case .severity:
            return 1.0
        default:
            return 0.1
        }
    }
    
    private var unitText: String {
        switch measureType {
        case .weight: return "kg"
        case .height: return "ft"
        case .temperature: return "°F"
        case .severity: return ""
        }
    }

    private var titleText: String {
        switch measureType {
        case .weight: return "Weight"
        case .height: return "Height"
        case .temperature: return "Temperature"
        case .severity: return "Severity"
        }
    }

    private var totalItems: Int {
        Int(((maxValue - minValue) / step).rounded()) + 1
    }

    private var selectedValue: Double = 0
    
    private var didScrollToInitialValue = false

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedValue = min(max(selectedInitialValue, minValue), maxValue)

        titleLabel.text = "\(titleText) (\(unitText))"
        updateValueLabel()

        configureSheet()
        configureCollectionView()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        scrollToInitialValue()
//    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !didScrollToInitialValue {
            didScrollToInitialValue = true
            collectionView.layoutIfNeeded()
            scrollToInitialValue()
        }
    }

    private func configureSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: cellWidth, height: 40)
        layout.minimumLineSpacing = 0

        let inset = collectionView.bounds.width / 2 - cellWidth / 2
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: inset,
            bottom: 0,
            right: inset
        )

        collectionView.collectionViewLayout = layout
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(
            UINib(nibName: "RulerTickCell", bundle: nil),
            forCellWithReuseIdentifier: "RulerTickCell"
        )

        addCenterIndicator()
    }


    private func addCenterIndicator() {
        let indicator = UIView()
        indicator.backgroundColor = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: collectionView.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 3)
        ])
    }

    private func scrollToInitialValue() {
        let index = Int(round((selectedValue - minValue) / step))
        let offsetX = CGFloat(index) * cellWidth
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }

    private func updateValueLabel() {
        switch measureType {
        case .severity:
            valueLabel.text = "\(Int(selectedValue))"
        default:
            valueLabel.text = String(format: "%.1f %@", selectedValue, unitText)
        }
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        delegate?.didSaveValue(selectedValue, type: measureType)
        dismiss(animated: true)
    }

    // MARK: - CollectionView DataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        totalItems
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RulerTickCell",
            for: indexPath
        ) as! RulerTickCell

        let isMajor = indexPath.item % 10 == 0
        cell.configure(isMajor: isMajor)
        return cell
    }

    // MARK: - Scroll Handling

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / cellWidth))
        let clampedIndex = max(0, min(index, totalItems - 1))

        selectedValue = minValue + Double(clampedIndex) * step
        updateValueLabel()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestTick()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestTick()
        }
    }

    private func snapToNearestTick() {
        let index = Int(round((selectedValue - minValue) / step))
        let offsetX = CGFloat(index) * cellWidth
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }

}
