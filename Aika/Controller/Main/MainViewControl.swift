//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import Speech
import SoundAnalysis
import ARKit

class MainViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var lblAikaMain: UILabel!
    @IBOutlet weak var lblSpeechRecognizer: UILabel!
    @IBOutlet weak var waveForm: WaveFormView!
    @IBOutlet weak var icAika: UIImageView!
    @IBOutlet weak var lblAnalysis: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblSoundAnalysis: UILabel!
    
    @IBOutlet weak var imgProgress: UIImageView!
    @IBOutlet weak var circularProgressBar: UIView!
    @IBOutlet weak var lblProgress: UILabel!
    
    @IBOutlet weak var viewTaskOption: UIView!
    @IBOutlet weak var viewSpeechAnalyzer: UIView!
    @IBOutlet weak var viewTaskAnalyze: UIView!

    @IBOutlet weak var btnOptionTrain: DesignableView!
    @IBOutlet weak var btnOptionListen: DesignableView!
    
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet var sceneView: ARSCNView!

    // MARK: Audio,Speech,SoundAnalysis
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
//    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    var soundClassifier: EmotionModel!
    
    // MARK: Variables
    var isRecording = false
    var analysis = ""
    var speechText = ""
    var continueSpeaking = false
    var silenceTimer: Float = 0.0
    var lowPassResults: Float = 0.0

    // MARK: Face Recognition
    var expression = Expression()
    var isSmiling = false
    var isLookOut = false
    var isExcited = false

    // MARK: Timers
    weak var expressionTimer: Timer?
    weak var waveFormTimer: Timer?
    weak var speechCountdownTimer: Timer?
    var expressionStartTime: Double = 0
    
    // MARK: Segues
    let instructionSegue = "showInstructionSegue"
    let resultSegue = "showResultSegue"
    
    // MARK: App Lifecycle
    var currentMode: CurrentMode = .groundZero {
        didSet {
            setupTaskMode()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try soundClassifier = .init(configuration: MLModelConfiguration.init())
        } catch {
            print("Error")
        }
        initFaceRecognition()
        setupTaskMode()
    }

    func progressAnimation() {
        let storkeLayer = CAShapeLayer()
        storkeLayer.fillColor = UIColor.clear.cgColor
        storkeLayer.strokeColor = UIColor.white.cgColor
        storkeLayer.lineWidth = 2
        
        storkeLayer.path = CGPath.init(roundedRect: self.circularProgressBar.bounds, cornerWidth: 50, cornerHeight: 50, transform: nil)
        
        self.circularProgressBar.layer.addSublayer(storkeLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0.0)
        animation.toValue = CGFloat(1.0)
        animation.duration = 5
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        storkeLayer.add(animation, forKey: "circleAnimation")
    }
    
    func progressCompleteAnimation(){
        UIView.transition(from: self.circularProgressBar, to: self.imgProgress, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews]) { (bol) in
            self.imgProgress.isHidden = false
        }
    }
    
    func taskAnalyzeComplete(){
        
        if !Constants.useOnDeviceRecognition {
            self.speechCountdownTimer?.invalidate()
        }
        
        self.lblProgress.countAnimation(upto: 100)

        self.lblTimer.text = ""
        
        self.expression.speechText = self.speechText
        
        self.progressAnimation()
        
        var runCount = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            runCount += 1

            if runCount == 5 {
                self.progressCompleteAnimation()
            }
            if runCount == 6 {
                self.openResultView()
                self.currentMode = .showResult
                timer.invalidate()
            }
        }
    }

    func groundZeroCheck(){
        self.cancelRecording()
        self.continueSpeaking = false
        self.expression = Expression()
        
        if self.expressionTimer != nil {
            self.expressionTimer?.invalidate()
        }
        if self.waveFormTimer != nil {
            self.waveFormTimer?.invalidate()
        }
        if self.speechCountdownTimer != nil {
            self.speechCountdownTimer?.invalidate()
        }
    }
    
    
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
