//
//  SquatVC.swift
//  Squat Counter
//
//  Created by sam hastings on 08/07/2023.
//

import UIKit
import AVFoundation
import MLImage
import MLKit
import Combine
import RealmSwift


class SquatVC: UIViewController {
    
    
    
    private var isUsingFrontCamera = true
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    private var lastFrame: CMSampleBuffer?
    
    private var workout = Workout()
    var startTime: Date?
    var setArray: [Workout] = []
    private var squat = Squat()
    var stopwatch = Stopwatch()
    private var cancellables: Set<AnyCancellable> = []
    private var featureEmbedder = FeatureEmbedder()
    private lazy var poseClassifier = PoseClassifier(exercises: [self.squat])
    private var repCount = 0
    private var isMonitoringPose = true
    let calendar = Calendar.current
    
    let synthesizer = AVSpeechSynthesizer()
    
    // Workout parameters
    var restInterval = 60
    var repTarget = 0
    var setTarget = 0
    var weightOnBar = 0
    
    
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
        resetWorkout()
    }
    
    @IBAction func stopButtonPushed(_ sender: UIButton) {
        self.stopWorkout()
    }
    
    
    //MARK: - Navigation functions
    
    func resetWorkout() {
        self.hidesBottomBarWhenPushed = true
        repCount = 0
        self.repCountLabel.text = "0"
        stopwatch.pause()
        isMonitoringPose = false
        performSegue(withIdentifier: "SquatToRestOverlay", sender: self)
    }
    
    func stopWorkout() {
        isMonitoringPose = false
        stopwatch.stop()
        let finishedWorkoutTV = FinishWorkoutTV()
        let realm = try! Realm()

        // Next, we create the RealmWorkout object
        let realmWorkout = RealmWorkout()
        let today = Date()
        realmWorkout.workoutDate = today // set the workoutDate to current date
        realmWorkout.workoutDay = calendar.ordinality(of: .day, in: .era, for: today)
        realmWorkout.startTime = startTime
        realmWorkout.endTime = today

        // Now, we loop over all workouts in setArray to create the RealmSet and RealmRep objects
        for (setNum, workout) in setArray.enumerated() {
            let realmSet = RealmSet()
            realmSet.setNum = setNum + 1 // setNum in 1-indexed form
            realmSet.exerciseName = workout.workoutArray.first?.exercise // replace this if multiple exercises can exist in a set
            realmSet.numReps = workout.workoutArray.count
            realmSet.weightLbs = workout.weightOnBar

//                // For each rep in workout, create a RealmRep and append it to the current RealmSet
            for (repNum, rep) in workout.workoutArray.enumerated() {
                let realmRep = RealmRep()
                realmRep.repNum = repNum + 1 // repNum in 1-indexed form
                realmRep.repTime = rep.time
                realmRep.minSquatDepth = rep.metricValues["minSquatDepth"] ?? 0.0

                // Append the RealmRep to the current RealmSet
                realmSet.reps.append(realmRep)
            }

            // After all reps in a workout have been processed, append the RealmSet to the current RealmWorkout
            realmWorkout.sets.append(realmSet)
        }

        // Finally, write all data into Realm in a write transaction
        do {
            try realm.write {
                realm.add(realmWorkout)
            }
        } catch {
            print("Failed to write data into Realm: \(error)")
        }
        finishedWorkoutTV.realmWorkout = realmWorkout
        
        // Turn Idle timer back on
        UIApplication.shared.isIdleTimerDisabled = false
        
        self.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(finishedWorkoutTV, animated: true)
        //self.performSegue(withIdentifier: "SquatToSummary", sender: self)
        self.hidesBottomBarWhenPushed = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SquatToRestOverlay" {
            let destinationVC = segue.destination as! RestVC
            destinationVC.delegate = self
            destinationVC.initialRestInterval = restInterval
            destinationVC.repTarget = repTarget
            destinationVC.setTarget = setTarget
            destinationVC.weightOnBar = weightOnBar
            destinationVC.setArray = setArray
            destinationVC.setsCompleted = setArray.count
            destinationVC.stopwatch = stopwatch
            destinationVC.calendar = calendar
            destinationVC.startTime = startTime
            //destinationVC.appear(sender: self)
        }
    }
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        checkCameraAuthorization { [weak self] granted in
            guard let strongSelf = self else { return }
            
            if granted {
                DispatchQueue.main.async {
                    self?.setUpCaptureSessionOutput()
                    self?.setUpCaptureSessionInput()
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.promptForCameraAccess()
                }
            }
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        //setUpPreviewOverlayView()
        setUpAnnotationOverlayView()
//        setUpCaptureSessionOutput()
//        setUpCaptureSessionInput()
        
        // Base pose detector with streaming, when depending on the PoseDetection SDK
        let options = PoseDetectorOptions()
        // Accurate pose detector with streaming, when depending on the PoseDetectionAccurate SDK
        // let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        self.poseDetector = PoseDetector.poseDetector(options: options)
        
        workout.weightOnBar = weightOnBar
        poseClassifier.onPoseCompleted = { pose, timeBetweenReps, metricValues in
            self.workout.addRep(exercise: pose, time: timeBetweenReps ?? 0.0, metricValues: metricValues)
            //print(self.workout.workoutArray)
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
        
        startTime = Date()
        
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
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

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
                            calsLabel.text = String(Int(0.4 * Double(totalReps)))
                            totalRepsLabel.text = String(totalReps)
                            DispatchQueue.main.async {
                                let squatCount = self.workout.workoutArray.count
                                let setCount = self.setArray.count
                                self.repCountLabel.text = String(squatCount)
                                if self.repTarget != 0 {
                                    if squatCount == self.repTarget {
                                        if self.setTarget != 0 && self.setTarget == setCount {
                                            self.stopWorkout()
                                        } else {
                                            self.resetWorkout()
                                        }
                                        
                                    }
                                }
    //                            do {
    //                                let leftFemurAngle = try self.featureEmbedder.leftFemurAngle()
    //                                let leftHipAngle = try self.featureEmbedder.leftHipAngle()
    //                                let leftKneeAngle = try self.featureEmbedder.leftKneeAngle()
    //                                self.wristALabel.text = "Squats: \(Int(squatCount))"
    //                                self.wristXLabel.text = "Fem: \(Int(leftFemurAngle))"
    //                                self.wristYLabel.text = "Hip: \(Int(leftHipAngle))"
    //                                self.wristZLabel.text = "Kne: \(Int(leftKneeAngle))"
    //                            } catch {
    //                                print("Error calculating left femur angle: \(error)")
    //                                // Handle the error as appropriate for your app.
    //                            }
                            }
                            
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
                    }
                    
                }
            }
        }
    }
    
    func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            completion(true)
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
            
        case .denied: // The user has previously denied access.
            completion(false)
            
        case .restricted: // The user can't grant access due to restrictions.
            completion(false)
        default:
            completion(false)
        }
    }
    
    func promptForCameraAccess() {
        let alert = UIAlertController(title: "Camera Access Needed", message: "Please grant access to the camera to use this feature.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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
    

    
    private func removeDetectionAnnotations() {
        for annotationView in annotationOverlayView.subviews {
            annotationView.removeFromSuperview()
        }
    }
    
    
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



extension SquatVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
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

// NAVIGATION
extension SquatVC: RestVCDelegate {
    func didDismissOverlay(repTarget: Int, setTarget: Int, weightOnBar: Int) {
        workout = Workout()
        setArray.append(workout)
        self.repTarget = repTarget
        self.setTarget = setTarget
        self.weightOnBar = weightOnBar
        self.workout.weightOnBar = weightOnBar
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
