//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import Speech
import SoundAnalysis

protocol EmotionClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double)
    func setExcited(excited: Bool)
    func setNeutral(neutral: Bool)
}

extension MainViewController: EmotionClassifierDelegate {
    func setNeutral(neutral: Bool) {
        self.isNeutral = neutral
    }
    
    func setExcited(excited: Bool) {
        self.isExcited = excited
    }
    
    func displayPredictionResult(identifier: String, confidence: Double) {
        DispatchQueue.main.async {
            
            let roundConfidence = Double(round(100*confidence)/100)
            self.lblSoundAnalysis.text = ("Recognition: \(identifier) with Confidence \(roundConfidence)")
        }
    }
    
}

class ResultsObserver: NSObject, SNResultsObserving {
    var delegate: EmotionClassifierDelegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }
        
        let confidence = classification.confidence * 100.0
        
        if classification.identifier == "Excited" &&  confidence > 80 {
            delegate?.setExcited(excited: true)
            delegate?.setNeutral(neutral: false)
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        } else if classification.identifier == "Neutral" &&  confidence > 80 {
            delegate?.setExcited(excited: false)
            delegate?.setNeutral(neutral: true)
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        } else {
            delegate?.setExcited(excited: false)
            delegate?.setNeutral(neutral: false)
        }
    }
}
