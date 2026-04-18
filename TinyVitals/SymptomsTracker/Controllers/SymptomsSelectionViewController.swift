//
//  SymptomsSelectionViewController.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 30/12/25.
//

import UIKit

final class SymptomsSelectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectedCollectionView: UICollectionView!
    @IBOutlet weak var allCollectionView: UICollectionView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var selectedCollectionHeight: NSLayoutConstraint!

    // MARK: - Data
    private var allSymptoms: [SymptomItem] = []
    private var filteredSymptoms: [SymptomItem] = []
    var selectedSymptoms = Set<SymptomItem>()

    /// Ordered version of selected symptoms (for UI stability)
    private var selectedSymptomsArray: [SymptomItem] {
        allSymptoms.filter { selectedSymptoms.contains($0) }
    }

    /// Callback to parent
    var onApply: (([SymptomItem]) -> Void)?

    // Skeleton loader
    private var skeletonView: SymptomsSelectionSkeletonView?
    private var isFirstLoad = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        allSymptoms = []
        filteredSymptoms = []

        fetchSymptomsFromDB()

        setupCollectionViews()
        setupSearchBar()
        setupApplyButton()
        
        updateSelectedSectionVisibility()

        hideKeyboardWhenTappedAround()

        // Show skeleton on first load
        showSelectionSkeleton()
    }

    private func fetchSymptomsFromDB() {
        Task {
            do {
                let dtos = try await SymptomService.shared.fetchSymptomsMaster()
                let items = dtos.map { dto in
                    SymptomItem(
                        title: dto.title,
                        iconName: dto.iconName,
                        tintColor: UIColor.from(string: dto.tintColor)
                    )
                }
                
                await MainActor.run {
                    self.allSymptoms = items
                    let searchText = self.searchBar.text ?? ""
                    if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                        self.filteredSymptoms = items
                    } else {
                        self.filteredSymptoms = items.filter {
                            $0.title.lowercased().contains(searchText.lowercased())
                        }
                    }
                    self.allCollectionView.reloadData()
                    self.selectedCollectionView.reloadData()
                    self.updateSelectedSectionVisibility()
                    self.hideSelectionSkeleton()
                }
            } catch {
//                print("❌ Failed to fetch symptoms: \(error)")
                await MainActor.run { self.hideSelectionSkeleton() }
            }
        }
    }

    // MARK: - Setup
    private func setupCollectionViews() {

        let nib = UINib(nibName: "SymptomItemCell", bundle: nil)

        [selectedCollectionView, allCollectionView].forEach {
            $0?.register(nib, forCellWithReuseIdentifier: "SymptomItemCell")
            $0?.delegate = self
            $0?.dataSource = self

            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 14
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            $0?.collectionViewLayout = layout

        }
    }


    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search symptoms"
        searchBar.autocapitalizationType = .none
    }

    private func setupApplyButton() {
        applyButton.configuration = nil
        applyButton.setTitle("Apply", for: .normal)
        applyButton.layer.cornerRadius = 25
        applyButton.backgroundColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }

    

    
    private func updateSelectedSectionVisibility() {

        let hasSelection = !selectedSymptoms.isEmpty

        selectedCollectionView.isHidden = !hasSelection
        selectedCollectionHeight.constant = hasSelection ? calculatedHeight() : 0

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func calculatedHeight() -> CGFloat {
        selectedCollectionView.layoutIfNeeded()
        return selectedCollectionView.collectionViewLayout.collectionViewContentSize.height
    }


    // MARK: - Actions
    @IBAction func applyTapped(_ sender: UIButton) {
        Haptics.impact(.light)
        onApply?(selectedSymptomsArray)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension SymptomsSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == selectedCollectionView
        ? selectedSymptomsArray.count
        : filteredSymptoms.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SymptomItemCell",
            for: indexPath
        ) as! SymptomItemCell

        let item: SymptomItem

        if collectionView == selectedCollectionView {
            item = selectedSymptomsArray[indexPath.item]
            cell.configure(with: item, selected: true)
        } else {
            item = filteredSymptoms[indexPath.item]
            cell.configure(with: item, selected: selectedSymptoms.contains(item))
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SymptomsSelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Haptics.impact(.light)
        let item: SymptomItem

        if collectionView == selectedCollectionView {
            item = selectedSymptomsArray[indexPath.item]
            selectedSymptoms.remove(item)
        } else {
            item = filteredSymptoms[indexPath.item]
            if selectedSymptoms.contains(item) {
                selectedSymptoms.remove(item)
            } else {
                selectedSymptoms.insert(item)
            }
        }

        selectedCollectionView.reloadData()
        allCollectionView.reloadData()
        updateSelectedSectionVisibility()

    }
}

// MARK: - UISearchBarDelegate
extension SymptomsSelectionViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filteredSymptoms = allSymptoms
        } else {
            filteredSymptoms = allSymptoms.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }

        allCollectionView.reloadData()
    }
}

extension SymptomsSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let totalPadding: CGFloat = 16 + 16 + 12   // left + right + spacing
        let width = (collectionView.bounds.width - totalPadding) / 2

        return CGSize(
            width: width,
            height: 48
        )
    }
}

// MARK: - Skeleton Loader
extension SymptomsSelectionViewController {

    func showSelectionSkeleton() {
        guard isFirstLoad else { return }

        let skeleton = SymptomsSelectionSkeletonView()
        skeleton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skeleton)

        NSLayoutConstraint.activate([
            skeleton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            skeleton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skeleton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skeleton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        skeletonView = skeleton
        DispatchQueue.main.async { skeleton.startAnimating() }
    }

    func hideSelectionSkeleton() {
        guard isFirstLoad else { return }
        isFirstLoad = false
        skeletonView?.stopAnimating { [weak self] in self?.skeletonView = nil }
    }
}
