//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import ARKit

class AddTraindataViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet weak var currentClassification: UISegmentedControl!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var soundsByLabel: SoundsByLabel!
    
    func animate(isRecording : Bool){
        if isRecording{
            self.recordButton.layer.cornerRadius = 10
            UIView.animate(withDuration: 0.1) {
                self.recordButton.layer.cornerRadius = 50
            }
        }
        else{
            UIView.animate(withDuration: 0.1) {
                self.recordButton.transform = .identity
                self.recordButton.layer.cornerRadius = 10
            }
        }
    }
    
    @IBAction func saveRecord(_ sender: Any) {
        let spesification = currentClassification.titleForSegment(at: currentClassification.selectedSegmentIndex) ?? ""
        
        soundsByLabel.addSound(trainingDataset.generateFileUrl(fileName: soundsByLabel.generatedFileName, spesification: spesification), for: spesification)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelRecord(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundsByLabel = SoundsByLabel(dataset: trainingDataset)
        
        //setup Recorder
        self.setupView()
    }
    
    func setupView() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record
                    }
                }
            }
        } catch {
            // failed to record
        }
    }
    
    func loadRecordingUI() {
        recordButton.isEnabled = true
        playButton.isEnabled = false
        recordButton.setTitle("Record", for: .normal)
        recordButton.addTarget(self, action: #selector(recordAudioButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    @objc func recordAudioButtonTapped(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
            animate(isRecording: false)
        } else {
            animate(isRecording: true)
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        
        let spesification = currentClassification.titleForSegment(at: currentClassification.selectedSegmentIndex) ?? ""

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: trainingDataset.generateFileUrl(fileName: soundsByLabel.generatedFileName, spesification: spesification), settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Stop", for: .normal)
            playButton.isEnabled = false
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Re-record", for: .normal)
        } else {
            recordButton.setTitle("Record", for: .normal)
            // recording failed :(
        }
        
        playButton.isEnabled = true
        recordButton.isEnabled = true
    }
    
    @IBAction func playAudioButtonTapped(_ sender: UIButton) {
        if (sender.titleLabel?.text == "Play"){
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            preparePlayer()
            audioPlayer.play()
        } else {
            audioPlayer.stop()
            sender.setTitle("Play", for: .normal)
        }
    }
    
    func preparePlayer() {
        
        let spesification = currentClassification.titleForSegment(at: currentClassification.selectedSegmentIndex) ?? ""

        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: trainingDataset.generateFileUrl(fileName: soundsByLabel.generatedFileName, spesification: spesification) as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
        }
    }
    
    
    //MARK: Delegates
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
    //MARK: To upload video on server
    
    func uploadAudioToServer() {
        /*Alamofire.upload(
         multipartFormData: { multipartFormData in
         multipartFormData.append(getFileURL(), withName: "audio.m4a")
         },
         to: "https://yourServerLink",
         encodingCompletion: { encodingResult in
         switch encodingResult {
         case .success(let upload, _, _):
         upload.responseJSON { response in
         Print(response)
         }
         case .failure(let encodingError):
         print(encodingError)
         }
         })*/
    }
    
    
}
