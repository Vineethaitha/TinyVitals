import UIKit
import Vision
import CoreImage

class DocumentCropViewController: UIViewController {

    // MARK: - Properties

    private let sourceImage: UIImage
    var onCropped: ((UIImage) -> Void)?

    private let imageView = UIImageView()
    private let overlayView = UIView()
    private let cropShapeLayer = CAShapeLayer()
    private let dimLayer = CAShapeLayer()
    private var cornerHandles: [UIView] = []

    // 4 corners in IMAGE coordinates (normalised to image size)
    private var corners: [CGPoint] = []

    private let handleSize: CGFloat = 28
    private var activeHandle: Int? = nil

    // MARK: - Init

    init(image: UIImage) {
        // Normalize orientation upfront so CIImage coordinates match UIImage coordinates
        self.sourceImage = DocumentCropViewController.normalizeOrientation(image)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavBar()
        setupImageView()
        setupOverlay()
        setupCornerHandles()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if corners.isEmpty {
            detectDocumentEdges()
        } else {
            updateOverlay()
        }
    }

    // MARK: - Nav Bar

    private func setupNavBar() {
        let nav = UINavigationBar()
        nav.isTranslucent = true
        nav.barStyle = .black
        nav.tintColor = .white
        nav.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nav)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let item = UINavigationItem(title: "Adjust Edges")
        item.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        item.rightBarButtonItem = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(doneTapped))
        item.rightBarButtonItem?.tintColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        nav.setItems([item], animated: false)
    }

    // MARK: - Image View

    private func setupImageView() {
        imageView.image = sourceImage
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    // MARK: - Overlay

    private func setupOverlay() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])

        // Dim layer (darkens area outside crop)
        dimLayer.fillRule = .evenOdd
        dimLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        overlayView.layer.addSublayer(dimLayer)

        // Crop border
        cropShapeLayer.strokeColor = UIColor.white.cgColor
        cropShapeLayer.fillColor = UIColor.clear.cgColor
        cropShapeLayer.lineWidth = 2
        overlayView.layer.addSublayer(cropShapeLayer)
    }

    // MARK: - Corner Handles

    private func setupCornerHandles() {
        let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        for _ in 0..<4 {
            let handle = UIView(frame: CGRect(x: 0, y: 0, width: handleSize, height: handleSize))
            handle.backgroundColor = brandPink
            handle.layer.cornerRadius = handleSize / 2
            handle.layer.borderWidth = 3
            handle.layer.borderColor = UIColor.white.cgColor
            handle.layer.shadowColor = UIColor.black.cgColor
            handle.layer.shadowOpacity = 0.3
            handle.layer.shadowRadius = 4
            handle.layer.shadowOffset = CGSize(width: 0, height: 2)
            handle.isHidden = true
            view.addSubview(handle)
            cornerHandles.append(handle)
        }

        // Pan gesture on the main view
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(pan)
    }

    // MARK: - Edge Detection (Vision)

    private func detectDocumentEdges() {
        guard let cgImage = sourceImage.cgImage else {
            setDefaultCorners()
            return
        }

        let request = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }

            if let result = (request.results as? [VNRectangleObservation])?.first {
                // Vision returns normalised coordinates (0..1), origin bottom-left
                let tl = result.topLeft
                let tr = result.topRight
                let br = result.bottomRight
                let bl = result.bottomLeft

                DispatchQueue.main.async {
                    // Convert from Vision coords (bottom-left origin) to image coords (top-left origin)
                    let imgW = self.sourceImage.size.width
                    let imgH = self.sourceImage.size.height

                    self.corners = [
                        CGPoint(x: tl.x * imgW, y: (1 - tl.y) * imgH),  // top-left
                        CGPoint(x: tr.x * imgW, y: (1 - tr.y) * imgH),  // top-right
                        CGPoint(x: br.x * imgW, y: (1 - br.y) * imgH),  // bottom-right
                        CGPoint(x: bl.x * imgW, y: (1 - bl.y) * imgH),  // bottom-left
                    ]
                    self.updateOverlay()
                }
            } else {
                DispatchQueue.main.async {
                    self.setDefaultCorners()
                }
            }
        }

        request.maximumObservations = 1
        request.minimumConfidence = 0.5
        request.minimumAspectRatio = 0.3

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    private func setDefaultCorners() {
        let w = sourceImage.size.width
        let h = sourceImage.size.height
        let inset: CGFloat = min(w, h) * 0.08

        corners = [
            CGPoint(x: inset, y: inset),              // top-left
            CGPoint(x: w - inset, y: inset),           // top-right
            CGPoint(x: w - inset, y: h - inset),       // bottom-right
            CGPoint(x: inset, y: h - inset),           // bottom-left
        ]
        updateOverlay()
    }

    // MARK: - Coordinate Conversion

    /// Returns the rect in which the image is actually displayed inside imageView
    private func displayedImageRect() -> CGRect {
        let viewSize = imageView.bounds.size
        let imgSize = sourceImage.size
        guard viewSize.width > 0, viewSize.height > 0 else { return .zero }

        let scale = min(viewSize.width / imgSize.width, viewSize.height / imgSize.height)
        let w = imgSize.width * scale
        let h = imgSize.height * scale
        let x = (viewSize.width - w) / 2
        let y = (viewSize.height - h) / 2
        return CGRect(x: x, y: y, width: w, height: h)
    }

    /// Image point → view point (relative to imageView)
    private func imageToView(_ pt: CGPoint) -> CGPoint {
        let rect = displayedImageRect()
        let scaleX = rect.width / sourceImage.size.width
        let scaleY = rect.height / sourceImage.size.height
        return CGPoint(
            x: rect.origin.x + pt.x * scaleX,
            y: rect.origin.y + pt.y * scaleY
        )
    }

    /// View point (relative to imageView) → image point
    private func viewToImage(_ pt: CGPoint) -> CGPoint {
        let rect = displayedImageRect()
        let scaleX = sourceImage.size.width / rect.width
        let scaleY = sourceImage.size.height / rect.height
        return CGPoint(
            x: (pt.x - rect.origin.x) * scaleX,
            y: (pt.y - rect.origin.y) * scaleY
        )
    }

    // MARK: - Update UI

    private func updateOverlay() {
        guard corners.count == 4 else { return }
        view.layoutIfNeeded()

        let viewCorners = corners.map { imageToView($0) }

        // Update crop border path
        let path = UIBezierPath()
        path.move(to: viewCorners[0])
        for i in 1..<4 { path.addLine(to: viewCorners[i]) }
        path.close()
        cropShapeLayer.path = path.cgPath

        // Dim layer
        let fullPath = UIBezierPath(rect: overlayView.bounds)
        fullPath.append(path)
        dimLayer.path = fullPath.cgPath
        dimLayer.frame = overlayView.bounds

        // Edge lines (grid)
        cropShapeLayer.frame = overlayView.bounds

        // Corner handles (positioned in view coordinates, relative to self.view)
        for (i, corner) in viewCorners.enumerated() {
            let handleCenter = imageView.convert(corner, to: view)
            cornerHandles[i].center = handleCenter
            cornerHandles[i].isHidden = false
        }
    }

    // MARK: - Pan Gesture

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)

        switch gesture.state {
        case .began:
            // Find closest handle
            var minDist: CGFloat = .greatestFiniteMagnitude
            for (i, handle) in cornerHandles.enumerated() {
                let dist = hypot(handle.center.x - location.x, handle.center.y - location.y)
                if dist < minDist && dist < 60 {
                    minDist = dist
                    activeHandle = i
                }
            }

        case .changed:
            guard let idx = activeHandle else { return }
            // Convert touch location to imageView coordinate space
            let pointInImageView = view.convert(location, to: imageView)
            // Clamp within displayed image rect
            let imgRect = displayedImageRect()
            let clamped = CGPoint(
                x: max(imgRect.minX, min(imgRect.maxX, pointInImageView.x)),
                y: max(imgRect.minY, min(imgRect.maxY, pointInImageView.y))
            )
            corners[idx] = viewToImage(clamped)
            updateOverlay()

            // Haptic on significant moves
            let translation = gesture.translation(in: view)
            if abs(translation.x) > 20 || abs(translation.y) > 20 {
                Haptics.selection()
                gesture.setTranslation(.zero, in: view)
            }

        case .ended, .cancelled:
            activeHandle = nil

        default: break
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        guard corners.count == 4 else {
            dismiss(animated: true)
            return
        }

        Haptics.impact(.medium)

        let cropped = perspectiveCorrectedImage()
        onCropped?(cropped ?? sourceImage)
        dismiss(animated: true)
    }

    // MARK: - Perspective Correction

    private func perspectiveCorrectedImage() -> UIImage? {
        guard let cgImg = sourceImage.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImg)

        let imgH = CGFloat(cgImg.height)

        // CIImage coordinate space is bottom-left origin
        let tl = CIVector(x: corners[0].x, y: imgH - corners[0].y)
        let tr = CIVector(x: corners[1].x, y: imgH - corners[1].y)
        let br = CIVector(x: corners[2].x, y: imgH - corners[2].y)
        let bl = CIVector(x: corners[3].x, y: imgH - corners[3].y)

        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(tl, forKey: "inputTopLeft")
        filter.setValue(tr, forKey: "inputTopRight")
        filter.setValue(br, forKey: "inputBottomRight")
        filter.setValue(bl, forKey: "inputBottomLeft")

        guard let output = filter.outputImage else { return nil }

        let context = CIContext()
        guard let resultCG = context.createCGImage(output, from: output.extent) else { return nil }

        return UIImage(cgImage: resultCG)
    }

    // MARK: - Orientation Fix

    /// Renders the image into a new bitmap with .up orientation
    /// so that CIImage pixel coordinates match UIImage coordinates.
    private static func normalizeOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }

        // Use scale = 1 so UIImage.size equals CGImage pixel dimensions
        let size = CGSize(width: image.size.width * image.scale,
                          height: image.size.height * image.scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
