//
//  RecordManagerViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit

class RecordManagerViewController: UIViewController {
    
    let store = RecordsStore.shared
    var activeChild: ChildProfile!
    
    
//    let store = RecordsStore.shared

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
        
        guard let activeChild else {
            assertionFailure("❌ RecordManagerViewController opened without activeChild")
            return
        }

        let childId = activeChild.id

        if store.foldersByChild[childId] == nil {
            store.foldersByChild[childId] = [
                RecordFolder(name: "Reports", icon: UIImage(systemName: "folder.fill")),
                RecordFolder(name: "Prescriptions", icon: UIImage(systemName: "pills.fill")),
                RecordFolder(name: "Vaccinations", icon: UIImage(systemName: "bandage.fill"))
            ]
            store.filesByChild[childId] = []
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
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

        if let index = recentFolders.firstIndex(where: { $0.name == folder.name }) {
            recentFolders.remove(at: index)
        }
        recentFolders.insert(folder, at: 0)

        if recentFolders.count > 5 {
            recentFolders.removeLast()
        }

        collectionView.reloadData()


        let vc = RecordListViewController(
            nibName: "RecordListViewController",
            bundle: nil
        )

        vc.activeChild = activeChild
        vc.mode = .normal(folder: folder.name)
        vc.folderName = folder.name
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
//        print("hi")
    }

    
    
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        let vc = CalendarRecordsViewController(
            nibName: "CalendarRecordsViewController",
            bundle: nil
        )

        vc.activeChild = activeChild

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
        
        vc.activeChild = activeChild
        vc.availableFolders = store.folders(for: activeChild.id).map { $0.name }
        vc.onRecordSaved = { [weak self] in
            guard let self = self else { return }

        
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

        guard let childId = activeChild?.id else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let newFolder = RecordFolder(
            name: trimmedName,
            icon: UIImage(systemName: "folder.fill"),
            color: UIColor.randomIOSFolderColor()
        )

        
        store.foldersByChild[childId, default: []].append(newFolder)

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

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in

            guard let newName = alert.textFields?.first?.text,
                  !newName.trimmingCharacters(in: .whitespaces).isEmpty,
                  newName != oldName
            else { return }

            
            if var folders = self.store.foldersByChild[childId],
               let index = folders.firstIndex(where: { $0.name == oldName }) {

                folders[index].name = newName
                self.store.foldersByChild[childId] = folders
            }

            
            self.store.filesByChild[childId] = self.store.filesByChild[childId]?.map {
                var file = $0
                if file.folderName == oldName {
                    file.folderName = newName
                }
                return file
            }

            
            if let rIndex = self.recentFolders.firstIndex(where: { $0.name == oldName }) {
                self.recentFolders[rIndex].name = newName
            }

            self.collectionView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }



    
    func deleteFolder(at indexPath: IndexPath) {

        guard let childId = activeChild?.id else { return }

        let folder = getFolder(for: indexPath)
        let folderName = folder.name

        
        store.foldersByChild[childId]?.removeAll {
            $0.name == folderName
        }

        
        recentFolders.removeAll {
            $0.name == folderName
        }

        
        store.filesByChild[childId]?.removeAll {
            $0.folderName == folderName
        }

        
        collectionView.reloadData()
    }
    
    func reloadForChild() {
        guard let childId = activeChild?.id else { return }

        isSearching = false
        searchBarView.text = nil

        recentFolders.removeAll()
        filteredFolders.removeAll()
        filteredRecentFolders.removeAll()

        if store.foldersByChild[childId] == nil {
            store.foldersByChild[childId] = [
                RecordFolder(name: "Reports", icon: UIImage(systemName: "folder.fill")),
                RecordFolder(name: "Prescriptions", icon: UIImage(systemName: "pills.fill")),
                RecordFolder(name: "Vaccinations", icon: UIImage(systemName: "bandage.fill"))
            ]
            store.filesByChild[childId] = []
        }

        collectionView.reloadData()
    }



}

extension RecordManagerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
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

        return (section == 0)
            ? recentFolders.count
            : store.folders(for: activeChild.id).count

    }


    func getFolder(for indexPath: IndexPath) -> RecordFolder {

        if isSearching {
            return indexPath.section == 0 ?
                filteredRecentFolders[indexPath.item] :
                filteredFolders[indexPath.item]
        }

        return indexPath.section == 0
            ? recentFolders[indexPath.item]
            : store.folders(for: activeChild.id)[indexPath.item]

    }

    // MARK: - Cell
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecordCardCell",
            for: indexPath
        ) as! RecordCardCell

        let folder = getFolder(for: indexPath)
        let count = store.files(
            for: activeChild.id,
            folderName: folder.name
        ).count


        cell.configure(with: folder, fileCount: count)

        cell.gestureRecognizers?.forEach { cell.removeGestureRecognizer($0) }

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

        
        header.subviews.forEach { $0.removeFromSuperview() }

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
