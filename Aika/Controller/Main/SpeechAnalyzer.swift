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
}

extension MainViewController: EmotionClassifierDelegate {
    
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
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        } else {
            delegate?.setExcited(excited: false)
        }
    }
}
