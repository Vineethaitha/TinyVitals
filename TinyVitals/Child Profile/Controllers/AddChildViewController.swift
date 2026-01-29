//  AddChildViewController.swift
//  ChildProfile
//
//  Created by admin0 on 12/21/25.
//

import UIKit
import PhotosUI


protocol AddChildDelegate: AnyObject {
    func didAddChild(_ child: ChildProfile)
}

class AddChildViewController: UIViewController, AddMeasureDelegate {
    
    enum Mode {
        case add
        case view
        case edit
    }

    var mode: Mode = .add
    var child: ChildProfile?
    
    weak var addDelegate: AddChildDelegate?
    weak var updateDelegate: ChildProfileDelegate?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var bloodGroupTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!

    private let years = [""] + Array(0...18).map { "\($0)" }
    private let months = [""] + Array(0...11).map { "\($0)" }
    
    private let agePicker = UIPickerView()

    private let bloodGroups = ["", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    private let bloodGroupPicker = UIPickerView()
    
    private let genders = ["", "Male", "Female", "Other"]
    private let genderPicker = UIPickerView()
    
    private var didPickAvatarImage = false


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        
        saveButton.configuration = nil
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.clipsToBounds = true
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        if let child = child {
            mode = .view
            populate(with: child)
            setEditable(false)
            setAgeFromDOB(child.dob)
        } else {
            ageTextField.text = nil
            mode = .add
            setEditable(true)
        }

        // 🔥 THIS IS THE IMPORTANT LINE
        saveButton.isHidden = (mode != .add)
        saveButton.bottomAnchor.constraint(
            lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor,
            constant: -16
        ).isActive = true
        
        
        
        setupNavBar()

        agePicker.dataSource = self
        agePicker.delegate = self

        ageTextField.inputView = agePicker

//        agePicker.selectRow(0, inComponent: 0, animated: false)
//        agePicker.selectRow(0, inComponent: 1, animated: false)
        
        bloodGroupPicker.dataSource = self
        bloodGroupPicker.delegate = self
        bloodGroupTextField.inputView = bloodGroupPicker
        
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderTextField.inputView = genderPicker
        
        avatarImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(avatarTapped)
            )
        )
        
        weightTextField.delegate = self
        heightTextField.delegate = self


    }

    
    @objc private func handleDismissKeyboard() {
        view.endEditing(true)
    }

    


    @IBAction func addChildTapped(_ sender: UIButton) {
        
        guard
            let name = nameTextField.text, !name.isEmpty,
            let gender = genderTextField.text, !gender.isEmpty,
            let bloodGroup = bloodGroupTextField.text, !bloodGroup.isEmpty,
            let userId = AppState.shared.userId
        else {
            return
        }
        
        let yRow = agePicker.selectedRow(inComponent: 0)
        let mRow = agePicker.selectedRow(inComponent: 1)
        guard yRow > 0 || mRow > 0 else { return }
        
        let selectedYears  = yRow > 0 ? Int(years[yRow]) ?? 0 : 0
        let selectedMonths = mRow > 0 ? Int(months[mRow]) ?? 0 : 0
        
        var components = DateComponents()
        components.year = -selectedYears
        components.month = -selectedMonths
        
        let dob = Calendar.current.date(byAdding: components, to: Date()) ?? Date()
        Task {
            do {
                let userUUID = UUID(uuidString: userId)!
                
                // 1️⃣ Create child (THIS WORKS)
                try await ChildService.shared.addChild(
                    userId: userUUID,
                    name: name,
                    dob: dob,
                    gender: gender
                )
                
                // 2️⃣ Fetch children
                let childDTOs = try await ChildService.shared.fetchChildren(userId: userUUID)
                let profiles = childDTOs.map { ChildProfile(dto: $0) }
                
                AppState.shared.setChildren(profiles)
                
                if let newChild = profiles.last {
                    AppState.shared.setActiveChild(newChild)
                }
                
                // ✅ DISMISS FIRST — UI MUST WIN
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
                
                // 3️⃣ Fire-and-forget vaccine generation
                if let newChildDTO = childDTOs.last, let childId = newChildDTO.id {
                    Task.detached {
                        try? await VaccinationService.shared.generateVaccinesForChild(
                            childId: childId,
                            dob: dob
                        )
                    }
                }
                
            } catch {
                print("❌ Child creation failed:", error)
            }
        }
    }
    
    private func updateAgeText() {
        let yString = years[agePicker.selectedRow(inComponent: 0)]
        let mString = months[agePicker.selectedRow(inComponent: 1)]

        guard
            let y = Int(yString),
            let m = Int(mString)
        else {
            ageTextField.text = ""
            return
        }

        if y == 0 {
            ageTextField.text = "\(m) month\(m == 1 ? "" : "s")"
        } else {
            ageTextField.text = "\(y) yr \(m) mo"
        }
    }




    @objc private func avatarTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func loadImage(filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }

    private func populate(with child: ChildProfile) {
        nameTextField.text = child.name
        genderTextField.text = child.gender
        bloodGroupTextField.text = child.bloodGroup
        weightTextField.text = child.weight.map { "\($0)" }
        heightTextField.text = child.height.map { "\($0)" }

        if let filename = child.photoFilename {
            avatarImageView.image = loadImage(filename: filename)
        }
    }
    
    private func setEditable(_ editable: Bool) {
        [nameTextField,
         genderTextField,
         bloodGroupTextField,
         weightTextField,
         heightTextField].forEach {
            $0?.isUserInteractionEnabled = editable
            $0?.alpha = editable ? 1.0 : 0.6
        }

        // ✅ AGE FIELD
        ageTextField.isUserInteractionEnabled = (mode != .view)
        ageTextField.alpha = (mode != .view) ? 1.0 : 0.6

        // ✅ AVATAR FIELD
        avatarImageView.isUserInteractionEnabled = (mode != .view)
//        avatarImageView.alpha = 1.0
    }



    private func setupNavBar() {
        switch mode {

        case .add:
            title = "Add Child"
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closeTapped)
            )
            navigationItem.rightBarButtonItem = nil

        case .view:
            title = "Child Profile"

            let deleteButton = UIBarButtonItem(
                title: "Delete",
                style: .plain,
                target: self,
                action: #selector(deleteTapped)
            )
            deleteButton.tintColor = .systemRed

            let editButton = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )

            navigationItem.rightBarButtonItems = [editButton, deleteButton]

        case .edit:
            title = "Edit Child"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save",
                style: .done,
                target: self,
                action: #selector(saveEditsTapped)
            )
        }
    }


    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Child?",
            message: "This will permanently delete all records for this child.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive
        ) { _ in
            self.performDelete()
        })

        present(alert, animated: true)
    }

    private func performDelete() {
        guard let child = child else { return }

        Task {
            do {
                try await ChildService.shared.deleteChild(childId: child.id)

                AppState.shared.removeChild(child)

                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)

                    if let tabBar = UIApplication.shared
                        .connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.windows.first })
                        .first?
                        .rootViewController as? MainTabBarController {

                        tabBar.handlePostDeleteFlow()
                    }
                }

            } catch {
                print("❌ Failed to delete child:", error)
            }
        }
    }


    
    @objc private func editTapped() {
        mode = .edit
        setEditable(true)
        setupNavBar()
    }
    
    @objc private func saveEditsTapped() {

        guard let child = child else { return }

        var updatedPhotoFilename = child.photoFilename

        if didPickAvatarImage {
            updatedPhotoFilename = saveImageToDisk(avatarImageView.image!)
        }

        let updatedChild = ChildProfile(
            id: child.id,
            name: nameTextField.text ?? child.name,
            dob: child.dob,
            gender: genderTextField.text ?? child.gender,
            bloodGroup: bloodGroupTextField.text ?? child.bloodGroup,
            weight: Double(weightTextField.text ?? ""),
            height: Double(heightTextField.text ?? ""),
            photoFilename: updatedPhotoFilename
        )

        updateDelegate?.didUpdateChild(updatedChild)
        navigationController?.popViewController(animated: true)
    }

    
    private func setAgeFromDOB(_ dob: Date) {
        let calendar = Calendar.current
        let now = Date()

        let components = calendar.dateComponents([.year, .month], from: dob, to: now)

        let y = components.year ?? 0
        let m = components.month ?? 0

        ageTextField.text = y == 0
            ? "\(m) month\(m == 1 ? "" : "s")"
            : "\(y) yr \(m) mo"

        // ✅ IMPORTANT: force picker to load components
        agePicker.reloadAllComponents()

        DispatchQueue.main.async {
            if let yIndex = self.years.firstIndex(of: "\(y)") {
                self.agePicker.selectRow(yIndex, inComponent: 0, animated: false)
            }
            if let mIndex = self.months.firstIndex(of: "\(m)") {
                self.agePicker.selectRow(mIndex, inComponent: 1, animated: false)
            }
        }
    }


    
    private func defaultAvatarForGender(_ gender: String) -> UIImage {
        if gender.lowercased() == "male" {
            return UIImage(named: "BabyBoy")!
        } else {
            return UIImage(named: "BabyGirl")!
        }
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if textField == weightTextField {
            openAddMeasure(type: .weight)
            return false
        }

        if textField == heightTextField {
            openAddMeasure(type: .height)
            return false
        }

        return true
    }
    
    private func openAddMeasure(type: AddMeasureViewController.MeasureType) {

        let vc = AddMeasureViewController(
            nibName: "AddMeasureViewController",
            bundle: nil
        )

        vc.measureType = type
        vc.delegate = self

        if type == .weight {
            vc.selectedInitialValue = Double(weightTextField.text ?? "") ?? 0
        } else {
            vc.selectedInitialValue = Double(heightTextField.text ?? "") ?? 0
        }

        present(vc, animated: true)
    }


    func didSaveValue(_ value: Double, type: AddMeasureViewController.MeasureType) {

        switch type {
        case .weight:
            weightTextField.text = String(format: "%.1f", value)

        case .height:
            heightTextField.text = String(format: "%.1f", value)

        default:
            break
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
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

extension AddChildViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView == agePicker ? 2 : 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == agePicker {
            return component == 0 ? years.count : months.count
        } else if pickerView == bloodGroupPicker {
            return bloodGroups.count
        } else {
            return genders.count
        }
    }

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {

        if pickerView == agePicker {
            if row == 0 { return "" }

            if component == 0 {
                let y = Int(years[row]) ?? 0
                return y == 1 ? "1 year" : "\(y) years"
            } else {
                let m = Int(months[row]) ?? 0
                return m == 1 ? "1 month" : "\(m) months"
            }
        }
        else if pickerView == bloodGroupPicker {
            return bloodGroups[row]
        }
        else {
            return genders[row]
        }
    }


    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        if pickerView == agePicker {
            let yRow = agePicker.selectedRow(inComponent: 0)
            let mRow = agePicker.selectedRow(inComponent: 1)

            // 🚫 Ignore until user selects real values
            guard yRow > 0 || mRow > 0 else {
                ageTextField.text = ""
                return
            }

            let y = yRow > 0 ? Int(years[yRow]) ?? 0 : 0
            let m = mRow > 0 ? Int(months[mRow]) ?? 0 : 0

            if y == 0 {
                ageTextField.text = "\(m) month\(m == 1 ? "" : "s")"
            } else {
                ageTextField.text = "\(y) yr \(m) mo"
            }
        }
        else if pickerView == bloodGroupPicker {
            guard row > 0 else {
                bloodGroupTextField.text = ""
                return
            }
            bloodGroupTextField.text = bloodGroups[row]
        }
        else if pickerView == genderPicker {
            guard row > 0 else {
                genderTextField.text = ""
                return
            }
            genderTextField.text = genders[row]
        }
    }


}

extension AddChildViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard
            let itemProvider = results.first?.itemProvider,
            itemProvider.canLoadObject(ofClass: UIImage.self)
        else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let img = image as? UIImage {
                    self?.avatarImageView.image = img
                    self?.didPickAvatarImage = true
                }
            }
        }

    }
}

private func saveImageToDisk(_ image: UIImage) -> String? {
    guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

    let filename = UUID().uuidString + ".jpg"
    let url = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(filename)

    try? data.write(to: url)
    return filename
}

extension AddChildViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == ageTextField && textField.text?.isEmpty == true {
            updateAgeText()
        }
    }
}

