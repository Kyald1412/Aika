//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import ARKit

class TrainingViewController : UIViewController,AVAudioPlayerDelegate{
   
    var audioPlayer:AVAudioPlayer!
    var soundsByLabel: SoundsByLabel!

    var recorder = AKAudioRecorder.shared

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
//        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = .black
        
        soundsByLabel = SoundsByLabel(dataset: trainingDataset)
        self.tableView.reloadData()
    }
    
    @IBAction func trainData(_ sender: Any) {
        print("laelsss \(labels.labelNames)")
        print("label internal  \(labels.internalLabelNames)")
        
        showDialog(message: "Coming soon :(")
        
    }
    
    @IBAction func backToSetting(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        soundsByLabel = SoundsByLabel(dataset: trainingDataset)
        self.tableView.reloadData()
    }

}

extension TrainingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return labels.internalLabelNames[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundsByLabel.numberOfSounds(for: labels.internalLabelNames[section])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecordedSoundCell.identifier, for: indexPath) as? RecordedSoundCell {
                
                let fileName = soundsByLabel.sound(for: labels.internalLabelNames[indexPath.section], at: indexPath.row)?.lastPathComponent
                cell.lblFIleName.text = fileName
                return cell
            }

        }
        
        if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecordedSoundCell.identifier, for: indexPath) as? RecordedSoundCell {
                
                let fileName = soundsByLabel.sound(for: labels.internalLabelNames[indexPath.section], at: indexPath.row)?.lastPathComponent
                cell.lblFIleName.text = fileName
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = soundsByLabel.sound(for: labels.internalLabelNames[indexPath.section], at: indexPath.row)!
        if recorder.isPlaying {
            recorder.stopPlaying()
            recorder.play(path: file)
        } else {
            recorder.play(path: file)
        }
        if indexPath.section == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecordedSoundCell.identifier, for: indexPath) as? RecordedSoundCell {
                cell.playSlider()
            }

        }
        
        if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecordedSoundCell.identifier, for: indexPath) as? RecordedSoundCell {
                cell.playSlider()
            }
        }

    }
    
    //MARK:- Delete Recording
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            soundsByLabel.removeSound(for:labels.internalLabelNames[indexPath.section], at: indexPath.row)
            soundsByLabel = SoundsByLabel(dataset: trainingDataset)
            self.tableView.reloadData()
            
//            let name = recorder.getRecordings[indexPath.row]
//            recorder.deleteRecording(name: name)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            debugLog("Deleted Recording")
//            print(recorder.getRecordings)
        }
    }
    
}
