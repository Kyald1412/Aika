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

enum CurrentMode: Int{
    case groundZero = -1
    case initial = 0
    case taskOption = 1
    case taskBegin = 2
    case taskProcess = 3
    case taskDone = 4
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var lblAikaMain: UILabel!
    @IBOutlet weak var lblSpeechRecognizer: UILabel!
    @IBOutlet weak var waveForm: WaveFormView!
    @IBOutlet weak var icAika: UIImageView!
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var viewTaskOption: UIView!
    @IBOutlet weak var viewSpeechAnalyzer: UIView!
    
    @IBOutlet weak var btnOptionTrain: DesignableButton!
    @IBOutlet weak var btnOptionListen: DesignableButton!
    
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
    
    var continueSpeaking = false
    var silenceTimer: Float = 0.0
    
    var currentMode: CurrentMode = .groundZero
    
    @IBAction func btnOptionTrain(_ sender: Any) {
        switch (currentMode) {
        case .groundZero:
            print("groundZero")
            self.currentMode = .initial
        case .initial :
            print("initial")
        case .taskOption:
            self.currentMode = .taskBegin
        case .taskBegin:
            self.currentMode = .taskProcess
        case .taskProcess:
            print("initial")
        case .taskDone:
            print("Call Result View Controller here")
        }
        setupTaskMode()
    }
    
    @IBAction func btnOptionListen(_ sender: Any) {
        switch (currentMode) {
        case .groundZero:
            print("groundZero")
        case .initial :
            print("initial")
        case .taskOption:
            self.currentMode = .taskBegin
        case .taskBegin:
            self.currentMode = .taskOption
        case .taskProcess:
            print("initial")
        case .taskDone:
            self.continueSpeaking = true
            self.currentMode = .taskProcess
            print("Call Result View Controller here")
        }
        setupTaskMode()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFaceRecognition()
        setupTaskMode()
    }
    
    func setupTaskMode(){
        
        self.lblSpeechRecognizer.text = ""
        
        switch (currentMode) {
        case .groundZero:
            self.lblAikaMain.text = "Hi, how are you today?"
            self.btnOptionListen.borderWidth = 0
            self.btnOptionTrain.setTitle("Start Speaking", for: .normal)
            self.btnOptionListen.setTitle("", for: .normal)
        case .initial :
            self.lblAikaMain.text = "Hi, how are you today?"
            self.initSpeechRecognition()
//            self.requestSpeechAuthorization()
        case .taskOption:
            self.lblAikaMain.text = "What can I do for you?"
            self.btnOptionTrain.setTitle("Public speaking training", for: .normal)
            self.btnOptionListen.setTitle("Listen to your story", for: .normal)
            self.btnOptionListen.borderWidth = 0.5
        case .taskBegin:
            self.lblAikaMain.text = "Shall we start?"
            self.btnOptionTrain.setTitle("Ready!", for: .normal)
            self.btnOptionListen.setTitle("No, I changed my mind", for: .normal)
            self.btnOptionListen.borderWidth = 0
        case .taskProcess:
            self.lblAikaMain.text = "I'm listening, go on!"
            self.requestSpeechAuthorization()
        case .taskDone:
            self.lblAikaMain.text = "Are you finished?"
            self.btnOptionTrain.setTitle("Yes!", for: .normal)
            self.btnOptionListen.setTitle("I'm not done yet", for: .normal)
            self.btnOptionListen.borderWidth = 0
        }
        
        self.setupView()
    }
    
    func setupView(){
        switch (currentMode) {
        case .groundZero:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
        case .initial :
            self.viewTaskOption.isHidden = true
            self.viewSpeechAnalyzer.isHidden = false
        case .taskOption:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
        case .taskBegin:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
        case .taskProcess:
            self.viewTaskOption.isHidden = true
            self.viewSpeechAnalyzer.isHidden = false
        case .taskDone:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
        }
    }
    
    //MARK: - Alert
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
