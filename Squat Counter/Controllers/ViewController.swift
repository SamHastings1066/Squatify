//
//  ViewController.swift
//  Squat Counter
//
//  Created by sam hastings on 08/07/2023.
//

import UIKit
import AVFoundation
import MLImage
import MLKit
import Combine


class ViewController: UIViewController {
    
    
    
    private var isUsingFrontCamera = true
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    private var lastFrame: CMSampleBuffer?
    
    private var workout = Workout()
    var setArray: [Workout] = []
    private var squat = Squat()
    private var stopwatch = Stopwatch()
    private var cancellables: Set<AnyCancellable> = []
    private var featureEmbedder = FeatureEmbedder()
    private lazy var poseClassifier = PoseClassifier(exercises: [self.squat])
    private var repCount = 0
    private var isMonitoringPose = true
    
    let synthesizer = AVSpeechSynthesizer()
    
    
    
    //    private lazy var previewOverlayView: UIImageView = {
    //
    //      precondition(isViewLoaded)
    //      let previewOverlayView = UIImageView(frame: .zero)
    //      previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
    //      previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
    //      return previewOverlayView
    //    }()
    
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    
    private var poseDetector: PoseDetector? = nil
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var repCountLabel: UILabel!
    
    @IBOutlet weak var wristALabel: UILabel!
    @IBOutlet weak var wristXLabel: UILabel!
    @IBOutlet weak var wristYLabel: UILabel!
    @IBOutlet weak var wristZLabel: UILabel!
    
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var totalRepsLabel: UILabel!
    @IBOutlet weak var calsLabel: UILabel!
    
    //MARK: - IBActions
       
    @IBAction func restButtonPushed(_ sender: Any) {
        print(workout.workoutArray)
        // Reset repCount
        repCount = 0
        self.repCountLabel.text = "0"
        // Create new workout
        workout = Workout()
        // Append to setArray
        setArray.append(workout)
        stopwatch.pause()
        isMonitoringPose = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let restOverlayer = storyboard.instantiateViewController(withIdentifier: "RestOverlayViewController") as! RestOverlayViewController
        restOverlayer.delegate = self
        restOverlayer.appear(sender: self)
    }
    
    @IBAction func stopButtonPushed(_ sender: UIButton) {
    }
    
    
    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        //setUpPreviewOverlayView()
        setUpAnnotationOverlayView()
        setUpCaptureSessionOutput()
        setUpCaptureSessionInput()
        
        // Base pose detector with streaming, when depending on the PoseDetection SDK
        let options = PoseDetectorOptions()
        // Accurate pose detector with streaming, when depending on the PoseDetectionAccurate SDK
        // let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        self.poseDetector = PoseDetector.poseDetector(options: options)
        
        poseClassifier.onPoseCompleted = { pose, timeBetweenReps, metricValues in
            self.workout.addRep(exercise: pose, time: timeBetweenReps ?? 0.0, metricValues: metricValues)
            print(self.workout.workoutArray)
        }
        
        stopwatch.$elapsedTime
                .map { elapsedTime in
                    // Convert elapsed time to minutes and seconds
                    let minutes = Int(elapsedTime) / 60
                    let seconds = Int(elapsedTime) % 60
                    return String(format: "%02d:%02d", minutes, seconds)
                }
                .receive(on: RunLoop.main)
                .assign(to: \.text, on: stopwatchLabel)
                .store(in: &cancellables)
        stopwatch.start()
        
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
        
        setArray.append(workout)
    }
    
    

   
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // This line will disable the idle timer (prevent the screen from auto-locking)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // This line will re-enable the idle timer (allow the screen to auto-lock)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = cameraView.frame
    }
    
    
    //MARK: - On-device detection
    
    
    private func detectPose(in image: MLImage, width: CGFloat, height: CGFloat) {
        if let poseDetector = self.poseDetector {
            var poses: [Pose] = []
            var detectionError: Error?
            do {
                poses = try poseDetector.results(in: image)
            } catch let error {
                detectionError = error
            }
            weak var weakSelf = self
            DispatchQueue.main.sync {
                guard let strongSelf = weakSelf else {
                    print("Self is nil!")
                    return
                }
                // strongSelf.updatePreviewOverlayViewWithLastFrame()
                strongSelf.removeDetectionAnnotations()
                if let detectionError = detectionError {
                    print("Failed to detect poses with error: \(detectionError.localizedDescription).")
                    return
                }
                guard !poses.isEmpty else {
                    //print("Pose detector returned no results.")
                    return
                }
                
                // Pose detected. Currently, only single person detection is supported.
                poses.forEach { pose in
                    if isBodyVisible(newPose: pose) && isMonitoringPose {
                        
                        
                        featureEmbedder.updatePose(from: pose)
                        featureEmbedder.updateEmbeddingDict()
                        
                        //here
                        let isRepCompleted = repCount != workout.workoutArray.count
                        
                        if (isRepCompleted) {
                            repCount = workout.workoutArray.count;
                            SpeechService.shared.startSpeaking(text: String(repCount), synthesizer: synthesizer)
                            setLabel.text = String(setArray.count)
                            let totalReps = setArray.reduce(0) { (result, workout) -> Int in
                                return result + workout.workoutArray.count
                            }
                            totalRepsLabel.text = String(totalReps)
                        }
                        
                        //print("getting here")
                        
                        if let embeddingDict = featureEmbedder.embeddingDict {
                            poseClassifier.updatePose(embeddingDict: embeddingDict, stopwatch: stopwatch)
                            // print("getting here")
                        }
                        
                        
                        let poseOverlayView = UIUtilities.createPoseOverlayView(
                            forPose: pose,
                            inViewWithBounds: strongSelf.annotationOverlayView.bounds,
                            lineWidth: Constant.lineWidth,
                            dotRadius: Constant.smallDotRadius,
                            positionTransformationClosure: { (position) -> CGPoint in
                                return strongSelf.normalizedPoint(
                                    fromVisionPoint: position, width: width, height: height)
                            }
                        )
                        strongSelf.annotationOverlayView.addSubview(poseOverlayView)
                        
                        
                        DispatchQueue.main.async {
                            do {
                                let leftFemurAngle = try self.featureEmbedder.leftFemurAngle()
                                let leftHipAngle = try self.featureEmbedder.leftHipAngle()
                                let leftKneeAngle = try self.featureEmbedder.leftKneeAngle()
                                let squatCount = self.workout.workoutArray.count
                                self.repCountLabel.text = String(squatCount)
                                self.wristALabel.text = "Squats: \(Int(squatCount))"
                                self.wristXLabel.text = "Fem: \(Int(leftFemurAngle))"
                                self.wristYLabel.text = "Hip: \(Int(leftHipAngle))"
                                self.wristZLabel.text = "Kne: \(Int(leftKneeAngle))"
                            } catch {
                                print("Error calculating left femur angle: \(error)")
                                // Handle the error as appropriate for your app.
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    
    //MARK: - Private
    
    private func setUpCaptureSessionOutput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.beginConfiguration()
            // When performing latency tests to determine ideal capture settings,
            // run the app in 'release' mode to get accurate performance metrics
            strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.medium
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
            output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
            guard strongSelf.captureSession.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            strongSelf.captureSession.addOutput(output)
            strongSelf.captureSession.commitConfiguration()
        }
    }
    
    private func setUpCaptureSessionInput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            let cameraPosition: AVCaptureDevice.Position = strongSelf.isUsingFrontCamera ? .front : .back
            guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                strongSelf.captureSession.beginConfiguration()
                let currentInputs = strongSelf.captureSession.inputs
                for input in currentInputs {
                    strongSelf.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard strongSelf.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                strongSelf.captureSession.addInput(input)
                strongSelf.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    private func startSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.stopRunning()
        }
    }
    
    //    private func setUpPreviewOverlayView() {
    //      cameraView.addSubview(previewOverlayView)
    //      NSLayoutConstraint.activate([
    //        previewOverlayView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
    //        previewOverlayView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor),
    //        previewOverlayView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
    //        previewOverlayView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),
    //
    //      ])
    //    }
    
    private func setUpAnnotationOverlayView() {
        cameraView.addSubview(annotationOverlayView)
        NSLayoutConstraint.activate([
            annotationOverlayView.topAnchor.constraint(equalTo: cameraView.topAnchor),
            annotationOverlayView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            annotationOverlayView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),
            annotationOverlayView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),
        ])
    }
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
            )
            return discoverySession.devices.first { $0.position == position }
        }
        return nil
    }
    
    //    private func updatePreviewOverlayViewWithLastFrame() {
    //      guard let lastFrame = lastFrame,
    //        let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
    //      else {
    //        return
    //      }
    //      self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
    //      self.removeDetectionAnnotations()
    //    }
    
    private func removeDetectionAnnotations() {
        for annotationView in annotationOverlayView.subviews {
            annotationView.removeFromSuperview()
        }
    }
    
    //    private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
    //      guard let imageBuffer = imageBuffer else {
    //        return
    //      }
    //      let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
    //      let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
    //      previewOverlayView.image = image
    //    }
    
    private func normalizedPoint(
        fromVisionPoint point: VisionPoint,
        width: CGFloat,
        height: CGFloat
    ) -> CGPoint {
        let cgPoint = CGPoint(x: point.x, y: point.y)
        var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
        normalizedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
        return normalizedPoint
    }
}

//MARK: - Extensions



extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        
        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = UIUtilities.imageOrientation(
            fromDevicePosition: isUsingFrontCamera ? .front : .back
        )
        visionImage.orientation = orientation
        
        guard let inputImage = MLImage(sampleBuffer: sampleBuffer) else {
            print("Failed to create MLImage from sample buffer.")
            return
        }
        inputImage.orientation = orientation
        
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        detectPose(in: inputImage, width: imageWidth, height: imageHeight)
        
    }
}

extension ViewController: RestOverlayViewControllerDelegate {
    func didDismissOverlay() {
        self.stopwatch.continue()
        isMonitoringPose = true
        setLabel.text = String(setArray.count)
    }
    
    
}


//MARK: - Constants

//TODO: remove unused constants
private enum Constant {
    //  static let alertControllerTitle = "Vision Detectors"
    //  static let alertControllerMessage = "Select a detector"
    //  static let cancelActionTitleText = "Cancel"
    static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
    static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
    //  static let noResultsMessage = "No Results"
    //  static let localModelFile = (name: "bird", type: "tflite")
    //  static let labelConfidenceThreshold = 0.75
    static let smallDotRadius: CGFloat = 4.0
    static let lineWidth: CGFloat = 3.0
    //  static let originalScale: CGFloat = 1.0
    //  static let padding: CGFloat = 10.0
    //  static let resultsLabelHeight: CGFloat = 200.0
    //  static let resultsLabelLines = 5
    //  static let imageLabelResultFrameX = 0.4
    //  static let imageLabelResultFrameY = 0.1
    //  static let imageLabelResultFrameWidth = 0.5
    //  static let imageLabelResultFrameHeight = 0.8
    //  static let segmentationMaskAlpha: CGFloat = 0.5
}
