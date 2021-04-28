//
//  SpeechRecognitionVC.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 27/04/21.
//

import UIKit
import SoundAnalysis

class SpeechAnalyzerVC: UIViewController {
    
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = EmotionModel()
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    
    @IBOutlet weak var transcriberText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
    }
    override func viewDidAppear(_ animated: Bool) {
        startAudioEngine()
    }
    
    private func startAudioEngine() {
        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try analyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8000, format: inputFormat) { buffer, time in
            self.analysisQueue.async {
                self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        
        do{
            try audioEngine.start()
        }catch( _){
            print("error in starting the Audio Engin")
        }
    }
}
protocol EmotionClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double)
}

extension SpeechAnalyzerVC: EmotionClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double) {
        DispatchQueue.main.async {
            
            let roundConfidence = Double(round(100*confidence)/100)
            self.transcriberText.text = ("Recognition: \(identifier) with Confidence \(roundConfidence)")
        }
    }
}

class ResultsObserver: NSObject, SNResultsObserving {
    var delegate: EmotionClassifierDelegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }
        
        let confidence = classification.confidence * 100.0
        
        if confidence > 80 {
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        }
    }
}
