//  ChildSelectionViewController.swift
//  ChildProfile
//
//  Created by admin0 on 12/22/25.
//

import UIKit
import Lottie

protocol ChildSelectionDelegate: AnyObject {
    func didSelectChild(_ child: ChildProfile)
}

protocol ChildSelectionActions: AnyObject {
    func requestAddChild()
}


class ChildSelectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectionVCAnimationView: UIView!
    @IBOutlet weak var yourChildrenLabel: UILabel!
    
    
    private let emptyStateContainer = UIView()
    private var animationView: LottieAnimationView?
    private let addFirstChildButton = UIButton(type: .system)
    private let emptyStateLabel = UILabel()
    private var selectionAnimationView: LottieAnimationView?




//    var childProfiles: [ChildProfile] = []
    weak var selectionDelegate: ChildSelectionDelegate?
    weak var actionsDelegate: ChildSelectionActions?

    var childrenProvider: (() -> [ChildProfile])?

    

    override func viewDidLoad() {
        super.viewDidLoad()

//        title = "Select Child"

        collectionView.dataSource = self
        collectionView.delegate = self

        yourChildrenLabel.isHidden = true
        
        collectionView.register(
            UINib(nibName: "ChildCardCell", bundle: nil),
            forCellWithReuseIdentifier: "ChildCardCell"
        )
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        }

        setupEmptyStateUI()
        setupSelectionVCAnimation()
        updateUI()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🟡 actionsDelegate =", actionsDelegate as Any)
    }
    
    private func setupEmptyStateUI() {
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateContainer)

        NSLayoutConstraint.activate([
            emptyStateContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // 🔹 Lottie Animation
        let animation = LottieAnimation.named("AddChild")
        let animView = LottieAnimationView(animation: animation)
        animView.translatesAutoresizingMaskIntoConstraints = false
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop

        emptyStateContainer.addSubview(animView)

        NSLayoutConstraint.activate([
            animView.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            animView.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor, constant: 80),
            animView.widthAnchor.constraint(equalTo: emptyStateContainer.widthAnchor, multiplier: 0.9),
            animView.heightAnchor.constraint(equalToConstant: 280) // 🔥 increase size here
        ])


        animView.play()
        animationView = animView
        
        // 🔹 Empty State Caption
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UIColor.systemGray
        emptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)

        emptyStateLabel.text =
        """
        Start your child’s health journey with us.
        Add your first child to track growth, records,
        and milestones — all in one place.
        """

        emptyStateContainer.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.topAnchor.constraint(equalTo: animView.bottomAnchor, constant: 24),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])


        // 🔹 Add First Child Button
        addFirstChildButton.translatesAutoresizingMaskIntoConstraints = false
        addFirstChildButton.setTitle("Add Child", for: .normal)
        addFirstChildButton.backgroundColor = .systemPurple
        addFirstChildButton.setTitleColor(.white, for: .normal)
        addFirstChildButton.layer.cornerRadius = 14
        addFirstChildButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        addFirstChildButton.addTarget(
            self,
            action: #selector(addFirstChildTapped),
            for: .touchUpInside
        )

        emptyStateContainer.addSubview(addFirstChildButton)
        
        addFirstChildButton.translatesAutoresizingMaskIntoConstraints = false
        addFirstChildButton.setTitle("Add Child", for: .normal)

        // 🎨 RGB(237, 112, 153)
        addFirstChildButton.backgroundColor = UIColor(
            red: 237/255,
            green: 112/255,
            blue: 153/255,
            alpha: 1
        )

        addFirstChildButton.setTitleColor(.white, for: .normal)
        addFirstChildButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addFirstChildButton.layer.cornerRadius = 25
        addFirstChildButton.clipsToBounds = true

        addFirstChildButton.addTarget(
            self,
            action: #selector(addFirstChildTapped),
            for: .touchUpInside
        )

        emptyStateContainer.addSubview(addFirstChildButton)

        NSLayoutConstraint.activate([
            addFirstChildButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 24),
            addFirstChildButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addFirstChildButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addFirstChildButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        
    }
    
    private func setupSelectionVCAnimation() {
        let animation = LottieAnimation.named("SelectionVCAnimation")
        // 👆 this must match your JSON filename exactly (without .json)

        let animView = LottieAnimationView(animation: animation)
        animView.translatesAutoresizingMaskIntoConstraints = false
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop

        selectionVCAnimationView.addSubview(animView)

        NSLayoutConstraint.activate([
            animView.leadingAnchor.constraint(equalTo: selectionVCAnimationView.leadingAnchor),
            animView.trailingAnchor.constraint(equalTo: selectionVCAnimationView.trailingAnchor),
            animView.topAnchor.constraint(equalTo: selectionVCAnimationView.topAnchor),
            animView.bottomAnchor.constraint(equalTo: selectionVCAnimationView.bottomAnchor)
        ])

        animView.play()
        selectionAnimationView = animView
    }

    
    private func updateUI() {
        let hasChildren = !(childrenProvider?().isEmpty ?? true)

        collectionView.isHidden = !hasChildren
        emptyStateContainer.isHidden = hasChildren
        selectionVCAnimationView.isHidden = !hasChildren
        yourChildrenLabel.isHidden = !hasChildren
    }

    @objc private func addFirstChildTapped() {
        dismiss(animated: true) { [weak self] in
            self?.actionsDelegate?.requestAddChild()
        }
    }






}

// MARK: - Collection DataSource
extension ChildSelectionViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        (childrenProvider?().count ?? 0) + 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChildCardCell",
            for: indexPath
        ) as! ChildCardCell

        let children = childrenProvider?() ?? []

        if indexPath.item < children.count {
            cell.configure(child: children[indexPath.item])
        } else {
            cell.configureAsAdd()
        }

        return cell
    }

}

// MARK: - Collection Delegate
extension ChildSelectionViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let children = childrenProvider?() ?? []

        if indexPath.item < children.count {
            selectionDelegate?.didSelectChild(children[indexPath.item])
            dismiss(animated: true)
        } else {
            dismiss(animated: true) { [weak self] in
                self?.actionsDelegate?.requestAddChild()
            }

        }
    }

}

// MARK: - AddChildDelegate

extension ChildSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let padding: CGFloat = 20 * 2 + 16 // left + right + spacing
        let availableWidth = collectionView.bounds.width - padding
        let width = availableWidth / 2

        return CGSize(width: width, height: 120)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.15) {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.15) {
                cell.transform = .identity
            }
        }
    }

}


