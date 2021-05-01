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

extension MainViewController {
    
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
                    if !allowed {
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
}
