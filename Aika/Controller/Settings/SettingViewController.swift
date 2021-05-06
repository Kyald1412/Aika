//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import ARKit
import Speech

class SettingViewController : UIViewController{
   
    @IBOutlet weak var offlineRecognitionControl: UISwitch!

    @IBAction func onUseOfflineRecognition(_ sender: Any) {
        
        if offlineRecognitionControl.isOn {
            
            if #available(iOS 13, *) {
                let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
                if let recognizer = speechRecognizer?.supportsOnDeviceRecognition {
                    if recognizer {
                        Constants.useOnDeviceRecognition = true

                    } else {
                        self.sendAlert(title:"Alert",message:"Sorry, online recognition is not supported yet, please try to calibrate first")
                        Constants.useOnDeviceRecognition = false   
                    }
                }
            }
        } else {
            Constants.useOnDeviceRecognition = false
        }
        self.offlineRecognitionControl.isOn = Constants.useOnDeviceRecognition
        
    }
   
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.offlineRecognitionControl.isOn = Constants.useOnDeviceRecognition
        
    }
    
    @IBAction func unwindToSetting( _ seg: UIStoryboardSegue) {
        
    }
    
}
