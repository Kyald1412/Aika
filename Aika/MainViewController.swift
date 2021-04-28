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
    @IBOutlet var sceneView: ARSCNView!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    var analysis = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSpeechRecognition()
        initFaceRecognition()
    }
    
    func initFaceRecognition(){
        sceneView.delegate = self
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
    }
    
    func initSpeechRecognition(){
        recordingSession = AVAudioSession.sharedInstance()
        
        requestSpeechAuthorization()
    }

    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
//                        self.loadRecordingUI()
//                        self.startRecording()
                    } else {
                        self.lblAikaMain.text = "I can't hear you, please allow the permission"
                    }
                }
            }
        } catch {
            self.lblAikaMain.text = "I can't hear you, please allow the permission"
        }
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Authroizerd")
                    self.startRecording()
                case .denied:
                    print("Denied")
                    self.lblAikaMain.text = "I can't hear you, please allow the permission"
                case .restricted:
                    print("Restricted")
                    self.lblAikaMain.text = "I can't hear you, please allow the permission"
                case .notDetermined:
                    print("notDetermined")
                    self.lblAikaMain.text = "I can't hear you, please allow the permission"
                @unknown default:
                    return
                }
            }
        }
    }
    
    //MARK: - Alert
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
