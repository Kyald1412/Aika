//
//  CalibrationViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 05/05/21.
//

import UIKit
import Speech
import SoundAnalysis

class CalibrationViewController: UIViewController,SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var beginCalibrating: DesignableView!
    @IBOutlet weak var waveForm: WaveFormView!
    @IBOutlet weak var lblTimer: UILabel!
    
    @IBOutlet weak var lblSpeechRecognizer: UILabel!
    weak var waveFormTimer: Timer?
    weak var speechCountdownTimer: Timer?
    
    // MARK: Audio,Speech,SoundAnalysis
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
//    var inputFormat: AVAudioFormat!
    
    // MARK: Variables
    var isRecording = false
    var analysis = ""
    var speechText = ""
    var continueSpeaking = false
    var silenceTimer: Float = 0.0
    var lowPassResults: Float = 0.0
    var totalTime = 59
    
    @IBOutlet weak var onBeginCalibrating: DesignableView!
    
    @IBAction func onBeginCalibrating(_ sender: Any) {
        requestSpeechAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.waveForm.amplitude = 0
        
        recordingSession = AVAudioSession.sharedInstance()
    }
    
    func startRecording() {
        if isRecording == true {
            self.beginCalibrating.setTitle("Begin Recording", for: .normal)
            cancelRecording()
            isRecording = false
            audioRecorder.stop()
            waveFormTimer?.invalidate()
            silenceTimer = 0
        } else {
            
            isRecording = true
            self.beginCalibrating.setTitle("Stop", for: .normal)
            self.startSpeechCountdownTimer()

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let diplayLink = CADisplayLink(target: self, selector: #selector(updateWaveForm))
            diplayLink.add(to: .current, forMode: .common)
            
            let url = URL.init(fileURLWithPath: "/dev/null")
            
            do {
                
                audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
                audioRecorder.isMeteringEnabled = true
                audioRecorder.record()
                
                waveFormTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(dbLevelUpdate), userInfo: nil, repeats: true)
                
                self.recordAndRecognizeSpeech()
                
            } catch {
                //finishRecording(success: false)
            }
            
            
        }
    }
    
    func cancelRecording() {
        
        if audioRecorder != nil {
            isRecording = false
            
            speechCountdownTimer?.invalidate()
            totalTime = 59
            audioRecorder.stop()
            waveFormTimer?.invalidate()
            silenceTimer = 0
            
            // stop audio
            request.endAudio()
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            
            recognitionTask?.cancel()
            recognitionTask?.finish()
            
        }
        
    }
    
    func startSpeechCountdownTimer() {
        speechCountdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSpeechCountdown), userInfo: nil, repeats: true)
    }
    
    
    @objc func updateWaveForm(){
        
        var normalizedValue : CGFloat = 0
        
        self.audioRecorder.updateMeters()
        
        normalizedValue = normalizedPowerLevelFromDecibels(decibels: self.audioRecorder.averagePower(forChannel: 0))
        
        self.waveForm.amplitude = normalizedValue
        
    }
    
    
    @objc func dbLevelUpdate(timer: Timer) {
        
        if self.audioRecorder != nil {
            let ALPHA: Float = 0.05
            let peakPowerForChannel = pow(10, (0.05 * self.audioRecorder.peakPower(forChannel: 0)))
            lowPassResults = ALPHA * peakPowerForChannel + ( 1.0 - ALPHA) * lowPassResults
            
            if lowPassResults < Constants.dbThreshold {
                if self.lblSpeechRecognizer.text?.count ?? 0 > 0 {
                    self.silenceTimer += ALPHA
                }
            } else {
                silenceTimer = 0
            }
            
//            self.checkCurrentSpeechTask()
            
        }
    }
    
    
    func normalizedPowerLevelFromDecibels(decibels: Float) -> CGFloat {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        
        return CGFloat(powf((powf(10.0, 0.05 * decibels) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - pow(10.0, 0.05 * -60.0))), 1.0 / 2.0))
    }
    
    
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        self.showDialog(message: "I can't hear you, please allow the permission")
                    }
                }
            }
        } catch {
            self.showDialog(message: "I can't hear you, please allow the permission")
        }
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Authroizerd")
                    self.startRecording()
                case .denied:
                    print("Denied")
                    self.showDialog(message: "I can't hear you, please allow the permission")
                case .restricted:
                    print("Restricted")
                    self.showDialog(message: "I can't hear you, please allow the permission")
                case .notDetermined:
                    print("notDetermined")
                    self.showDialog(message: "I can't hear you, please allow the permission")
                @unknown default:
                    return
                }
            }
        }
    }
    
    @objc func updateSpeechCountdown() {
        self.lblTimer.text = "\(totalTime.timeFormatted())"
        
        if totalTime != 0 {
            totalTime -= 1

        } else {
//            self.currentMode = .taskAnalyze
//            self.setupTaskMode()
            speechCountdownTimer?.invalidate()
        }
    }
    
    //MARK: - Recognize Speech
    func recordAndRecognizeSpeech() {
        
        if (recognitionTask != nil) {
            recognitionTask?.cancel()
            recognitionTask?.finish()
            recognitionTask = nil
        }
        
        
        self.request =  SFSpeechAudioBufferRecognitionRequest()
        let node = audioEngine.inputNode
        
        audioEngine.inputNode.removeTap(onBus: 0)
        let recordingFormat = node.outputFormat(forBus: 0)

        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            self.request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(title: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            return
        }
        
//        if Constants.useOnDeviceRecognition {
//
//            print("SUPPORT ON DEVICE \(String(describing: speechRecognizer?.supportsOnDeviceRecognition))")
//
//            // Keep speech recognition data on device
//            if #available(iOS 13, *) {
//                self.request.requiresOnDeviceRecognition = true
//            }
//        }
        
        let currentSpeechText = self.speechText
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                if result.isFinal {
                    // self.sendAlert(title: "Sorry lost connection", message: "Speech recognition is not currently available. Check back at a later time.
                    print("SPEECH IS FINAL")
                }
                
                let bestString = result.bestTranscription.formattedString
                
                self.speechText = "\(currentSpeechText) \(bestString)"
                self.lblSpeechRecognizer.text = self.speechText
                
            } else if let error = error {
                //                self.recordAndRecognizeSpeech()
                //                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
