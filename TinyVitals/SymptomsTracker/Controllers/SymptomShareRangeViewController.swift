//
//  SymptomShareRangeViewController.swift
//  TinyVitals
//

import UIKit

final class SymptomShareRangeViewController: UIViewController {

    var activeChild: ChildProfile!
    private var allSymptoms: [SymptomEntry] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        let desc = UIFont.systemFont(ofSize: 22, weight: .bold).fontDescriptor.withDesign(.rounded)!
        label.font = UIFont(descriptor: desc, size: 24)
        label.text = "Export Symptoms"
        label.textAlignment = .center
        return label
    }()
    
    private let fromLabel: UILabel = {
        let label = UILabel()
        label.text = "From Date"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let fromDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        picker.date = thirtyDaysAgo
        picker.maximumDate = Date()
        return picker
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = "To Date"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let toDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.date = Date()
        picker.maximumDate = Date()
        return picker
    }()
    
    private let shareButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Generate PDF"
        config.baseBackgroundColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1) // brandPink
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        let btn = UIButton(configuration: config)
        return btn
    }()
    
    private let loaderContainer = UIView()
    private let loader = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupLoader()
    }
    
    private func setupUI() {
        let fromStack = UIStackView(arrangedSubviews: [fromLabel, fromDatePicker])
        fromStack.axis = .horizontal
        fromStack.distribution = .equalSpacing
        fromStack.alignment = .center
        
        let toStack = UIStackView(arrangedSubviews: [toLabel, toDatePicker])
        toStack.axis = .horizontal
        toStack.distribution = .equalSpacing
        toStack.alignment = .center
        
        fromDatePicker.addTarget(self, action: #selector(fromDateChanged), for: .valueChanged)
        
        let containerStack = UIStackView(arrangedSubviews: [titleLabel, fromStack, toStack, shareButton])
        containerStack.axis = .vertical
        containerStack.spacing = 32
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }
    
    @objc private func fromDateChanged() {
        toDatePicker.minimumDate = fromDatePicker.date
    }
    
    private func setupLoader() {
        loaderContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        loaderContainer.translatesAutoresizingMaskIntoConstraints = false
        loaderContainer.isHidden = true
        
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    @objc private func shareTapped() {
        let fromDate = Calendar.current.startOfDay(for: fromDatePicker.date)
        let toDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: toDatePicker.date) ?? toDatePicker.date
        
        Task {
            await MainActor.run {
                loaderContainer.isHidden = false
                loader.startAnimating()
                shareButton.isEnabled = false
            }
            
            do {
                // 1. Fetch complete symptoms directly from DB so we have a fresh copy
                let dtos = try await SymptomService.shared.fetchSymptoms(childId: activeChild.id)
                let allEntries = dtos.map { SymptomEntry(dto: $0) }
                
                // 2. Filter by date
                let filtered = allEntries.filter { item in
                    item.date >= fromDate && item.date <= toDate
                }
                
                if filtered.isEmpty {
                    await MainActor.run {
                        self.loader.stopAnimating()
                        self.loaderContainer.isHidden = true
                        self.shareButton.isEnabled = true
                        let alert = UIAlertController(title: "No Symptoms", message: "No symptoms found in the selected date range.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                // 3. Download images for any entries with images
                var enrichedEntries = [SymptomEntry]()
                for var entry in filtered {
                    if let imagePath = entry.imagePath {
                        if let signedURL = try? await SymptomService.shared.signedImageURL(path: imagePath) {
                            if let (data, _) = try? await URLSession.shared.data(from: signedURL), let image = UIImage(data: data) {
                                entry.image = image
                            }
                        }
                    }
                    enrichedEntries.append(entry)
                }
                
                // 4. Generate PDF
                guard let pdfURL = SymptomsPDFExporter.generatePDF(
                    from: enrichedEntries,
                    calendar: Calendar.current,
                    childName: self.activeChild.name,
                    fromDate: fromDate,
                    toDate: toDate
                ) else {
                    throw NSError(domain: "PDFGeneration", code: 1, userInfo: nil)
                }
                
                // 5. Present
                await MainActor.run {
                    self.loader.stopAnimating()
                    self.loaderContainer.isHidden = true
                    self.shareButton.isEnabled = true
                    
                    let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
                    // For iPad
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = self.shareButton
                        popover.sourceRect = self.shareButton.bounds
                    }
                    self.present(activityVC, animated: true)
                }
                
            } catch {
                await MainActor.run {
                    self.loader.stopAnimating()
                    self.loaderContainer.isHidden = true
                    self.shareButton.isEnabled = true
                    let alert = UIAlertController(title: "Error", message: "Failed to generate PDF.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
