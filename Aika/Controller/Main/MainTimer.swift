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
   
    func startSpeechCountdownTimer() {
        speechCountdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSpeechCountdown), userInfo: nil, repeats: true)
    }

    func startExpressionTimer(){
        expressionStartTime = Date().timeIntervalSinceReferenceDate
        expressionTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(updateExpression),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopExpressionTimer(){
        expressionTimer?.invalidate()
    }
    
    @objc func updateExpression() {
                        
        if isSmiling {
            self.expression.smiling += 0.05
        } else {
            self.expression.neutral += 0.05
        }
        if isLookOut {
            self.expression.lookOut += 0.05
        }
        if isExcited {
            self.expression.excited += 0.05
        }

        self.expression.timeSpeaking = Float(Date().timeIntervalSinceReferenceDate - expressionStartTime)
        self.lblTimer.text = self.expression.timeSpeakingString()
    }
    
    @objc func updateSpeechCountdown() {
        self.lblTimer.text = "\(Constants.totalTime.timeFormatted())"
        
        if Constants.totalTime != 0 {
            Constants.totalTime -= 1

        } else {
            self.currentMode = .taskAnalyze
            self.setupTaskMode()
            speechCountdownTimer?.invalidate()
        }
    }
    
}
