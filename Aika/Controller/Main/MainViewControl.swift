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
    
    @IBOutlet weak var lblAikaMain: UILabel!
    @IBOutlet weak var lblSpeechRecognizer: UILabel!
    @IBOutlet weak var waveForm: WaveFormView!
    @IBOutlet weak var icAika: UIImageView!
    @IBOutlet weak var lblAnalysis: UILabel!
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var imgProgress: UIImageView!
    @IBOutlet weak var circularProgressBar: UIView!
    @IBOutlet weak var lblProgress: UILabel!
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var viewTaskOption: UIView!
    @IBOutlet weak var viewSpeechAnalyzer: UIView!
    @IBOutlet weak var viewTaskAnalyze: UIView!

    @IBOutlet weak var btnOptionTrain: DesignableButton!
    @IBOutlet weak var btnOptionListen: DesignableButton!
    
    @IBOutlet weak var lblTimer: UILabel!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    var analysis = ""
    var levelTimer = Timer()
    var lowPassResults: Float = 0.0
    
    var countdownTimer: Timer!
    var totalTime = 60
    
    var continueSpeaking = false
    var silenceTimer: Float = 0.0
    
    var currentMode: CurrentMode = .groundZero {
        didSet {
            setupTaskMode()
        }
    }
    
    let instructionSegue = "showInstructionSegue"
    let resultSegue = "showResultSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFaceRecognition()
        setupTaskMode()
    }
    
    func successAnimation() {
        let storkeLayer = CAShapeLayer()
        storkeLayer.fillColor = UIColor.clear.cgColor
        storkeLayer.strokeColor = UIColor.white.cgColor
        storkeLayer.lineWidth = 2
        
        // Create a rounded rect path using button's bounds.
        storkeLayer.path = CGPath.init(roundedRect: self.circularProgressBar.bounds, cornerWidth: 50, cornerHeight: 50, transform: nil) // same path like the empty one ...
        
        // Add layer to the button
        self.circularProgressBar.layer.addSublayer(storkeLayer)
        
        // Create animation layer and add it to the stroke layer.
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0.0)
        animation.toValue = CGFloat(1.0)
        animation.duration = 5
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        storkeLayer.add(animation, forKey: "circleAnimation")
    }
    
    func successCapturing(){
        UIView.transition(from: self.circularProgressBar, to: self.imgProgress, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews]) { (bol) in
            self.imgProgress.isHidden = false
        }
    }
    
    func taskAnalyzeComplete(){
        self.lblProgress.countAnimation(upto: 100)
        self.countdownTimer.invalidate()
        self.lblTimer.text = ""
        
        var runCount = 0
        self.successAnimation()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            print("Timer fired!")
            runCount += 1

            if runCount == 5 {
                self.successCapturing()
            }
            if runCount == 6 {
                self.openResultView()
                self.currentMode = .showResult
                timer.invalidate()
            }
        }
    }
    
    func openResultView(){
        self.performSegue(withIdentifier: resultSegue, sender: nil)
    }
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        self.lblTimer.text = "\(totalTime.timeFormatted())"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            self.currentMode = .taskAnalyze
            self.setupTaskMode()
            countdownTimer.invalidate()
        }
    }
    
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
