//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import Speech
import SoundAnalysis

extension MainViewController: SFSpeechRecognizerDelegate {
    
    //MARK: IBActions and Cancel
    func startRecording() {
        if isRecording == true {
            cancelRecording()
            isRecording = false
            audioRecorder.stop()
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
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
                //finishRecording(success: false)
            }
            
        }
    }
    
    
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    @objc func updateMeters(){
        
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
                
                if result.isFinal {
                    self.sendAlert(title: "ARE YOU DONE?", message: "Speech recognition is not currently available. Check back at a later time.")

                }
                
                let bestString = result.bestTranscription.formattedString
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                }
                self.lblSpeechRecognizer.text = bestString
                //                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
}

