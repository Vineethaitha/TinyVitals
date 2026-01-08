//
//  RecordManagerViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit

class RecordManagerViewController: UIViewController {
    
    let store = RecordsStore.shared

    @IBOutlet weak var searchBarView: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var threeDotsButton: UIButton!
    
    var recentFolders: [RecordFolder] = []

    var filteredFolders: [RecordFolder] = []
    var filteredRecentFolders: [RecordFolder] = []
    var isSearching = false
    
    enum FolderSortOption {
        case nameAZ
        case nameZA
        case mostFiles
        case leastFiles
    }


    var selectedSortOption: FolderSortOption = .nameAZ
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.configuration = nil
        addButton.layer.cornerRadius = addButton.frame.height / 2
        addButton.clipsToBounds = true
        addButton.setImage(UIImage(systemName: "doc.badge.plus"), for: .normal)
        
        if store.folders.isEmpty {
            store.folders = [
                RecordFolder(name: "Reports", icon: UIImage(systemName: "folder.fill")),
                RecordFolder(name: "Prescriptions", icon: UIImage(systemName: "pills.fill")),
                RecordFolder(name: "Vaccinations", icon: UIImage(systemName: "bandage.fill"))
            ]
        }

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.backgroundColor = UIColor.clear

        let nib = UINib(nibName: "RecordCardCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "RecordCardCell")
        
        collectionView.register(UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header")
        
        searchBarView.delegate = self
        
        setupSortMenu()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//            tap.cancelsTouchesInView = false
//            view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
    }
    
    @IBAction func magicWandTapped() {
        let vc = AIQueryViewController(
            nibName: "AIQueryViewController",
            bundle: nil
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    
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
        store.folders.sort {
            ascending ? $0.name < $1.name : $0.name > $1.name
        }
        collectionView.reloadData()
    }

    func sortFoldersByFileCount(descending: Bool) {
        store.folders.sort {
            let c1 = store.filesByFolder[$0.name]?.count ?? 0
            let c2 = store.filesByFolder[$1.name]?.count ?? 0
            return descending ? c1 > c2 : c1 < c2
        }
        collectionView.reloadData()
    }



    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let folder = getFolder(for: indexPath)

        // Add to recents (avoid duplicates)
        if let index = recentFolders.firstIndex(where: { $0.name == folder.name }) {
            recentFolders.remove(at: index)
        }
        recentFolders.insert(folder, at: 0)

        // Limit to last 5
        if recentFolders.count > 5 {
            recentFolders.removeLast()
        }

        collectionView.reloadData()

        // Navigate to next screen
        let vc = RecordListViewController(nibName: "RecordListViewController", bundle: nil)
        vc.folderName = folder.name
        vc.folderName = folder.name
        navigationController?.pushViewController(vc, animated: true)
        
//        print("hi")
    }

    
    
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        let vc = CalendarRecordsViewController(
            nibName: "CalendarRecordsViewController",
            bundle: nil
        )

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @IBAction func addFileButtonTapped(_ sender: UIButton) {

        let sheetHeight: CGFloat = 650

        let vc = AddRecordViewController(
            nibName: "AddRecordViewController",
            bundle: nil
        )

        vc.availableFolders = store.folders.map { $0.name }

        vc.onRecordSaved = { [weak self] in
            guard let self = self else { return }

            // Reload folder counts
            self.collectionView.reloadData()
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
    
    func createFolder(named name: String) {
        let newFolder = RecordFolder(
            name: name,
            icon: UIImage(systemName: "folder.fill"),
            color: UIColor.randomIOSFolderColor()
        )

        store.folders.append(newFolder)
        collectionView.reloadData()
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

        let folder = getFolder(for: indexPath)

        let alert = UIAlertController(title: "Rename Folder",
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = folder.name
        }

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let newName = alert.textFields?.first?.text,
                  !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

            let oldName = folder.name

            // 1️⃣ Update folders list
            if let index = self.store.folders.firstIndex(where: { $0.name == oldName }) {
                self.store.folders[index].name = newName
            }

            // 2️⃣ Move files to new key
            if let files = self.store.filesByFolder[oldName] {
                self.store.filesByFolder[newName] = files.map {
                    var f = $0
                    f.folderName = newName
                    return f
                }
                self.store.filesByFolder.removeValue(forKey: oldName)
            }

            // 3️⃣ Update recents
            if let rIndex = self.recentFolders.firstIndex(where: { $0.name == oldName }) {
                self.recentFolders[rIndex].name = newName
            }

            self.collectionView.reloadData()
        })


        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }


    
    func deleteFolder(at indexPath: IndexPath) {

        let folder = getFolder(for: indexPath)
        let folderName = folder.name

        // 1️⃣ Remove from ALL folders
        store.folders.removeAll { $0.name == folderName }

        // 2️⃣ Remove from RECENTS
        recentFolders.removeAll { $0.name == folderName }

        // 3️⃣ Remove all files of this folder
        store.filesByFolder.removeValue(forKey: folderName)

        // 4️⃣ Refresh UI
        collectionView.reloadData()
    }

}

extension RecordManagerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2  // Section 0 = Recents, Section 1 = All
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//
//        return (section == 0) ? recentFolders.count : folders.count
//    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        if isSearching {
            return (section == 0) ? filteredRecentFolders.count : filteredFolders.count
        }

        return (section == 0) ? recentFolders.count : store.folders.count
    }


    func getFolder(for indexPath: IndexPath) -> RecordFolder {

        if isSearching {
            return indexPath.section == 0 ?
                filteredRecentFolders[indexPath.item] :
                filteredFolders[indexPath.item]
        }

        return indexPath.section == 0 ?
            recentFolders[indexPath.item] :
            store.folders[indexPath.item]
    }

    // MARK: - Cell
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecordCardCell",
            for: indexPath
        ) as! RecordCardCell

        let folder = getFolder(for: indexPath)
        let count = store.filesByFolder[folder.name]?.count ?? 0
        cell.configure(with: folder, fileCount: count)


        // Remove old gestures
        cell.gestureRecognizers?.forEach { cell.removeGestureRecognizer($0) }

        // Add long-press gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPress)

        return cell
    }

    // MARK: - Header View
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header",
            for: indexPath
        )

        // Clear old labels
        header.subviews.forEach { $0.removeFromSuperview() }

        // Add title
        let title = UILabel(frame: CGRect(
            x: 16,
            y: 0,
            width: collectionView.frame.width - 32,
            height: 40
        ))
        title.font = .boldSystemFont(ofSize: 20)
        title.text = (indexPath.section == 0) ? "Recents" : "All"

        header.addSubview(title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        if isSearching {
            // hide recents while searching
            if section == 0 { return .zero }
        } else {
            if section == 0 && recentFolders.isEmpty { return .zero }
        }

        return CGSize(width: collectionView.frame.width, height: 40)
    }


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

        let text = searchText.lowercased()

        if text.isEmpty {
            isSearching = false
            collectionView.reloadData()
            return
        }

        isSearching = true

        // Filter All folders
        filteredFolders = store.folders.filter {
            $0.name.lowercased().contains(text)
        }

        // Filter Recents
        filteredRecentFolders = recentFolders.filter {
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
