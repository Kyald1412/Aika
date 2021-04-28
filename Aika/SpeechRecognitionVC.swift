//
//  SpeechRecognitionVC.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 27/04/21.
//

import UIKit
import Speech

class SpeechRecognitionVC: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var waveFormView: WaveFormView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        self.requestSpeechAuthorization()
        
        
        
    }
    
    //MARK: - Colors
    enum Color: String {
        case Red, Orange, Yellow, Green, Blue, Purple, Black, Gray
        
        var create: UIColor {
            switch self {
            case .Red:
                return UIColor.red
            case .Orange:
                return UIColor.orange
            case .Yellow:
                return UIColor.yellow
            case .Green:
                return UIColor.green
            case .Blue:
                return UIColor.blue
            case .Purple:
                return UIColor.purple
            case .Black:
                return UIColor.black
            case .Gray:
                return UIColor.gray
            }
        }
    }
    
    //MARK: IBActions and Cancel
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            cancelRecording()
            isRecording = false
            startButton.backgroundColor = UIColor.gray
            audioRecorder.stop()
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            startButton.backgroundColor = UIColor.red
            
            let settings = [
                   AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                   AVSampleRateKey: 12000,
                   AVNumberOfChannelsKey: 1,
                   AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
               ]

//            CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
//                [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
                
            
            let diplayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
            diplayLink.add(to: .current, forMode: .common)
            
            
            
            let url = URL.init(fileURLWithPath: "/dev/null")
            
            do {
                audioRecorder = try AVAudioRecorder(url: url, settings: settings)
//                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
                audioRecorder.isMeteringEnabled = true
                audioRecorder.record()
                
            } catch {
                //                   finishRecording(success: false)
            }
            
        }
    }
    
    @objc func updateMeters(){
        
        var normalizedValue : CGFloat = 0
        
        self.audioRecorder.updateMeters()
        
        normalizedValue = normalizedPowerLevelFromDecibels(decibels: self.audioRecorder.averagePower(forChannel: 0))

        
        self.waveFormView.amplitude = normalizedValue
//        [self.waveformView updateWithLevel:normalizedValue];

    }
    
    func normalizedPowerLevelFromDecibels(decibels: Float) -> CGFloat {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        
        
        
        return CGFloat(powf((powf(10.0, 0.05 * decibels) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - pow(10.0, 0.05 * -60.0))), 1.0 / 2.0))
    }
    
//    - (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
//    {
//        if (decibels < -60.0f || decibels == 0.0f) {
//            return 0.0f;
//        }
//
//        return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
//    }

    
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    //MARK: - Recognize Speech
    func recordAndRecognizeSpeech() {
        

        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
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
            // Recognizer is not available right now
            return
        }
//        // Keep speech recognition data on device
//        if #available(iOS 13, *) {
//            //recognitionRequest.requiresOnDeviceRecognition = false
//            self.request.requiresOnDeviceRecognition = true
//        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                }
                self.detectedTextLabel.text = bestString
                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    func loadRecordingUI() {
    }
    
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                @unknown default:
                    return
                }
            }
        }
    }
    
    //MARK: - UI / Set view color.
    func checkForColorsSaid(resultString: String) {
        guard let color = Color(rawValue: resultString) else { return }
        colorView.backgroundColor = color.create
        //        self.detectedTextLabel.text = resultString
    }
    
    //MARK: - Alert
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
