//
//  MilestoneVideoRecorderViewController.swift
//  TinyVitals
//
//  A custom 30-second video recorder for milestone memories.
//

import UIKit
import AVFoundation

protocol MilestoneVideoRecorderDelegate: AnyObject {
    func videoRecorderDidFinish(_ controller: MilestoneVideoRecorderViewController, videoURL: URL)
    func videoRecorderDidCancel(_ controller: MilestoneVideoRecorderViewController)
}

final class MilestoneVideoRecorderViewController: UIViewController {

    // MARK: - Delegate

    weak var delegate: MilestoneVideoRecorderDelegate?

    // MARK: - Brand colors

    private let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
    private let brandBlue = UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 1)

    // MARK: - Capture session

    private let captureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private let movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - State

    private var isRecording = false
    private var isFrontCamera = true
    private var recordingTimer: Timer?
    private var elapsedSeconds: Int = 0
    private let maxDuration: Int = 30
    private var recordedURL: URL?

    // MARK: - UI Elements

    private let closeButton = UIButton(type: .system)
    private let galleryButton = UIButton(type: .system)
    private let flipButton = UIButton(type: .system)
    private let recordButton = UIButton(type: .custom)
    private let recordRing = CAShapeLayer()
    private let progressRing = CAShapeLayer()
    private let timerLabel = UILabel()
    private let hintLabel = UILabel()

    // Preview state UI
    private let previewContainer = UIView()
    private let playButton = UIButton(type: .system)
    private let retakeButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private var previewPlayer: AVPlayer?
    private var previewPlayerLayer: AVPlayerLayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        previewPlayerLayer?.frame = previewContainer.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
        recordingTimer?.invalidate()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Camera Setup

    private func setupCamera() {
        captureSession.sessionPreset = .hd1280x720

        // Video input — front camera default
        guard let camera = camera(for: .front) else { return }
        videoDevice = camera

        do {
            let vInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(vInput) {
                captureSession.addInput(vInput)
                videoInput = vInput
            }
        } catch { return }

        // Audio input
        if let mic = AVCaptureDevice.default(for: .audio) {
            do {
                let aInput = try AVCaptureDeviceInput(device: mic)
                if captureSession.canAddInput(aInput) {
                    captureSession.addInput(aInput)
                    audioInput = aInput
                }
            } catch {}
        }

        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
            movieOutput.maxRecordedDuration = CMTime(seconds: Double(maxDuration), preferredTimescale: 600)
        }

        // Preview layer
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
        previewLayer = layer
    }

    private func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }

    // MARK: - UI Setup

    private func setupUI() {
        // --- Close button ---
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: closeConfig), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        closeButton.layer.cornerRadius = 18
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        // --- Flip camera button ---
        let flipConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        flipButton.setImage(UIImage(systemName: "camera.rotate.fill", withConfiguration: flipConfig), for: .normal)
        flipButton.tintColor = .white
        flipButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        flipButton.layer.cornerRadius = 22
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        flipButton.addTarget(self, action: #selector(flipTapped), for: .touchUpInside)
        view.addSubview(flipButton)

        // --- Gallery button ---
        let galleryConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        galleryButton.setImage(UIImage(systemName: "photo.on.rectangle", withConfiguration: galleryConfig), for: .normal)
        galleryButton.tintColor = .white
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
        view.addSubview(galleryButton)

        // --- Timer label ---
        timerLabel.text = "00:00"
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)

        // --- Hint label ---
        hintLabel.text = "Tap to start recording"
        hintLabel.font = .systemFont(ofSize: 14, weight: .medium)
        hintLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        hintLabel.textAlignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintLabel)

        // --- Record button with progress ring ---
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)

        // Outer ring (track)
        let ringPath = UIBezierPath(
            arcCenter: CGPoint(x: 40, y: 40),
            radius: 36,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        recordRing.path = ringPath.cgPath
        recordRing.fillColor = UIColor.clear.cgColor
        recordRing.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
        recordRing.lineWidth = 4
        recordButton.layer.addSublayer(recordRing)

        // Progress ring
        progressRing.path = ringPath.cgPath
        progressRing.fillColor = UIColor.clear.cgColor
        progressRing.strokeColor = brandPink.cgColor
        progressRing.lineWidth = 4
        progressRing.lineCap = .round
        progressRing.strokeEnd = 0
        recordButton.layer.addSublayer(progressRing)

        // Inner circle
        let innerCircle = UIView()
        innerCircle.backgroundColor = brandPink
        innerCircle.layer.cornerRadius = 28
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.isUserInteractionEnabled = false
        recordButton.addSubview(innerCircle)

        // --- Preview container (hidden initially) ---
        previewContainer.backgroundColor = .black
        previewContainer.isHidden = true
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewContainer)

        // Play button
        let playConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: playConfig), for: .normal)
        playButton.tintColor = .white
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        previewContainer.addSubview(playButton)

        // Retake button
        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        retakeButton.setTitleColor(.white, for: .normal)
        retakeButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        retakeButton.layer.cornerRadius = 14
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.addTarget(self, action: #selector(retakeTapped), for: .touchUpInside)
        previewContainer.addSubview(retakeButton)

        // Save button
        saveButton.setTitle("Save Memory", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = brandPink
        saveButton.layer.cornerRadius = 14
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        previewContainer.addSubview(saveButton)

        NSLayoutConstraint.activate([
            // Close
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            // Flip
            flipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            flipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flipButton.widthAnchor.constraint(equalToConstant: 44),
            flipButton.heightAnchor.constraint(equalToConstant: 44),

            // Gallery
            galleryButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            galleryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            galleryButton.widthAnchor.constraint(equalToConstant: 44),
            galleryButton.heightAnchor.constraint(equalToConstant: 44),

            // Timer
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Record button
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),

            // Inner circle
            innerCircle.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 56),
            innerCircle.heightAnchor.constraint(equalToConstant: 56),

            // Hint
            hintLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -16),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Preview container
            previewContainer.topAnchor.constraint(equalTo: view.topAnchor),
            previewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Play button center
            playButton.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor),

            // Retake
            retakeButton.bottomAnchor.constraint(equalTo: previewContainer.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            retakeButton.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 40),
            retakeButton.heightAnchor.constraint(equalToConstant: 50),
            retakeButton.trailingAnchor.constraint(equalTo: previewContainer.centerXAnchor, constant: -10),

            // Save
            saveButton.bottomAnchor.constraint(equalTo: previewContainer.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            saveButton.leadingAnchor.constraint(equalTo: previewContainer.centerXAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        Haptics.impact(.light)
        if isRecording {
            movieOutput.stopRecording()
        }
        delegate?.videoRecorderDidCancel(self)
        dismiss(animated: true)
    }

    @objc private func flipTapped() {
        Haptics.impact(.light)
        isFrontCamera.toggle()
        let newPosition: AVCaptureDevice.Position = isFrontCamera ? .front : .back

        guard let newCamera = camera(for: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newCamera) else { return }

        captureSession.beginConfiguration()
        if let current = videoInput {
            captureSession.removeInput(current)
        }
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            videoInput = newInput
            videoDevice = newCamera
        }
        captureSession.commitConfiguration()

        // Mirror flip animation
        UIView.transition(with: view, duration: 0.3, options: .transitionFlipFromLeft) {}
    }

    @objc private func galleryTapped() {
        Haptics.impact(.light)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.videoMaximumDuration = 30.0
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func recordTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    @objc private func playTapped() {
        guard let url = recordedURL else { return }
        previewPlayer?.seek(to: .zero)
        previewPlayer?.play()
        playButton.isHidden = true
    }

    @objc private func retakeTapped() {
        Haptics.impact(.light)
        // Clean up preview
        previewPlayer?.pause()
        previewPlayerLayer?.removeFromSuperlayer()
        previewPlayer = nil
        previewPlayerLayer = nil

        // Reset state
        previewContainer.isHidden = true
        elapsedSeconds = 0
        timerLabel.text = "00:00"
        progressRing.strokeEnd = 0
        hintLabel.text = "Tap to start recording"
        hintLabel.isHidden = false

        // Restart camera
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    @objc private func saveTapped() {
        Haptics.impact(.medium)
        guard let url = recordedURL else { return }
        previewPlayer?.pause()
        delegate?.videoRecorderDidFinish(self, videoURL: url)
        dismiss(animated: true)
    }

    // MARK: - Recording

    private func startRecording() {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
        elapsedSeconds = 0
        hintLabel.text = "Recording…"

        // Animate record button to square
        UIView.animate(withDuration: 0.3) {
            if let innerCircle = self.recordButton.subviews.first {
                innerCircle.layer.cornerRadius = 8
                innerCircle.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        }

        Haptics.impact(.medium)

        // Start timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 1

            let mins = self.elapsedSeconds / 60
            let secs = self.elapsedSeconds % 60
            self.timerLabel.text = String(format: "%02d:%02d", mins, secs)

            // Pulse timer color when near limit
            if self.elapsedSeconds >= 25 {
                self.timerLabel.textColor = self.brandPink
            }

            // Update progress ring
            let progress = CGFloat(self.elapsedSeconds) / CGFloat(self.maxDuration)
            self.progressRing.strokeEnd = progress

            // Auto stop at max
            if self.elapsedSeconds >= self.maxDuration {
                self.stopRecording()
            }
        }
    }

    private func stopRecording() {
        movieOutput.stopRecording()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false

        Haptics.notification(.success)

        // Animate record button back to circle
        UIView.animate(withDuration: 0.3) {
            if let innerCircle = self.recordButton.subviews.first {
                innerCircle.layer.cornerRadius = 28
                innerCircle.transform = .identity
            }
        }

        timerLabel.textColor = .white
        hintLabel.isHidden = true
    }

    // MARK: - Show Preview

    private func showPreview(url: URL) {
        recordedURL = url

        captureSession.stopRunning()

        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = previewContainer.bounds
        previewContainer.layer.insertSublayer(playerLayer, at: 0)

        previewPlayer = player
        previewPlayerLayer = playerLayer
        previewContainer.isHidden = false
        playButton.isHidden = false

        // Loop playback
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.playButton.isHidden = false
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension MilestoneVideoRecorderViewController: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                let alert = UIAlertController(
                    title: "Recording Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
                return
            }
            self?.showPreview(url: outputFileURL)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MilestoneVideoRecorderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        guard let url = info[.mediaURL] as? URL else { return }
        
        // Copy to temp directory to ensure we own the file and it isn't deleted by the picker
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            try FileManager.default.copyItem(at: url, to: tempURL)
            showPreview(url: tempURL)
        } catch {
            let alert = UIAlertController(title: "Error", message: "Could not load the selected video.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
