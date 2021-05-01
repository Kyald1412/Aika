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
            self.currentMode = .taskAnalyze
        case .taskAnalyze:
            print("Analysze")
        case .showResult:
            print("showResult")
        }
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
        case .taskAnalyze:
            print("Analysze")
        case .showResult:
            print("showResult")
        }
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
            self.startTimer()
            self.lblAikaMain.text = "I'm listening, go on!"
            self.requestSpeechAuthorization()
        case .taskDone:
            self.lblAikaMain.text = "Are you finished?"
            self.btnOptionTrain.setTitle("Yes!", for: .normal)
            self.btnOptionListen.setTitle("I'm not done yet", for: .normal)
            self.btnOptionListen.borderWidth = 0
            self.cancelRecording()
        case .taskAnalyze:
            self.lblAikaMain.text = "Analyzing your speech..."
            self.cancelRecording()
//            self.circularProgressBar.progressAnimation(duration: 5)
            self.taskAnalyzeComplete()
        case .showResult:
            print("showResult")
        }
        
        self.setupView()
    }
    
    func setupView(){

        self.viewMain.isHidden = false

        switch (currentMode) {
        case .groundZero:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
            self.viewTaskAnalyze.isHidden = true
            self.icAika.isHidden = false
        case .initial :
            self.viewTaskOption.isHidden = true
            self.viewSpeechAnalyzer.isHidden = false
            self.viewTaskAnalyze.isHidden = true
            self.icAika.isHidden = false
        case .taskOption:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
            self.viewTaskAnalyze.isHidden = true
            self.icAika.isHidden = false
        case .taskBegin:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
            self.viewTaskAnalyze.isHidden = true
            self.icAika.isHidden = false
        case .taskProcess:
            self.viewTaskOption.isHidden = true
            self.viewSpeechAnalyzer.isHidden = false
            self.viewTaskAnalyze.isHidden = true
            self.icAika.isHidden = false
        case .taskDone:
            self.viewTaskOption.isHidden = false
            self.viewSpeechAnalyzer.isHidden = true
            self.viewTaskAnalyze.isHidden = true
            self.icAika.isHidden = false
        case .taskAnalyze:
            self.viewTaskOption.isHidden = true
            self.viewSpeechAnalyzer.isHidden = true
            self.viewTaskAnalyze.isHidden = false
            self.icAika.isHidden = false
        case .showResult:
            self.viewTaskOption.isHidden = true
            self.viewSpeechAnalyzer.isHidden = true
            self.viewTaskAnalyze.isHidden = true
            self.icAika.isHidden = true
            self.viewMain.isHidden = true
        }
    }
    
}
