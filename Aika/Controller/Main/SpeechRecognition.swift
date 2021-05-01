//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import Speech
import SoundAnalysis

extension MainViewController: SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {
    
    func startRecording() {
        if isRecording == true {
            cancelRecording()
            isRecording = false
            audioRecorder.stop()
            waveFormTimer?.invalidate()
            silenceTimer = 0
        } else {
            
            isRecording = true
            
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
            
            self.checkCurrentSpeechTask()

        }
    }
    
    func cancelRecording() {
        
        if audioRecorder != nil {
            isRecording = false
            
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
    
    @objc func updateWaveForm(){
        
        var normalizedValue : CGFloat = 0
        
        self.audioRecorder.updateMeters()
        
        normalizedValue = normalizedPowerLevelFromDecibels(decibels: self.audioRecorder.averagePower(forChannel: 0))
        
        self.waveForm.amplitude = normalizedValue
        
    }
    
    func normalizedPowerLevelFromDecibels(decibels: Float) -> CGFloat {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        
        return CGFloat(powf((powf(10.0, 0.05 * decibels) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - pow(10.0, 0.05 * -60.0))), 1.0 / 2.0))
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
            return
        }
        
        
        if Constants.useOnDeviceRecognition {
            
            print("SUPPORT ON DEVICE \(String(describing: speechRecognizer?.supportsOnDeviceRecognition))")
            
            // Keep speech recognition data on device
            if #available(iOS 13, *) {
                self.request.requiresOnDeviceRecognition = true
            }
        }
        
        
        let currentSpeechText = self.speechText
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                if result.isFinal {
                    // self.sendAlert(title: "Sorry lost connection", message: "Speech recognition is not currently available. Check back at a later time.
                    print("SPEECH IS FINAL")
                    // Add continuation here when speech recognizer break
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
    
    func checkCurrentSpeechTask() {
        switch (currentMode) {
        case .groundZero:
            print("groundZero")
        case .initial :
            print("initial")
            self.speechInitialTaskCheck()
        case .taskOption:
            print("task Option")
        case .taskBegin:
            print("task begin")
        case .taskProcess:
            print("task Process")
            self.speechTaskProcessCheck()
        case .taskDone:
            print("Call Result View Controller here")
        case .taskAnalyze:
            print("Call Result View Controller here")
        case .showResult:
            print("showResult")
            
        }
        
    }
    
    func speechTaskProcessCheck(){
        if self.lblSpeechRecognizer.text?.count ?? 0 > 0 && silenceTimer > 5 {
            self.cancelRecording()
            self.continueSpeaking = false
            self.currentMode = .taskDone
        }
    }
    
    func speechInitialTaskCheck(){
        if self.lblSpeechRecognizer.text?.count ?? 0 > 0 && silenceTimer > 2 {
            self.cancelRecording()
            self.currentMode = .taskOption
        }
    }
  
}

