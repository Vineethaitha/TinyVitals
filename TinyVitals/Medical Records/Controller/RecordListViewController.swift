//
//  RecordListViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit
import QuickLook
import Lottie
import Supabase


class RecordListViewController: UIViewController {
    
    var activeChild: ChildProfile!

    let store = RecordsStore.shared


    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var addFileButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!

    
    
    var folderName: String = ""
    
//    var currentFiles: [MedicalFile] {
//        store.filesByFolder[folderName] ?? []
//    }

    
    
    var previewURL: URL?
    
    var filteredFiles: [MedicalFile] = []
    var isSearching = false

    private var emptyStateView: UIView?
    private var gradientLayer: CAGradientLayer?

    private var addButtonBlurView: UIVisualEffectView?

    var isSelectionMode = false
    var selectedRecords: Set<String> = []

    enum RecordSortOption {
        case nameAZ
        case nameZA
        case newest
        case oldest
    }

    var currentSort: RecordSortOption = .newest
    
    private var lottieView: LottieAnimationView?


    enum RecordListMode {
        case normal(folder: String)
        case aiResults
    }

    var mode: RecordListMode = .normal(folder: "")
    var aiFilteredFiles: [MedicalFile] = []

    var currentFiles: [MedicalFile] {
        switch mode {
        case .aiResults:
            return aiFilteredFiles

        case .normal(let folder):
            guard let childId = activeChild?.id else { return [] }
            return store.files(for: childId, folderName: folder)
        }
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()



    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let activeChild else {
            assertionFailure("RecordListViewController opened without activeChild")
            return
        }
        
        if case .normal = mode {
            assert(activeChild != nil, "❌ RecordListViewController opened in normal mode without activeChild")
        }
//        mode = .normal(folder: folderName)
        
        addFileButton.configuration = nil
        addFileButton.layer.cornerRadius = addFileButton.frame.height / 2
        addFileButton.clipsToBounds = true
        addFileButton.setImage(UIImage(systemName: "doc.badge.plus"), for: .normal)
        
        title = folderName 
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        
        tableView.isEditing = false
        tableView.allowsMultipleSelectionDuringEditing = true

        let nib = UINib(nibName: "RecordListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RecordListCell")
            
        searchBar.delegate = self
        
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPress)

        configureSortMenu(for: moreButton)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//           tap.cancelsTouchesInView = false
//           view.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }


    func updateUI() {
        let files = currentFiles

        if files.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }

        tableView.reloadData()
    }




    
    @IBAction func addFileButtonTapped(_ sender: UIButton) {

        let vc = AddRecordViewController(
            nibName: "AddRecordViewController",
            bundle: nil
        )

        vc.activeChild = activeChild
        vc.availableFolders = store.folders(for: activeChild.id).map { $0.name }
        vc.selectedFolderName = folderName

        vc.onRecordSaved = { [weak self] in
            self?.updateUI()
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 650 }]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
    }
    

    @objc func shareButtonTapped() {

        // If no records, do nothing
        let files = isSearching ? filteredFiles : currentFiles
        guard !files.isEmpty else { return }

        let alert = UIAlertController(
            title: "Share Records",
            message: "Choose a record to share",
            preferredStyle: .actionSheet
        )

        for record in files {
            alert.addAction(UIAlertAction(title: record.title, style: .default) { _ in
                self.share(record: record)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func share(record: MedicalFile) {

        var items: [Any] = []

        if let pdfURL = record.pdfURL {
            items.append(pdfURL)
        } else if let image = record.thumbnail {
            items.append(image)
        }

        guard !items.isEmpty else { return }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // iPad safety
        activityVC.popoverPresentationController?.sourceView = view

        present(activityVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let record = isSearching
            ? filteredFiles[indexPath.row]
            : currentFiles[indexPath.row]

        Task {
            do {
                // 1️⃣ Get signed URL from Supabase
                let signedURL = try await MedicalRecordService.shared
                    .getSignedFileURL(path: record.filePath)

                // 2️⃣ Download actual file
                let localURL: URL

                if record.fileType == "image" {
                    let image = try await MedicalRecordService.shared
                        .downloadImage(from: signedURL)

                    guard let url = saveTempImage(image) else { return }
                    localURL = url
                } else {
                    localURL = try await MedicalRecordService.shared
                        .downloadFile(from: signedURL, fileType: record.fileType)
                }

                // 3️⃣ Open QuickLook with REAL file
                DispatchQueue.main.async {
                    self.previewURL = localURL

                    let previewVC = QLPreviewController()
                    previewVC.dataSource = self
                    self.navigationController?.pushViewController(previewVC, animated: true)
                }

            } catch {
                print("❌ Preview failed:", error)
            }
        }
    }
    

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        guard tableView.isEditing else { return }

        let record = isSearching
            ? filteredFiles[indexPath.row]
            : currentFiles[indexPath.row]

        selectedRecords.remove(record.id)
        updateActionButtonsState()
    }
    
    @objc func deleteSelectedRecords() {

        guard !selectedRecords.isEmpty else { return }
        guard let childId = activeChild?.id else { return }

        let alert = UIAlertController(
            title: "Delete Records",
            message: "Are you sure you want to delete the selected records?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task {
                do {
                    let records = self.store.filesByChild[childId]?.filter {
                        self.selectedRecords.contains($0.id)
                    } ?? []

                    for record in records {
                        // 1️⃣ Delete DB row
                        try await MedicalRecordService.shared
                            .deleteRecord(id: UUID(uuidString: record.id)!)

                        // 2️⃣ Delete from storage (✅ correct bucket name)
                        try await SupabaseAuthService.shared.client
                            .storage
                            .from("medical-records")
                            .remove(paths: [record.filePath])
                    }

                    // 3️⃣ Remove locally
                    self.store.filesByChild[childId]?.removeAll {
                        self.selectedRecords.contains($0.id)
                    }

                    if self.isSearching {
                        self.filteredFiles.removeAll {
                            self.selectedRecords.contains($0.id)
                        }
                    }

                    DispatchQueue.main.async {
                        self.exitSelectionMode()
                        self.updateUI()
                    }

                } catch {
                    print("❌ Bulk delete failed:", error)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }






    func updateShareButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = !selectedRecords.isEmpty
    }
    
    @objc func shareSelectedRecords() {

        guard let childId = activeChild?.id else { return }

        let records = store.filesByChild[childId]?.filter {
            selectedRecords.contains($0.id)
        } ?? []

        var items: [Any] = []

        for record in records {
            if let pdf = record.pdfURL {
                items.append(pdf)
            } else if let image = record.thumbnail {
                items.append(image)
            }
        }

        guard !items.isEmpty else { return }

        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        vc.popoverPresentationController?.sourceView = view
        present(vc, animated: true)
    }



    
    func saveTempImage(_ image: UIImage) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("preview.jpg")
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: url)
            return url
        }
        return nil
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let point = gesture.location(in: tableView)

        guard let indexPath = tableView.indexPathForRow(at: point) else {
            return
        }

        showOptionsForRecord(at: indexPath)
    }

    
    func showOptionsForRecord(at indexPath: IndexPath) {

        let record = isSearching
            ? filteredFiles[indexPath.row]
            : currentFiles[indexPath.row]


        let alert = UIAlertController(
            title: record.title,
            message: "Choose an option",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Select", style: .default) { _ in
            self.enterSelectionMode()
        })


        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            self.openEditRecord(for: indexPath)
        }))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteRecord(at: indexPath)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    func enterSelectionMode() {
        isSelectionMode = true
        selectedRecords.removeAll()

        tableView.setEditing(true, animated: true)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(exitSelectionMode)
        )

        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareSelectedRecords)
        )

        let deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteSelectedRecords)
        )

        navigationItem.rightBarButtonItems = [shareButton, deleteButton]

        updateActionButtonsState()
    }

    func updateActionButtonsState() {
        let hasSelection = !selectedRecords.isEmpty
        navigationItem.rightBarButtonItems?.forEach {
            $0.isEnabled = hasSelection
        }
    }




    
    @objc func exitSelectionMode() {
        isSelectionMode = false
        selectedRecords.removeAll()

        tableView.setEditing(false, animated: true)

        // Clear visible selections
        if let selected = tableView.indexPathsForSelectedRows {
            selected.forEach {
                tableView.deselectRow(at: $0, animated: false)
            }
        }

        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }

    
    func deleteRecord(at indexPath: IndexPath) {

        let record = isSearching
            ? filteredFiles[indexPath.row]
            : currentFiles[indexPath.row]

        Task {
            do {
                // 1️⃣ Delete DB row
                try await MedicalRecordService.shared
                    .deleteRecord(id: UUID(uuidString: record.id)!)

                // 2️⃣ Delete file from storage
                try await SupabaseAuthService.shared.client
                    .storage
                    .from("medical-records")
                    .remove(paths: [record.filePath])

                // 3️⃣ Remove locally
                store.filesByChild[activeChild.id]?.removeAll {
                    $0.id == record.id
                }

                if isSearching {
                    filteredFiles.removeAll { $0.id == record.id }
                }

                // 4️⃣ Refresh UI
                DispatchQueue.main.async {
                    self.updateUI()
                }

            } catch {
                print("❌ Delete failed:", error)
            }
        }
    }





    func openEditRecord(for indexPath: IndexPath) {

        guard let childId = activeChild?.id else { return }

        let record = isSearching
            ? filteredFiles[indexPath.row]
            : currentFiles[indexPath.row]

        let vc = AddRecordViewController(
            nibName: "AddRecordViewController",
            bundle: nil
        )

        vc.isEditingRecord = true
        vc.existingRecord = record
        vc.activeChild = activeChild

        // ✅ FIXED: child-scoped folders
        vc.availableFolders = store.folders(for: childId).map { $0.name }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 650 }]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
    }

    

    func configureSortMenu(for button: UIButton) {

        let selectAction = UIAction(
            title: "Select",
            image: UIImage(systemName: "checkmark.circle"),
            attributes: [],
            handler: { _ in
                self.enterSelectionMode()
            }
        )

        let nameAZ = UIAction(
            title: "Name (A → Z)",
            image: UIImage(systemName: "textformat"),
            state: currentSort == .nameAZ ? .on : .off
        ) { _ in
            self.applySort(.nameAZ)
            self.configureSortMenu(for: button)
        }

        let nameZA = UIAction(
            title: "Name (Z → A)",
            image: UIImage(systemName: "textformat.size"),
            state: currentSort == .nameZA ? .on : .off
        ) { _ in
            self.applySort(.nameZA)
            self.configureSortMenu(for: button)
        }

        let newest = UIAction(
            title: "Newest First",
            image: UIImage(systemName: "clock.arrow.circlepath"),
            state: currentSort == .newest ? .on : .off
        ) { _ in
            self.applySort(.newest)
            self.configureSortMenu(for: button)
        }

        let oldest = UIAction(
            title: "Oldest First",
            image: UIImage(systemName: "clock"),
            state: currentSort == .oldest ? .on : .off
        ) { _ in
            self.applySort(.oldest)
            self.configureSortMenu(for: button)
        }

        button.menu = UIMenu(
            title: "",
            children: [
                selectAction,
                UIMenu(
                    title: "Sort By",
                    options: [.singleSelection],
                    children: [
                        nameAZ,
                        nameZA,
                        newest,
                        oldest
                    ]
                )
            ]
        )

        button.showsMenuAsPrimaryAction = true
    }



    
    func applySort(_ option: RecordSortOption) {
        currentSort = option

        var files = store.files(for: activeChild.id, folderName: folderName)

        switch option {
        case .nameAZ:
            files.sort { $0.title.lowercased() < $1.title.lowercased() }

        case .nameZA:
            files.sort { $0.title.lowercased() > $1.title.lowercased() }

        case .newest:
            files.sort { $0.date > $1.date }

        case .oldest:
            files.sort { $0.date < $1.date }
        }

        store.updateFiles(files, for: activeChild.id, folderName: folderName)

        // Update filtered list if searching
        if isSearching {
            filteredFiles = files.filter {
                $0.title.lowercased().contains(searchBar.text?.lowercased() ?? "")
            }
        }

        tableView.reloadData()
    }
    
    func showEmptyState() {

        addFileButton.isHidden = true
        
        let emptyView = EmptyStateAnimationView(
            animationName: "FileClosetAnimation2",
            message: "Add your medical records\nand keep everything organised",
            animationSize: 220,
            actionTitle: "Add"
        ) { [weak self] in
            self?.addFileButtonTapped(self!.addFileButton)
        }

        tableView.backgroundView = emptyView
        emptyStateView = emptyView
    }

    func animateIcon(_ icon: UIImageView) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = -6
        animation.toValue = 6
        animation.duration = 1.6
        animation.autoreverses = true
        animation.repeatCount = .infinity
        icon.layer.add(animation, forKey: "float")
    }

    func hideEmptyState() {

        guard let emptyView = emptyStateView as? EmptyStateAnimationView else {
            tableView.backgroundView = nil
            addFileButton.isHidden = false
            return
        }

        emptyView.stop()
        addFileButton.isHidden = false

        UIView.animate(withDuration: 0.25, animations: {
            emptyView.alpha = 0
        }) { _ in
            self.tableView.backgroundView = nil
            self.emptyStateView = nil
            self.addFileButton.isHidden = false
        }
    }
    
//    func presentSummary(for record: MedicalFile) {
//
//        let summaryVC = RecordSummaryViewController(record: record)
//        let nav = UINavigationController(rootViewController: summaryVC)
//
//        nav.modalPresentationStyle = .pageSheet
//
//        if let sheet = nav.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//            sheet.prefersGrabberVisible = true
//        }
//
//        present(nav, animated: true)
//    }
    
    func presentSummary(for record: MedicalFile) {

        Task {
            do {
                let signedURL = try await MedicalRecordService.shared
                    .getSignedFileURL(path: record.filePath)

                let localURL: URL

                if record.fileType == "image" {
                    let image = try await MedicalRecordService.shared
                        .downloadImage(from: signedURL)

                    guard let url = saveTempImage(image) else { return }
                    localURL = url
                } else {
                    localURL = try await MedicalRecordService.shared
                        .downloadFile(from: signedURL, fileType: record.fileType)
                }

                DispatchQueue.main.async {
                    let summaryVC = RecordSummaryViewController(
                        record: record,
                        localFileURL: localURL
                    )

                    let nav = UINavigationController(rootViewController: summaryVC)
                    nav.modalPresentationStyle = .pageSheet

                    if let sheet = nav.sheetPresentationController {
                        sheet.detents = [.medium(), .large()]
                        sheet.prefersGrabberVisible = true
                    }

                    self.present(nav, animated: true)
                }

            } catch {
                print("❌ Summary load failed:", error)
            }
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

extension RecordListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredFiles.count : currentFiles.count

    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath)
    -> UITableViewCell.EditingStyle {
        return .insert   // 👈 this enables selection circles
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RecordListCell",
            for: indexPath
        ) as! RecordListCell

        let record = isSearching
            ? filteredFiles[indexPath.row]
            : currentFiles[indexPath.row]

        cell.configure(with: record)

        cell.onSummaryTap = { [weak self] in
            self?.presentSummary(for: record)
        }
        
        // IMPORTANT: allow default iOS selection UI
        cell.selectionStyle = .default

        return cell
    }





}


extension RecordListViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewURL == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewURL! as NSURL
    }
}

extension RecordListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.lowercased()

        if text.isEmpty {
            isSearching = false
            updateUI()
            return
        }

        isSearching = true
        hideEmptyState()

        filteredFiles = currentFiles.filter {
            $0.title.lowercased().contains(text) ||
            $0.hospital.lowercased().contains(text) ||
            dateFormatter.string(from: $0.date).lowercased().contains(text)
        }


        tableView.reloadData()
    }


    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        updateUI()
        searchBar.resignFirstResponder()
    }

}
