//
//  RecordManagerViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit

class RecordManagerViewController: UIViewController, ActiveChildReceivable {
    
    private let recordDateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    let store = RecordsStore.shared

    var activeChild: ChildProfile? {
        didSet {
            guard isViewLoaded else { return }
            loadDataIfPossible()
        }
    }

//    var activeChild: ChildProfile?
    
//    let store = RecordsStore.shared

    @IBOutlet weak var searchBarView: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var threeDotsButton: UIButton!
    
//    var recentFolders: [RecordFolder] = []
    var filteredFolders: [RecordFolder] = []
    var isSearching = false
    
    enum FolderSortOption {
        case nameAZ
        case nameZA
        case mostFiles
        case leastFiles
    }


    var selectedSortOption: FolderSortOption = .nameAZ
    
    private let loader = UIActivityIndicatorView(style: .large)
    private let loaderContainer = UIView()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoader()

        addButton.configuration = nil
        addButton.layer.cornerRadius = addButton.frame.height / 2
        addButton.clipsToBounds = true
        addButton.setImage(UIImage(systemName: "doc.badge.plus"), for: .normal)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear

        let nib = UINib(nibName: "RecordCardCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "RecordCardCell")

//        collectionView.register(
//            UICollectionReusableView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "Header"
//        )

        searchBarView.delegate = self
        setupSortMenu()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        collectionView.reloadData()
//        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
//        if activeChild != nil {
//            onActiveChildChanged()
//        }
//        if let child = activeChild {
//                   loadRecordsForActiveChild(child)
//               }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()

        // ✅ FIX: ensure data loads on first tab open
        loadDataIfPossible()
    }
    
//    @IBAction func magicWandTapped() {
//        let vc = AIQueryViewController(
//            nibName: "AIQueryViewController",
//            bundle: nil
//        )
//
//        vc.activeChild = activeChild   // ✅ THIS LINE FIXES EVERYTHING
//
//        navigationController?.pushViewController(vc, animated: true)
//    }


    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }


    
    
    func setupSortMenu() {

        let createFolderAction = UIAction(
            title: "New Folder",
            image: UIImage(systemName: "folder.badge.plus")
        ) { _ in
            self.showCreateFolderAlert()
        }

        let sortByNameAZ = UIAction(
            title: "Name (A → Z)",
            image: UIImage(systemName: "textformat"),
            state: selectedSortOption == .nameAZ ? .on : .off
        ) { _ in
            self.selectedSortOption = .nameAZ
            self.sortFoldersByName(ascending: true)
            self.setupSortMenu()
        }

        let sortByNameZA = UIAction(
            title: "Name (Z → A)",
            image: UIImage(systemName: "textformat"),
            state: selectedSortOption == .nameZA ? .on : .off
        ) { _ in
            self.selectedSortOption = .nameZA
            self.sortFoldersByName(ascending: false)
            self.setupSortMenu()
        }

        let sortByMostFiles = UIAction(
            title: "Most Files",
            image: UIImage(systemName: "tray.full"),
            state: selectedSortOption == .mostFiles ? .on : .off
        ) { _ in
            self.selectedSortOption = .mostFiles
            self.sortFoldersByFileCount(descending: true)
            self.setupSortMenu()
        }

        let sortByLeastFiles = UIAction(
            title: "Least Files",
            image: UIImage(systemName: "tray"),
            state: selectedSortOption == .leastFiles ? .on : .off
        ) { _ in
            self.selectedSortOption = .leastFiles
            self.sortFoldersByFileCount(descending: false)
            self.setupSortMenu()
        }

        let menu = UIMenu(children: [
            createFolderAction,

            UIMenu(
                title: "Sort By",
                options: .displayInline,
                children: [
                    sortByNameAZ,
                    sortByNameZA,
                    sortByMostFiles,
                    sortByLeastFiles
                ]
            )
        ])

        threeDotsButton.menu = menu
        threeDotsButton.showsMenuAsPrimaryAction = true
    }





    func sortFoldersByName(ascending: Bool) {

        guard let childId = activeChild?.id else { return }

        var folders = store.folders(for: childId)

        folders.sort {
            ascending ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                      : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
        }

        store.foldersByChild[childId] = folders
        collectionView.reloadData()
    }


    func sortFoldersByFileCount(descending: Bool) {

        guard let childId = activeChild?.id else { return }

        var folders = store.folders(for: childId)

        folders.sort {

            let count1 = store.files(
                for: childId,
                folderName: $0.name
            ).count

            let count2 = store.files(
                for: childId,
                folderName: $1.name
            ).count

            return descending ? count1 > count2 : count1 < count2
        }

        store.foldersByChild[childId] = folders
        collectionView.reloadData()
    }




    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let folder = getFolder(for: indexPath)

        // Add to recents (avoid duplicates)
//        if let index = recentFolders.firstIndex(where: { $0.name == folder.name }) {
//            recentFolders.remove(at: index)
//        }
//        recentFolders.insert(folder, at: 0)
//
//        // Limit to last 5
//        if recentFolders.count > 5 {
//            recentFolders.removeLast()
//        }

        collectionView.reloadData()

        // Navigate to next screen
        let vc = RecordListViewController(
            nibName: "RecordListViewController",
            bundle: nil
        )

        vc.activeChild = activeChild          // ✅ REQUIRED
        vc.mode = .normal(folder: folder.name)
        vc.folderName = folder.name
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    
    
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        let vc = CalendarRecordsViewController(
            nibName: "CalendarRecordsViewController",
            bundle: nil
        )

        vc.activeChild = activeChild

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
    
    @IBAction func addFileButtonTapped(_ sender: UIButton) {

        guard let childId = activeChild?.id else { return }

        let sheetHeight: CGFloat = 650

        let vc = AddRecordViewController(
            nibName: "AddRecordViewController",
            bundle: nil
        )

        vc.activeChild = activeChild
        vc.availableFolders = store.folders(for: childId).map { $0.name }
        vc.onRecordSaved = { [weak self] in
            self?.collectionView.reloadData()
        }

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in sheetHeight }
            ]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
    }


    
    func showCreateFolderAlert() {
        Haptics.impact(.light)
        let alert = UIAlertController(
            title: "New Folder",
            message: "Enter a name for your folder",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Folder Name"
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let folderName = alert.textFields?.first?.text,
                  !folderName.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            self.createFolder(named: folderName)
        }

        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
//    func createFolder(named name: String) {
//
//        guard let childId = activeChild?.id else { return }
//
//        let trimmedName = name.trimmingCharacters(in: .whitespaces)
//        guard !trimmedName.isEmpty else { return }
//
//        let newFolder = RecordFolder(
//            name: trimmedName,
//            icon: UIImage(systemName: "folder.fill"),
//            color: UIColor.randomIOSFolderColor()
//        )
//
//        // Append to CHILD-SCOPED folders
////        store.foldersByChild[childId, default: []].append(newFolder)
////
////        collectionView.reloadData()
//    }
    
    func createFolder(named name: String) {

        guard let childId = activeChild?.id else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        Task {
            do {
                try await RecordFolderService.shared
                    .createFolder(childId: childId, name: trimmedName)

                await loadFoldersForActiveChild(childId)

            } catch {
                print("❌ Folder create failed:", error)
            }
        }
    }

    
    func loadFoldersForActiveChild(_ childId: UUID) async {
        do {
            let dtos = try await RecordFolderService.shared
                .fetchFolders(childId: childId)

            let folders = dtos.map {
                RecordFolder(
                    name: $0.name,
                    icon: UIImage(systemName: "folder.fill"),
                    color: UIColor(red: 255/255, green: 139/255, blue: 167/255, alpha: 1)
                )
            }

            RecordsStore.shared.foldersByChild[childId] = folders

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }

        } catch {
            print("❌ Failed to load folders:", error)
        }
    }
    
    func loadRecordsForActiveChild(_ child: ChildProfile) async {
        do {
            let dtos = try await MedicalRecordService.shared
                .fetchRecords(childId: child.id)

            // ✅ Map DTO → Model WITHOUT formatting
            let files = dtos.map { MedicalFile(dto: $0) }

            RecordsStore.shared.filesByChild[child.id] = files

            await MainActor.run {
                self.collectionView.reloadData()
            }

        } catch {
            print("❌ Failed to load records:", error)
        }
    }



    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let cell = gesture.view as? UICollectionViewCell,
                  let indexPath = collectionView.indexPath(for: cell) else { return }
            showFolderOptions(for: indexPath)
        }
    }
    
    func showFolderOptions(for indexPath: IndexPath) {

        let folder = getFolder(for: indexPath)

        let alert = UIAlertController(
            title: folder.name,
            message: "Choose an option",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Rename Folder", style: .default, handler: { _ in
            self.showRenameAlert(for: indexPath)
        }))

        alert.addAction(UIAlertAction(title: "Delete Folder", style: .destructive, handler: { _ in
            self.deleteFolder(at: indexPath)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }


    func showRenameAlert(for indexPath: IndexPath) {
        Haptics.impact(.light)

        guard let childId = activeChild?.id else { return }

        let folder = getFolder(for: indexPath)
        let oldName = folder.name

        let alert = UIAlertController(
            title: "Rename Folder",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = oldName
        }

        // ✅ THIS IS WHERE YOUR CODE GOES
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in

            guard let newName = alert.textFields?.first?.text,
                  !newName.trimmingCharacters(in: .whitespaces).isEmpty,
                  newName != oldName
            else { return }

            Task {
                do {
                    try await RecordFolderService.shared.renameFolder(
                        childId: childId,
                        oldName: oldName,
                        newName: newName
                    )

                    // 🔄 Reload fresh data from Supabase
                    await self.loadFoldersForActiveChild(childId)

                    guard let child = self.activeChild else {
                        print("⚠️ activeChild missing after rename")
                        return
                    }

                    await self.loadRecordsForActiveChild(child)

                } catch {
                    print("❌ Folder rename failed:", error)
                }
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    
    func deleteFolder(at indexPath: IndexPath) {
        Haptics.impact(.light)

        guard let child = activeChild else { return }

        let folder = getFolder(for: indexPath)
        let folderName = folder.name

        let alert = UIAlertController(
            title: "Delete Folder",
            message: "All records inside this folder will be deleted permanently.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task {
                do {
                    try await MedicalRecordService.shared
                        .deleteRecordsInFolder(
                            childId: child.id,
                            folderName: folderName
                        )

                    try await RecordFolderService.shared
                        .deleteFolder(
                            childId: child.id,
                            name: folderName
                        )

                    await self.loadFoldersForActiveChild(child.id)
                    await self.loadRecordsForActiveChild(child)

                } catch {
                    print("❌ Folder delete failed:", error)
                }
            }
        })


        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    
    func reloadForChild() {
        guard let childId = activeChild?.id else { return }

        isSearching = false
        searchBarView.text = nil

//        recentFolders.removeAll()
        filteredFolders.removeAll()
//        filteredRecentFolders.removeAll()

//        store.ensureDefaultFolders(for: childId)

        collectionView.reloadData()
    }
    
    func onActiveChildChanged() {
        guard isViewLoaded else { return } 
        guard let child = activeChild else { return }

//        recentFolders.removeAll()
        filteredFolders.removeAll()
//        filteredRecentFolders.removeAll()
        isSearching = false
        searchBarView.text = nil

        Task {
            do {
                // 1️⃣ Ensure default folders (Supabase)
                try await RecordFolderService.shared
                    .createDefaultFoldersIfNeeded(childId: child.id)

                // 2️⃣ Load folders
                await loadFoldersForActiveChild(child.id)

                // 3️⃣ Load records
                await loadRecordsForActiveChild(child)

            } catch {
                print("❌ Failed to load child data:", error)
            }
        }
    }

    private func loadDataIfPossible() {
        guard let child = activeChild else { return }
        
        showLoader()
        
        Task {
            do {
                try await RecordFolderService.shared
                    .createDefaultFoldersIfNeeded(childId: child.id)

                await loadFoldersForActiveChild(child.id)
                await loadRecordsForActiveChild(child)

            } catch {
                print("❌ Failed to load child data:", error)
            }
            
            await MainActor.run {
                self.hideLoader()
            }
        }
    }

    private func setupLoader() {
        loaderContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        loaderContainer.translatesAutoresizingMaskIntoConstraints = false
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

//    func createDefaultFoldersIfNeeded(childId: UUID) async throws {
//
//        let existing = try await fetchFolders(childId: childId)
//        guard existing.isEmpty else { return }
//
//        let defaults = ["Reports", "Prescriptions", "Vaccinations"]
//
//        for name in defaults {
//            let dto = RecordFolderDTO(
//                id: nil,
//                child_id: childId,
//                name: name,
//                created_at: nil
//            )
//
//            try await client
//                .from("record_folders")
//                .insert(dto)
//                .execute()
//        }
//    }
//

}

extension RecordManagerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1  // Section 0 = Recents, Section 1 = All
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//
//        return (section == 0) ? recentFolders.count : folders.count
//    }
//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//
//        if isSearching {
//            return (section == 0)
//                ? filteredRecentFolders.count
//                : filteredFolders.count
//        }
//
//        guard let childId = activeChild?.id else { return 0 }
//
//        return (section == 0)
//            ? recentFolders.count
//            : store.folders(for: childId).count
//    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        guard let childId = activeChild?.id else { return 0 }

        if isSearching {
            return filteredFolders.count
        }

        return store.folders(for: childId).count
    }




//    func getFolder(for indexPath: IndexPath) -> RecordFolder {
//
//        if isSearching {
//            return indexPath.section == 0
//                ? filteredRecentFolders[indexPath.item]
//                : filteredFolders[indexPath.item]
//        }
//
//        guard let childId = activeChild?.id else {
//            fatalError("activeChild missing in RecordManagerViewController")
//        }
//
//        return indexPath.section == 0
//            ? recentFolders[indexPath.item]
//            : store.folders(for: childId)[indexPath.item]
//    }
    func getFolder(for indexPath: IndexPath) -> RecordFolder {

        if isSearching {
            return filteredFolders[indexPath.item]
        }

        guard let childId = activeChild?.id else {
            fatalError("activeChild missing in RecordManagerViewController")
        }

        return store.folders(for: childId)[indexPath.item]
    }



    // MARK: - Cell
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecordCardCell",
            for: indexPath
        ) as! RecordCardCell

        guard let childId = activeChild?.id else { return cell }

        let folder = getFolder(for: indexPath)
        let count = store.files(
            for: childId,
            folderName: folder.name
        ).count

        cell.configure(with: folder, fileCount: count)

        cell.gestureRecognizers?.forEach {
            cell.removeGestureRecognizer($0)
        }

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPress)

        return cell
        
    }


    // MARK: - Header View
//    func collectionView(_ collectionView: UICollectionView,
//                        viewForSupplementaryElementOfKind kind: String,
//                        at indexPath: IndexPath) -> UICollectionReusableView {
//
//        let header = collectionView.dequeueReusableSupplementaryView(
//            ofKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "Header",
//            for: indexPath
//        )
//
//        // Clear old labels
//        header.subviews.forEach { $0.removeFromSuperview() }
//
//        // Add title
//        let title = UILabel(frame: CGRect(
//            x: 16,
//            y: 0,
//            width: collectionView.frame.width - 32,
//            height: 40
//        ))
//        title.font = .boldSystemFont(ofSize: 20)
//        title.text = (indexPath.section == 0) ? "Recents" : "All"
//
//        header.addSubview(title)
//        return header
//    }

//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        if isSearching {
//            // hide recents while searching
//            if section == 0 { return .zero }
//        } else {
//            if section == 0 && recentFolders.isEmpty { return .zero }
//        }
//
//        return CGSize(width: collectionView.frame.width, height: 40)
//    }


    // MARK: - Cell Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.bounds.width - 24) / 2
        return CGSize(width: width, height: 160)
    }
}

extension RecordManagerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        guard let childId = activeChild?.id else { return }

        let text = searchText.lowercased()

        if text.isEmpty {
            isSearching = false
            collectionView.reloadData()
            return
        }

        isSearching = true

        let allFolders = store.folders(for: childId)

        filteredFolders = allFolders.filter {
            $0.name.lowercased().contains(text)
        }

        collectionView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        collectionView.reloadData()
        searchBar.resignFirstResponder()
    }
}
